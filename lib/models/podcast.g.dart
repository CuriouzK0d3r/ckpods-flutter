// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'podcast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Podcast _$PodcastFromJson(Map<String, dynamic> json) => Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      artworkUrl: json['artworkUrl'] as String,
      publisher: json['publisher'] as String,
      category: json['category'] as String,
      language: json['language'] as String,
      episodeCount: json['episodeCount'] as int? ?? 0,
      lastUpdated: json['lastUpdated'] == null
          ? null
          : DateTime.parse(json['lastUpdated'] as String),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );

Map<String, dynamic> _$PodcastToJson(Podcast instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'artworkUrl': instance.artworkUrl,
      'publisher': instance.publisher,
      'category': instance.category,
      'language': instance.language,
      'episodeCount': instance.episodeCount,
      'lastUpdated': instance.lastUpdated?.toIso8601String(),
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'episodes': instance.episodes,
      'isFavorite': instance.isFavorite,
    };

Episode _$EpisodeFromJson(Map<String, dynamic> json) => Episode(
      id: json['id'] as String,
      podcastId: json['podcastId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      audioUrl: json['audioUrl'] as String,
      duration: Duration(seconds: json['duration'] as int),
      publishDate: DateTime.parse(json['publishDate'] as String),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      isPlayed: json['isPlayed'] as bool? ?? false,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      playbackPosition: json['playbackPosition'] == null
          ? null
          : Duration(seconds: json['playbackPosition'] as int),
    );

Map<String, dynamic> _$EpisodeToJson(Episode instance) => <String, dynamic>{
      'id': instance.id,
      'podcastId': instance.podcastId,
      'title': instance.title,
      'description': instance.description,
      'audioUrl': instance.audioUrl,
      'duration': instance.duration.inSeconds,
      'publishDate': instance.publishDate.toIso8601String(),
      'thumbnailUrl': instance.thumbnailUrl,
      'rating': instance.rating,
      'ratingCount': instance.ratingCount,
      'isPlayed': instance.isPlayed,
      'isDownloaded': instance.isDownloaded,
      'playbackPosition': instance.playbackPosition?.inSeconds,
    };
