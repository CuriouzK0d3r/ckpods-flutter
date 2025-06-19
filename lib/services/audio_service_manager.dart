import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'audio_player_service.dart';

class AudioServiceManager {
  static AudioServiceManager? _instance;
  static AudioServiceManager get instance => _instance ??= AudioServiceManager._();
  AudioServiceManager._();

  late AudioPlayerService _audioPlayerService;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  AudioPlayerService get audioPlayerService => _audioPlayerService;

  /// Initialize the audio service for background playback and lockscreen controls
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    try {
      _audioPlayerService = await AudioService.init(
        builder: () => AudioPlayerService(),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.ckpods.audio',
          androidNotificationChannelName: 'CKPods Audio Playback',
          androidNotificationOngoing: true,
          androidShowNotificationBadge: true,
          androidStopForegroundOnPause: false,
          preloadArtwork: true,
          androidNotificationChannelDescription: 'Podcast audio playback and media controls',
          androidNotificationIcon: 'drawable/ic_launcher',
          fastForwardInterval: const Duration(seconds: 30),
          rewindInterval: const Duration(seconds: 15),
          // Enhanced Android-specific settings
          androidNotificationClickStartsActivity: true,
          artDownscaleWidth: 256,
          artDownscaleHeight: 256,
        ),
      );

      await _audioPlayerService.initialize();
      _isInitialized = true;
      
      debugPrint('Audio service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize audio service: $e');
      // Fallback to regular audio player service without background capabilities
      _audioPlayerService = AudioPlayerService();
      await _audioPlayerService.initialize();
      _isInitialized = true;
    }
  }

  /// Get the current audio handler
  AudioPlayerService get audioHandler => _audioPlayerService;

  /// Dispose the audio service
  void dispose() {
    if (_isInitialized) {
      _audioPlayerService.dispose();
      _isInitialized = false;
    }
  }
}
