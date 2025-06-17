// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      favoritePodcastIds: (json['favoritePodcastIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      subscribedPodcastIds: (json['subscribedPodcastIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'settings': instance.settings,
      'favoritePodcastIds': instance.favoritePodcastIds,
      'subscribedPodcastIds': instance.subscribedPodcastIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastActiveAt': instance.lastActiveAt.toIso8601String(),
    };

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      playbackSpeed: (json['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      autoPlay: json['autoPlay'] as bool? ?? true,
      downloadOnWifi: json['downloadOnWifi'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      newEpisodeNotifications: json['newEpisodeNotifications'] as bool? ?? true,
      favoriteUpdatesNotifications:
          json['favoriteUpdatesNotifications'] as bool? ?? true,
      streamingQuality: $enumDecodeNullable(
              _$PlaybackQualityEnumMap, json['streamingQuality']) ??
          PlaybackQuality.standard,
      downloadQuality: $enumDecodeNullable(
              _$PlaybackQualityEnumMap, json['downloadQuality']) ??
          PlaybackQuality.high,
      darkMode: json['darkMode'] as bool? ?? false,
      skipIntro: json['skipIntro'] as bool? ?? false,
      skipIntroLength: json['skipIntroLength'] == null
          ? const Duration(seconds: 30)
          : Duration(microseconds: (json['skipIntroLength'] as num).toInt()),
      skipOutro: json['skipOutro'] as bool? ?? false,
      skipOutroLength: json['skipOutroLength'] == null
          ? const Duration(seconds: 30)
          : Duration(microseconds: (json['skipOutroLength'] as num).toInt()),
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'playbackSpeed': instance.playbackSpeed,
      'volume': instance.volume,
      'autoPlay': instance.autoPlay,
      'downloadOnWifi': instance.downloadOnWifi,
      'notificationsEnabled': instance.notificationsEnabled,
      'newEpisodeNotifications': instance.newEpisodeNotifications,
      'favoriteUpdatesNotifications': instance.favoriteUpdatesNotifications,
      'streamingQuality': _$PlaybackQualityEnumMap[instance.streamingQuality]!,
      'downloadQuality': _$PlaybackQualityEnumMap[instance.downloadQuality]!,
      'darkMode': instance.darkMode,
      'skipIntro': instance.skipIntro,
      'skipIntroLength': instance.skipIntroLength.inMicroseconds,
      'skipOutro': instance.skipOutro,
      'skipOutroLength': instance.skipOutroLength.inMicroseconds,
    };

const _$PlaybackQualityEnumMap = {
  PlaybackQuality.low: 'low',
  PlaybackQuality.standard: 'standard',
  PlaybackQuality.high: 'high',
  PlaybackQuality.ultra: 'ultra',
};
