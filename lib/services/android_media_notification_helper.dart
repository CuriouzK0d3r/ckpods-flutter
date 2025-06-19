import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audio_service/audio_service.dart';

class AndroidMediaNotificationHelper {
  static final AndroidMediaNotificationHelper _instance = 
      AndroidMediaNotificationHelper._internal();
  factory AndroidMediaNotificationHelper() => _instance;
  AndroidMediaNotificationHelper._internal();

  static const String channelId = 'com.ckpods.media_playback';
  static const String channelName = 'Media Playback';
  static const String channelDescription = 'Podcast media playback controls';

  late FlutterLocalNotificationsPlugin _notificationsPlugin;
  bool _isInitialized = false;

  /// Initialize the notification helper for enhanced Android media notifications
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@drawable/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    try {
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for media playback
      await _createNotificationChannel();
      _isInitialized = true;

      debugPrint('Android media notification helper initialized');
    } catch (e) {
      debugPrint('Failed to initialize Android media notifications: $e');
    }
  }

  /// Create a dedicated notification channel for media playback
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.low, // Low importance for media notifications
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle notification tap events
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Media notification tapped: ${response.actionId}');
    
    // Handle different notification actions
    switch (response.actionId) {
      case 'play':
        AudioService.play();
        break;
      case 'pause':
        AudioService.pause();
        break;
      case 'skip_forward':
        AudioService.fastForward();
        break;
      case 'skip_backward':
        AudioService.rewind();
        break;
      case 'stop':
        AudioService.stop();
        break;
      default:
        // Open the app
        debugPrint('Opening app from media notification');
        break;
    }
  }

  /// Show enhanced media notification with custom actions
  Future<void> showMediaNotification({
    required String title,
    required String artist,
    required bool isPlaying,
    String? artworkUrl,
  }) async {
    if (!_isInitialized) return;

    try {
      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        showWhen: false,
        usesChronometer: true,
        chronometerCountDown: false,
        category: AndroidNotificationCategory.transport,
        visibility: NotificationVisibility.public,
        actions: [
          AndroidNotificationAction(
            'skip_backward',
            'Rewind 15s',
            contextual: true,
          ),
          AndroidNotificationAction(
            'play',
            'Play',
            contextual: true,
          ),
          AndroidNotificationAction(
            'pause',
            'Pause',
            contextual: true,
          ),
          AndroidNotificationAction(
            'skip_forward',
            'Skip 30s',
            contextual: true,
          ),
          AndroidNotificationAction(
            'stop',
            'Stop',
            contextual: true,
          ),
        ],
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        1001, // Use a fixed ID for media notifications
        title,
        artist,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Failed to show enhanced media notification: $e');
    }
  }

  /// Clear the media notification
  Future<void> clearMediaNotification() async {
    if (!_isInitialized) return;
    
    try {
      await _notificationsPlugin.cancel(1001);
    } catch (e) {
      debugPrint('Failed to clear media notification: $e');
    }
  }

  /// Check if notification permissions are granted (Android 13+)
  Future<bool> checkNotificationPermissions() async {
    if (!_isInitialized) return false;

    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
      return result ?? false;
    } catch (e) {
      debugPrint('Failed to check notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestNotificationPermissions() async {
    if (!_isInitialized) return false;

    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    } catch (e) {
      debugPrint('Failed to request notification permissions: $e');
      return false;
    }
  }
}
