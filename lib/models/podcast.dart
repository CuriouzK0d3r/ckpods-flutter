class Podcast {
  final String id;
  final String name;
  final String artist;
  final String imageUrl;
  final String feedUrl;
  final String description;
  final List<Episode> episodes;

  Podcast({
    required this.id,
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.feedUrl,
    required this.description,
    this.episodes = const [],
  });

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['collectionId']?.toString() ?? '',
      name: json['collectionName'] ?? '',
      artist: json['artistName'] ?? '',
      imageUrl: json['artworkUrl600'] ?? json['artworkUrl100'] ?? '',
      feedUrl: json['feedUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class Episode {
  final String id;
  final String title;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final DateTime publishDate;
  final Duration duration;

  Episode({
    required this.id,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.publishDate,
    required this.duration,
  });

  factory Episode.fromXml(dynamic item, String podcastImageUrl) {
    final title = item.findElements('title').first.text;
    final description = item.findElements('description').first.text;

    String audioUrl = '';
    final enclosures = item.findElements('enclosure');
    if (enclosures.isNotEmpty) {
      audioUrl = enclosures.first.getAttribute('url') ?? '';
    }

    String imageUrl = podcastImageUrl;
    final itunesImage = item.findElements('itunes:image');
    if (itunesImage.isNotEmpty) {
      imageUrl = itunesImage.first.getAttribute('href') ?? podcastImageUrl;
    }

    DateTime publishDate = DateTime.now();
    try {
      final pubDateStr = item.findElements('pubDate').first.text;
      publishDate = DateTime.parse(pubDateStr);
    } catch (e) {
      // Use current date if parsing fails
    }

    return Episode(
      id: title.hashCode.toString(),
      title: title,
      description: description,
      audioUrl: audioUrl,
      imageUrl: imageUrl,
      publishDate: publishDate,
      duration: const Duration(minutes: 30), // Default duration
    );
  }
}
