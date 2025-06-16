import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final UserSettings settings;
  final List<String> favoritePodcastIds;
  final List<String> subscribedPodcastIds;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.settings,
    this.favoritePodcastIds = const [],
    this.subscribedPodcastIds = const [],
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    UserSettings? settings,
    List<String>? favoritePodcastIds,
    List<String>? subscribedPodcastIds,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      settings: settings ?? this.settings,
      favoritePodcastIds: favoritePodcastIds ?? this.favoritePodcastIds,
      subscribedPodcastIds: subscribedPodcastIds ?? this.subscribedPodcastIds,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

@JsonSerializable()
class UserSettings {
  final double playbackSpeed;
  final double volume;
  final bool autoPlay;
  final bool downloadOnWifi;
  final bool notificationsEnabled;
  final bool newEpisodeNotifications;
  final bool favoriteUpdatesNotifications;
  final PlaybackQuality streamingQuality;
  final PlaybackQuality downloadQuality;
  final bool darkMode;
  final bool skipIntro;
  final Duration skipIntroLength;
  final bool skipOutro;
  final Duration skipOutroLength;

  UserSettings({
    this.playbackSpeed = 1.0,
    this.volume = 1.0,
    this.autoPlay = true,
    this.downloadOnWifi = true,
    this.notificationsEnabled = true,
    this.newEpisodeNotifications = true,
    this.favoriteUpdatesNotifications = true,
    this.streamingQuality = PlaybackQuality.standard,
    this.downloadQuality = PlaybackQuality.high,
    this.darkMode = false,
    this.skipIntro = false,
    this.skipIntroLength = const Duration(seconds: 30),
    this.skipOutro = false,
    this.skipOutroLength = const Duration(seconds: 30),
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => _$UserSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$UserSettingsToJson(this);

  UserSettings copyWith({
    double? playbackSpeed,
    double? volume,
    bool? autoPlay,
    bool? downloadOnWifi,
    bool? notificationsEnabled,
    bool? newEpisodeNotifications,
    bool? favoriteUpdatesNotifications,
    PlaybackQuality? streamingQuality,
    PlaybackQuality? downloadQuality,
    bool? darkMode,
    bool? skipIntro,
    Duration? skipIntroLength,
    bool? skipOutro,
    Duration? skipOutroLength,
  }) {
    return UserSettings(
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      volume: volume ?? this.volume,
      autoPlay: autoPlay ?? this.autoPlay,
      downloadOnWifi: downloadOnWifi ?? this.downloadOnWifi,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      newEpisodeNotifications: newEpisodeNotifications ?? this.newEpisodeNotifications,
      favoriteUpdatesNotifications: favoriteUpdatesNotifications ?? this.favoriteUpdatesNotifications,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      darkMode: darkMode ?? this.darkMode,
      skipIntro: skipIntro ?? this.skipIntro,
      skipIntroLength: skipIntroLength ?? this.skipIntroLength,
      skipOutro: skipOutro ?? this.skipOutro,
      skipOutroLength: skipOutroLength ?? this.skipOutroLength,
    );
  }
}

enum PlaybackQuality {
  @JsonValue('low')
  low,
  @JsonValue('standard')
  standard,
  @JsonValue('high')
  high,
  @JsonValue('ultra')
  ultra,
}

extension PlaybackQualityExtension on PlaybackQuality {
  String get displayName {
    switch (this) {
      case PlaybackQuality.low:
        return 'Low (64 kbps)';
      case PlaybackQuality.standard:
        return 'Standard (128 kbps)';
      case PlaybackQuality.high:
        return 'High (256 kbps)';
      case PlaybackQuality.ultra:
        return 'Ultra (320 kbps)';
    }
  }
}
