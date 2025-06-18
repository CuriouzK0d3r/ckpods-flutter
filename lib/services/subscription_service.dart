import 'package:shared_preferences/shared_preferences.dart';
import '../models/podcast.dart';
import '../services/podcast_service.dart';
import '../services/database_service.dart';
import 'dart:convert';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final PodcastService _podcastService = PodcastService();
  final DatabaseService _databaseService = DatabaseService();

  static const String _lastRefreshKey = 'subscription_last_refresh';
  static const String _autoRefreshEnabledKey = 'auto_refresh_enabled';
  static const String _newEpisodeNotificationsKey = 'new_episode_notifications';
  static const String _subscriptionLastCheckKey = 'subscription_last_check_';

  /// Subscribe to a podcast
  Future<bool> subscribeToPodcast(String podcastId) async {
    try {
      await _databaseService.addToSubscriptions(podcastId);

      // Set initial last check date to now to avoid flooding with old episodes
      await _setLastCheckDate(podcastId, DateTime.now());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Unsubscribe from a podcast
  Future<bool> unsubscribeFromPodcast(String podcastId) async {
    try {
      await _databaseService.removeFromSubscriptions(podcastId);

      // Clean up last check date
      await _removeLastCheckDate(podcastId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if subscribed to a podcast
  Future<bool> isSubscribed(String podcastId) async {
    return await _databaseService.isSubscribed(podcastId);
  }

  /// Get all subscribed podcasts
  Future<List<Podcast>> getSubscribedPodcasts() async {
    return await _databaseService.getSubscribedPodcasts();
  }

  /// Get subscribed podcast IDs
  Future<List<String>> getSubscribedPodcastIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('subscriptions') ?? [];
  }

  /// Refresh all subscriptions and check for new episodes
  Future<SubscriptionRefreshResult> refreshSubscriptions() async {
    try {
      final subscribedIds = await getSubscribedPodcastIds();
      final lastCheckDates = await _getLastCheckDates(subscribedIds);

      final newEpisodesMap = await _podcastService
          .refreshSubscriptionsAndGetNewEpisodes(lastCheckDates);

      // Update last check dates
      final now = DateTime.now();
      for (final podcastId in subscribedIds) {
        await _setLastCheckDate(podcastId, now);
      }

      // Update last refresh time
      await _setLastRefreshTime(now);

      // Calculate totals
      int totalNewEpisodes = 0;
      final List<Episode> allNewEpisodes = [];

      for (final episodes in newEpisodesMap.values) {
        totalNewEpisodes += episodes.length;
        allNewEpisodes.addAll(episodes);
      }

      // Sort all new episodes by publish date
      allNewEpisodes.sort((a, b) => b.publishDate.compareTo(a.publishDate));

      return SubscriptionRefreshResult(
        success: true,
        totalNewEpisodes: totalNewEpisodes,
        newEpisodesByPodcast: newEpisodesMap,
        allNewEpisodes: allNewEpisodes,
        refreshTime: now,
      );
    } catch (e) {
      return SubscriptionRefreshResult(
        success: false,
        error: e.toString(),
        totalNewEpisodes: 0,
        newEpisodesByPodcast: {},
        allNewEpisodes: [],
        refreshTime: DateTime.now(),
      );
    }
  }

  /// Get latest episodes from all subscriptions
  Future<List<Episode>> getLatestSubscriptionEpisodes({int limit = 20}) async {
    try {
      final subscribedIds = await getSubscribedPodcastIds();
      final episodes = await _podcastService
          .fetchLatestEpisodesForSubscriptions(subscribedIds);

      return episodes.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check for new episodes since last check (without updating check dates)
  Future<Map<String, List<Episode>>> checkForNewEpisodes() async {
    try {
      final subscribedIds = await getSubscribedPodcastIds();
      final lastCheckDates = await _getLastCheckDates(subscribedIds);

      return await _podcastService
          .refreshSubscriptionsAndGetNewEpisodes(lastCheckDates);
    } catch (e) {
      return {};
    }
  }

  /// Get subscription statistics
  Future<SubscriptionStats> getSubscriptionStats() async {
    try {
      final subscribedIds = await getSubscribedPodcastIds();
      final stats = await _podcastService.getSubscriptionStats(subscribedIds);
      final lastRefresh = await getLastRefreshTime();

      return SubscriptionStats(
        totalSubscriptions: stats['totalSubscriptions'] ?? 0,
        totalEpisodes: stats['totalEpisodes'] ?? 0,
        totalListenTimeMinutes: stats['totalListenTimeMinutes'] ?? 0,
        totalListenTimeHours: stats['totalListenTimeHours'] ?? 0,
        newEpisodesThisWeek: stats['newEpisodesThisWeek'] ?? 0,
        lastRefreshTime: lastRefresh,
      );
    } catch (e) {
      return SubscriptionStats(
        totalSubscriptions: 0,
        totalEpisodes: 0,
        totalListenTimeMinutes: 0,
        totalListenTimeHours: 0,
        newEpisodesThisWeek: 0,
        lastRefreshTime: null,
      );
    }
  }

  /// Auto-refresh settings
  Future<bool> isAutoRefreshEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoRefreshEnabledKey) ?? true;
  }

  Future<void> setAutoRefreshEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoRefreshEnabledKey, enabled);
  }

  /// New episode notifications settings
  Future<bool> areNewEpisodeNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_newEpisodeNotificationsKey) ?? true;
  }

  Future<void> setNewEpisodeNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newEpisodeNotificationsKey, enabled);
  }

  /// Get last refresh time
  Future<DateTime?> getLastRefreshTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastRefreshKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Set last refresh time
  Future<void> _setLastRefreshTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastRefreshKey, time.millisecondsSinceEpoch);
  }

  /// Get last check dates for all subscribed podcasts
  Future<Map<String, DateTime>> _getLastCheckDates(
      List<String> podcastIds) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, DateTime> checkDates = {};

    for (final podcastId in podcastIds) {
      final timestamp = prefs.getInt('$_subscriptionLastCheckKey$podcastId');
      if (timestamp != null) {
        checkDates[podcastId] = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else {
        // If no last check date, use a week ago to avoid flooding with old episodes
        checkDates[podcastId] =
            DateTime.now().subtract(const Duration(days: 7));
      }
    }

    return checkDates;
  }

  /// Set last check date for a specific podcast
  Future<void> _setLastCheckDate(String podcastId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        '$_subscriptionLastCheckKey$podcastId', date.millisecondsSinceEpoch);
  }

  /// Remove last check date for a specific podcast
  Future<void> _removeLastCheckDate(String podcastId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_subscriptionLastCheckKey$podcastId');
  }

  /// Check if it's time for auto-refresh (e.g., every 6 hours)
  Future<bool> shouldAutoRefresh() async {
    if (!await isAutoRefreshEnabled()) return false;

    final lastRefresh = await getLastRefreshTime();
    if (lastRefresh == null) return true;

    final sixHoursAgo = DateTime.now().subtract(const Duration(hours: 6));
    return lastRefresh.isBefore(sixHoursAgo);
  }

  /// Export subscriptions (for backup/sharing)
  Future<String> exportSubscriptions() async {
    try {
      final subscriptions = await _databaseService.getSubscribedPodcasts();

      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'subscriptions': subscriptions
            .map((podcast) => {
                  'id': podcast.id,
                  'title': podcast.title,
                  'publisher': podcast.publisher,
                  'artworkUrl': podcast.artworkUrl,
                })
            .toList(),
      };

      return jsonEncode(exportData);
    } catch (e) {
      throw Exception('Failed to export subscriptions: $e');
    }
  }

  /// Import subscriptions (from backup/sharing)
  Future<ImportResult> importSubscriptions(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final subscriptions = data['subscriptions'] as List<dynamic>;

      int successCount = 0;
      int failureCount = 0;
      final List<String> importedTitles = [];

      for (final sub in subscriptions) {
        try {
          final podcastId = sub['id'] as String;
          await subscribeToPodcast(podcastId);
          successCount++;
          importedTitles.add(sub['title'] as String);
        } catch (e) {
          failureCount++;
        }
      }

      return ImportResult(
        success: true,
        successCount: successCount,
        failureCount: failureCount,
        importedTitles: importedTitles,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: e.toString(),
        successCount: 0,
        failureCount: 0,
        importedTitles: [],
      );
    }
  }
}

