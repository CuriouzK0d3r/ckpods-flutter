import 'package:json_annotation/json_annotation.dart';

part 'podcast.g.dart';

@JsonSerializable()
class Podcast {
  final String id;
  final String title;
  final String description;
  final String artworkUrl;
  final String publisher;
  final String category;
  final String language;
  final int episodeCount;
  final DateTime? lastUpdated;
  final double rating;
  final int ratingCount;
  final List<Episode> episodes;
  final bool isFavorite;

  Podcast({
    required this.id,
    required this.title,
    required this.description,
    required this.artworkUrl,
    required this.publisher,
    required this.category,
    required this.language,
    this.episodeCount = 0,
    this.lastUpdated,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.episodes = const [],
    this.isFavorite = false,
  });

  factory Podcast.fromJson(Map<String, dynamic> json) => _$PodcastFromJson(json);
  Map<String, dynamic> toJson() => _$PodcastToJson(this);

  Podcast copyWith({
    String? id,
    String? title,
    String? description,
    String? artworkUrl,
    String? publisher,
    String? category,
    String? language,
    int? episodeCount,
    DateTime? lastUpdated,
    double? rating,
    int? ratingCount,
    List<Episode>? episodes,
    bool? isFavorite,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      publisher: publisher ?? this.publisher,
      category: category ?? this.category,
      language: language ?? this.language,
      episodeCount: episodeCount ?? this.episodeCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      episodes: episodes ?? this.episodes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

@JsonSerializable()
class Episode {
  final String id;
  final String podcastId;
  final String title;
  final String description;
  final String audioUrl;
  final Duration duration;
  final DateTime publishDate;
  final String? thumbnailUrl;
  final double rating;
  final int ratingCount;
  final bool isPlayed;
  final bool isDownloaded;
  final Duration? playbackPosition;

  Episode({
    required this.id,
    required this.podcastId,
    required this.title,
    required this.description,
    required this.audioUrl,
    required this.duration,
    required this.publishDate,
    this.thumbnailUrl,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isPlayed = false,
    this.isDownloaded = false,
    this.playbackPosition,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => _$EpisodeFromJson(json);
  Map<String, dynamic> toJson() => _$EpisodeToJson(this);

  Episode copyWith({
    String? id,
    String? podcastId,
    String? title,
    String? description,
    String? audioUrl,
    Duration? duration,
    DateTime? publishDate,
    String? thumbnailUrl,
    double? rating,
    int? ratingCount,
    bool? isPlayed,
    bool? isDownloaded,
    Duration? playbackPosition,
  }) {
    return Episode(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      title: title ?? this.title,
      description: description ?? this.description,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      publishDate: publishDate ?? this.publishDate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isPlayed: isPlayed ?? this.isPlayed,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      playbackPosition: playbackPosition ?? this.playbackPosition,
    );
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m ${seconds}s';
    }
  }
}
