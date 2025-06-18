import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/podcast.dart';
import '../services/subscription_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions for Android 13+
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    // You can navigate to specific screens based on the payload
    final payload = notificationResponse.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
      print('Notification tapped with payload: $payload');
    }
  }

  Future<void> showNewEpisodeNotification({
    required String podcastTitle,
    required String episodeTitle,
    required String podcastId,
    required String episodeId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'new_episodes',
      'New Episodes',
      channelDescription: 'Notifications for new podcast episodes',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      episodeId.hashCode,
      'New Episode Available',
      '$episodeTitle from $podcastTitle',
      platformChannelSpecifics,
      payload: 'episode:$episodeId:$podcastId',
    );
  }

  Future<void> showDownloadCompleteNotification({
    required String episodeTitle,
    required String episodeId,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'downloads',
      'Downloads',
      channelDescription: 'Notifications for completed downloads',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      episodeId.hashCode + 1000, // Offset to avoid ID conflicts
      'Download Complete',
      '$episodeTitle is now available offline',
      platformChannelSpecifics,
      payload: 'download:$episodeId',
    );
  }

  Future<void> showPlaybackNotification({
    required String episodeTitle,
    required String podcastTitle,
    required bool isPlaying,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'playback',
      'Playback Controls',
      channelDescription: 'Media playback controls',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      icon: '@mipmap/ic_launcher',
      styleInformation: MediaStyleInformation(),
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Fixed ID for playback notification
      episodeTitle,
      podcastTitle,
      platformChannelSpecifics,
      payload: 'playback',
    );
  }

  Future<void> cancelPlaybackNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> scheduleNewEpisodeCheck() async {
    // Schedule a periodic check for new episodes
    // This would typically be handled by a background service
    // For now, we'll implement a simple notification scheduling

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'updates',
      'Updates',
      channelDescription: 'Podcast update reminders',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Schedule a notification for later (for demo purposes)
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      'Check for New Episodes',
      'Tap to refresh your podcast library',
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 24)),
      platformChannelSpecifics,
      payload: 'update_check',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // iOS handles permissions differently
  }

  // Subscription-specific notification methods

  /// Check for new episodes and send notifications
  Future<void> checkAndNotifyNewEpisodes() async {
    final subscriptionService = SubscriptionService();

    if (!await subscriptionService.areNewEpisodeNotificationsEnabled()) {
      return;
    }

    try {
      final newEpisodesMap = await subscriptionService.checkForNewEpisodes();

      if (newEpisodesMap.isEmpty) return;

      int totalNewEpisodes = 0;
      for (final episodes in newEpisodesMap.values) {
        totalNewEpisodes += episodes.length;
      }

      // Show summary notification if there are multiple new episodes
      if (totalNewEpisodes > 1) {
        await _showSummaryNotification(totalNewEpisodes, newEpisodesMap.length);
      }

      // Show individual notifications for each podcast with new episodes
      int notificationId = 1000; // Start from 1000 to avoid conflicts
      for (final entry in newEpisodesMap.entries) {
        final episodes = entry.value;

        if (episodes.isNotEmpty) {
          await _showNewEpisodeNotification(
            notificationId++,
            episodes,
          );
        }
      }
    } catch (e) {
      // Silently fail - don't interrupt user experience
    }
  }

  Future<void> _showSummaryNotification(
      int totalEpisodes, int podcastCount) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'podcast_episodes',
        'New Podcast Episodes',
        channelDescription: 'Notifications for new podcast episodes',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      0, // Use ID 0 for summary notifications
      'New Podcast Episodes',
      '$totalEpisodes new episodes from $podcastCount podcasts',
      notificationDetails,
      payload: 'summary',
    );
  }

  Future<void> _showNewEpisodeNotification(
    int notificationId,
    List<Episode> episodes,
  ) async {
    if (episodes.isEmpty) return;

    final episode = episodes.first; // Show notification for the latest episode
    const podcastTitle =
        'Podcast'; // In a real app, you'd get this from the podcast data

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'podcast_episodes',
        'New Podcast Episodes',
        channelDescription: 'Notifications for new podcast episodes',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    String title;
    String body;

    if (episodes.length == 1) {
      title = podcastTitle;
      body = 'New episode: ${episode.title}';
    } else {
      title = podcastTitle;
      body = '${episodes.length} new episodes, latest: ${episode.title}';
    }

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: 'episode:${episode.id}',
    );
  }

  /// Show notification when subscribed to a new podcast
  Future<void> showSubscriptionNotification(String podcastTitle) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'podcast_subscriptions',
        'Podcast Subscriptions',
        channelDescription: 'Notifications for podcast subscriptions',
        importance: Importance.low,
        priority: Priority.low,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      999, // Special ID for subscription notifications
      'Subscribed',
      'You\'re now subscribed to $podcastTitle',
      notificationDetails,
      payload: 'subscription',
    );
  }
}
