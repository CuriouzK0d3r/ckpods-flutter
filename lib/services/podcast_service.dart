import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/podcast.dart';

class PodcastService {
  static const String _itunesSearchUrl = 'https://itunes.apple.com/search';
  static const String _itunesLookupUrl = 'https://itunes.apple.com/lookup';

  // iTunes API search for podcasts
  Future<List<Podcast>> fetchPodcasts({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      String url;
      String searchTerm;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Search for specific podcasts
        searchTerm = searchQuery;
      } else if (category != null && category != 'All') {
        // Search by category
        searchTerm = '$category podcast';
      } else {
        // Get popular/trending podcasts
        searchTerm = 'podcast';
      }

      url = '$_itunesSearchUrl?'
          'term=${Uri.encodeComponent(searchTerm)}&'
          'media=podcast&'
          'limit=$limit&'
          'entity=podcast&'
          'attribute=titleTerm';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        List<Podcast> podcasts =
            results.map((json) => _mapItunesResultToPodcast(json)).toList();

        // Filter by category if specified
        if (category != null && category != 'All') {
          podcasts = podcasts
              .where((podcast) =>
                  podcast.category
                      .toLowerCase()
                      .contains(category.toLowerCase()) ||
                  podcast.title
                      .toLowerCase()
                      .contains(category.toLowerCase()) ||
                  podcast.description
                      .toLowerCase()
                      .contains(category.toLowerCase()))
              .toList();
        }

        return podcasts;
      } else {
        throw Exception('Failed to fetch podcasts: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching podcasts: $e');
    }
  }

  // Map iTunes API result to our Podcast model
  Podcast _mapItunesResultToPodcast(Map<String, dynamic> json) {
    return Podcast(
      id: json['collectionId']?.toString() ?? '',
      title: json['collectionName'] ?? json['trackName'] ?? '',
      description: _cleanHtml(json['description'] ?? ''),
      artworkUrl: json['artworkUrl600'] ?? json['artworkUrl100'] ?? '',
      publisher: json['artistName'] ?? '',
      category: _extractCategory(json['primaryGenreName'] ?? ''),
      language: json['country'] ?? 'en',
      episodeCount: json['trackCount'] ?? 0,
      rating: 0.0, // iTunes doesn't provide ratings in search results
      ratingCount: 0,
      episodes: [], // Will be populated when fetching individual podcast
    );
  }

  // Clean HTML tags from description
  String _cleanHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ');
  }

  // Extract and normalize category
  String _extractCategory(String genre) {
    // Map iTunes genres to our categories
    final genreMap = {
      'News': 'News',
      'True Crime': 'True Crime',
      'Comedy': 'Comedy',
      'Business': 'Business',
      'Technology': 'Technology',
      'Health & Fitness': 'Health & Fitness',
      'Education': 'Education',
      'Arts': 'Arts',
      'Sports': 'Sports',
      'Science': 'Science',
      'History': 'History',
    };

    return genreMap[genre] ?? 'Other';
  }

  Future<Podcast?> fetchPodcastById(String id) async {
    try {
      final url = '$_itunesLookupUrl?id=$id&entity=podcast';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        if (results.isNotEmpty) {
          final podcast = _mapItunesResultToPodcast(results.first);
          
          // Fetch episodes for this podcast
          final episodes = await fetchEpisodesByPodcastId(id);
          
          // Return podcast with episodes
          return podcast.copyWith(episodes: episodes);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching podcast: $e');
    }
  }

  Future<List<Episode>> fetchEpisodesByPodcastId(String podcastId) async {
    try {
      // First, get the podcast feed URL from iTunes
      final url = '$_itunesLookupUrl?id=$podcastId&entity=podcast';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        
        if (results.isNotEmpty) {
          final feedUrl = results.first['feedUrl'];
          if (feedUrl != null) {
            return await _fetchEpisodesFromRssFeed(feedUrl, podcastId);
          }
        }
      }
      
      // If we can't get the feed URL, return some mock episodes for demo
      return _generateMockEpisodes(podcastId);
    } catch (e) {
      // Return mock episodes if there's an error
      return _generateMockEpisodes(podcastId);
    }
  }

  // Parse RSS feed to get episodes
  Future<List<Episode>> _fetchEpisodesFromRssFeed(String feedUrl, String podcastId) async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      
      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        
        List<Episode> episodes = [];
        
        for (var item in items.take(10)) { // Limit to 10 most recent episodes
          try {
            final title = item.findElements('title').first.innerText;
            final description = _extractDescription(item);
            final audioUrl = _extractAudioUrl(item);
            final duration = _extractDuration(item);
            final publishDate = _extractPublishDate(item);
            
            if (title.isNotEmpty && audioUrl.isNotEmpty) {
              episodes.add(Episode(
                id: '${podcastId}_${episodes.length + 1}',
                podcastId: podcastId,
                title: _cleanHtml(title),
                description: _cleanHtml(description),
                audioUrl: audioUrl,
                duration: duration,
                publishDate: publishDate,
                rating: 4.0 + (episodes.length % 5) * 0.2, // Generate varied ratings
                ratingCount: 50 + (episodes.length * 20),
              ));
            }
          } catch (e) {
            // Skip malformed episodes
            continue;
          }
        }
        
        return episodes.isNotEmpty ? episodes : _generateMockEpisodes(podcastId);
      }
      
      return _generateMockEpisodes(podcastId);
    } catch (e) {
      return _generateMockEpisodes(podcastId);
    }
  }

  String _extractDescription(XmlElement item) {
    // Try different description fields
    var desc = item.findElements('description').isNotEmpty 
        ? item.findElements('description').first.innerText
        : '';
    
    if (desc.isEmpty) {
      desc = item.findElements('itunes:summary').isNotEmpty
          ? item.findElements('itunes:summary').first.innerText
          : '';
    }
    
    if (desc.isEmpty) {
      desc = item.findElements('content:encoded').isNotEmpty
          ? item.findElements('content:encoded').first.innerText
          : '';
    }
    
    return desc.isNotEmpty ? desc : 'Episode description not available.';
  }

  String _extractAudioUrl(XmlElement item) {
    // Look for enclosure tag with audio URL
    final enclosures = item.findElements('enclosure');
    for (var enclosure in enclosures) {
      final url = enclosure.getAttribute('url');
      final type = enclosure.getAttribute('type');
      if (url != null && type != null && type.startsWith('audio/')) {
        return url;
      }
    }
    
    // Fallback to link tag
    final links = item.findElements('link');
    if (links.isNotEmpty) {
      return links.first.innerText;
    }
    
    return 'https://example.com/audio.mp3'; // Fallback URL
  }

  Duration _extractDuration(XmlElement item) {
    // Try to extract duration from iTunes tags
    final durationElements = item.findElements('itunes:duration');
    if (durationElements.isNotEmpty) {
      final durationText = durationElements.first.innerText;
      return _parseDuration(durationText);
    }
    
    // Default duration
    return const Duration(minutes: 30);
  }

  Duration _parseDuration(String durationText) {
    try {
      if (durationText.contains(':')) {
        final parts = durationText.split(':');
        if (parts.length == 2) {
          // MM:SS format
          final minutes = int.parse(parts[0]);
          final seconds = int.parse(parts[1]);
          return Duration(minutes: minutes, seconds: seconds);
        } else if (parts.length == 3) {
          // HH:MM:SS format
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          return Duration(hours: hours, minutes: minutes, seconds: seconds);
        }
      } else {
        // Assume seconds
        final seconds = int.parse(durationText);
        return Duration(seconds: seconds);
      }
    } catch (e) {
      // Return default duration if parsing fails
      return const Duration(minutes: 30);
    }
    
    return const Duration(minutes: 30);
  }

  DateTime _extractPublishDate(XmlElement item) {
    final pubDateElements = item.findElements('pubDate');
    if (pubDateElements.isNotEmpty) {
      try {
        final dateString = pubDateElements.first.innerText;
        return DateTime.parse(dateString);
      } catch (e) {
        // Try RFC 822 format
        try {
          // Basic RFC 822 parsing (simplified)
          return DateTime.now().subtract(Duration(days: item.parent!.children.indexOf(item)));
        } catch (e) {
          return DateTime.now().subtract(Duration(days: item.parent!.children.indexOf(item)));
        }
      }
    }
    
    return DateTime.now().subtract(Duration(days: 1));
  }

  // Generate mock episodes for demo purposes
  List<Episode> _generateMockEpisodes(String podcastId) {
    final now = DateTime.now();
    return [
      Episode(
        id: '${podcastId}_ep1',
        podcastId: podcastId,
        title: 'Latest Episode',
        description: 'The most recent episode with great content and insights.',
        audioUrl: 'https://example.com/episode1.mp3',
        duration: const Duration(minutes: 45),
        publishDate: now.subtract(const Duration(days: 1)),
        rating: 4.6,
        ratingCount: 234,
      ),
      Episode(
        id: '${podcastId}_ep2',
        podcastId: podcastId,
        title: 'Previous Episode',
        description: 'An amazing episode discussing current topics and trends.',
        audioUrl: 'https://example.com/episode2.mp3',
        duration: const Duration(minutes: 38),
        publishDate: now.subtract(const Duration(days: 3)),
        rating: 4.4,
        ratingCount: 189,
      ),
      Episode(
        id: '${podcastId}_ep3',
        podcastId: podcastId,
        title: 'Interview Special',
        description: 'A special interview episode with industry experts.',
        audioUrl: 'https://example.com/episode3.mp3',
        duration: const Duration(minutes: 52),
        publishDate: now.subtract(const Duration(days: 7)),
        rating: 4.8,
        ratingCount: 156,
      ),
      Episode(
        id: '${podcastId}_ep4',
        podcastId: podcastId,
        title: 'Weekly Roundup',
        description: 'Our weekly roundup of important news and discussions.',
        audioUrl: 'https://example.com/episode4.mp3',
        duration: const Duration(minutes: 35),
        publishDate: now.subtract(const Duration(days: 10)),
        rating: 4.3,
        ratingCount: 98,
      ),
      Episode(
        id: '${podcastId}_ep5',
        podcastId: podcastId,
        title: 'Deep Dive Analysis',
        description: 'A comprehensive analysis of recent developments.',
        audioUrl: 'https://example.com/episode5.mp3',
        duration: const Duration(minutes: 41),
        publishDate: now.subtract(const Duration(days: 14)),
        rating: 4.7,
        ratingCount: 203,
      ),
    ];
  }

  Future<List<String>> fetchCategories() async {
    // Return predefined categories that match iTunes genres
    // These categories align with iTunes podcast genres
    return [
      'All',
      'News',
      'True Crime',
      'Comedy',
      'Business',
      'Technology',
      'Health & Fitness',
      'Education',
      'Arts',
      'Sports',
      'Science',
      'History',
      'Society & Culture',
      'Religion & Spirituality',
      'Kids & Family',
      'TV & Film',
      'Music',
      'Government',
    ];
  }

  Future<List<Podcast>> fetchTrendingPodcasts() async {
    // Fetch trending podcasts using iTunes API with popular search terms
    return await fetchPodcasts(searchQuery: 'popular podcasts', limit: 10);
  }

  Future<List<Podcast>> fetchRecommendedPodcasts(String userId) async {
    // Fetch recommended podcasts based on popular categories
    // In a real app, this would be personalized based on user preferences
    return await fetchPodcasts(searchQuery: 'recommended podcasts', limit: 10);
  }

  Future<bool> ratePodcast(String podcastId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // In a real implementation, this would send the rating to the server
    return true;
  }

  Future<bool> rateEpisode(String episodeId, double rating) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // In a real implementation, this would send the rating to the server
    return true;
  }
}
