import '../models/podcast.dart';

class PodcastService {
  static const String _baseUrl = 'https://api.podcastindex.org/api/1.0';
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key
  static const String _apiSecret = 'YOUR_API_SECRET'; // Replace with actual API secret

  // For demo purposes, we'll use mock data
  static const List<Map<String, dynamic>> _mockPodcasts = [
    {
      'id': '1',
      'title': 'The Daily',
      'description': 'This is what the news should sound like. The biggest stories of our time, told by the best journalists in the world.',
      'artworkUrl': 'https://megaphone.imgix.net/podcasts/6ba4b0b0-e10e-11e7-a97a-e7104350e3f3/image/uploads_2F1517777805062-6azs2ogr9ai-06c4b3b2b15e4e67d7b5e6db4b1fc3d5_2FThe+Daily+Art+Final+with+White.jpg',
      'publisher': 'The New York Times',
      'category': 'News',
      'language': 'en',
      'episodeCount': 1200,
      'rating': 4.5,
      'ratingCount': 15420,
      'episodes': []
    },
    {
      'id': '2',
      'title': 'Serial',
      'description': 'Serial is a podcast from the creators of This American Life, hosted by Sarah Koenig.',
      'artworkUrl': 'https://serialpodcast.org/sites/default/files/serial-itunes-logo.png',
      'publisher': 'Serial Productions',
      'category': 'True Crime',
      'language': 'en',
      'episodeCount': 60,
      'rating': 4.8,
      'ratingCount': 28920,
      'episodes': []
    },
    {
      'id': '3',
      'title': 'The Joe Rogan Experience',
      'description': 'The Joe Rogan Experience podcast is a long form conversation hosted by comedian Joe Rogan.',
      'artworkUrl': 'https://i.scdn.co/image/ab6765630000ba8a7b2e8b4c6f6f6f6f6f6f6f6f',
      'publisher': 'Joe Rogan',
      'category': 'Comedy',
      'language': 'en',
      'episodeCount': 2000,
      'rating': 4.2,
      'ratingCount': 45670,
      'episodes': []
    },
  ];

  static const List<Map<String, dynamic>> _mockEpisodes = [
    {
      'id': '1-1',
      'podcastId': '1',
      'title': 'Monday, June 16, 2025',
      'description': 'Today\'s top stories from around the world.',
      'audioUrl': 'https://example.com/episode1.mp3',
      'duration': 1800000, // 30 minutes in milliseconds
      'publishDate': '2025-06-16T06:00:00Z',
      'rating': 4.6,
      'ratingCount': 234,
    },
    {
      'id': '1-2',
      'podcastId': '1',
      'title': 'Friday, June 13, 2025',
      'description': 'Weekly roundup of major news events.',
      'audioUrl': 'https://example.com/episode2.mp3',
      'duration': 2100000, // 35 minutes in milliseconds
      'publishDate': '2025-06-13T06:00:00Z',
      'rating': 4.4,
      'ratingCount': 189,
    },
  ];

  Future<List<Podcast>> fetchPodcasts({
    String? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo, return mock data
    List<Map<String, dynamic>> filteredPodcasts = List.from(_mockPodcasts);
    
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredPodcasts = filteredPodcasts.where((podcast) {
        return podcast['title'].toLowerCase().contains(searchQuery.toLowerCase()) ||
               podcast['description'].toLowerCase().contains(searchQuery.toLowerCase()) ||
               podcast['publisher'].toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    if (category != null && category.isNotEmpty) {
      filteredPodcasts = filteredPodcasts.where((podcast) {
        return podcast['category'].toLowerCase() == category.toLowerCase();
      }).toList();
    }
    
    return filteredPodcasts.map((json) => Podcast.fromJson(json)).toList();
  }

  Future<Podcast?> fetchPodcastById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final podcastData = _mockPodcasts.firstWhere(
      (podcast) => podcast['id'] == id,
      orElse: () => {},
    );
    
    if (podcastData.isEmpty) return null;
    
    // Add episodes to the podcast
    final episodes = await fetchEpisodesByPodcastId(id);
    podcastData['episodes'] = episodes.map((e) => e.toJson()).toList();
    
    return Podcast.fromJson(podcastData);
  }

  Future<List<Episode>> fetchEpisodesByPodcastId(String podcastId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final episodeData = _mockEpisodes.where((episode) => 
      episode['podcastId'] == podcastId
    ).toList();
    
    return episodeData.map((json) {
      // Convert duration from milliseconds to Duration object
      final durationMs = json['duration'];
      json['duration'] = Duration(milliseconds: durationMs).inSeconds;
      
      // Convert publishDate string to DateTime
      json['publishDate'] = DateTime.parse(json['publishDate']).toIso8601String();
      
      return Episode.fromJson(json);
    }).toList();
  }

  Future<List<String>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
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
    ];
  }

  Future<List<Podcast>> fetchTrendingPodcasts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Return a subset of mock podcasts as trending
    return _mockPodcasts.take(2).map((json) => Podcast.fromJson(json)).toList();
  }

  Future<List<Podcast>> fetchRecommendedPodcasts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Return mock recommendations based on user preferences
    return _mockPodcasts.map((json) => Podcast.fromJson(json)).toList();
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