/// Result of subscription refresh operation
class SubscriptionRefreshResult {
  final bool success;
  final String? error;
  final int totalNewEpisodes;
  final Map<String, List<Episode>> newEpisodesByPodcast;
  final List<Episode> allNewEpisodes;
  final DateTime refreshTime;

  SubscriptionRefreshResult({
    required this.success,
    this.error,
    required this.totalNewEpisodes,
    required this.newEpisodesByPodcast,
    required this.allNewEpisodes,
    required this.refreshTime,
  });
}

/// Subscription statistics
class SubscriptionStats {
  final int totalSubscriptions;
  final int totalEpisodes;
  final int totalListenTimeMinutes;
  final int totalListenTimeHours;
  final int newEpisodesThisWeek;
  final DateTime? lastRefreshTime;

  SubscriptionStats({
    required this.totalSubscriptions,
    required this.totalEpisodes,
    required this.totalListenTimeMinutes,
    required this.totalListenTimeHours,
    required this.newEpisodesThisWeek,
    this.lastRefreshTime,
  });
}

/// Result of import operation
class ImportResult {
  final bool success;
  final String? error;
  final int successCount;
  final int failureCount;
  final List<String> importedTitles;

  ImportResult({
    required this.success,
    this.error,
    required this.successCount,
    required this.failureCount,
    required this.importedTitles,
  });
}
