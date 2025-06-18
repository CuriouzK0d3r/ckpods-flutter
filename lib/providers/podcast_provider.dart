import 'package:flutter/foundation.dart';
import '../models/podcast.dart';
import '../services/podcast_service.dart';
import '../services/database_service.dart';
import '../services/subscription_service.dart';

class PodcastProvider with ChangeNotifier {
  final PodcastService _podcastService = PodcastService();
  final DatabaseService _databaseService = DatabaseService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<Podcast> _podcasts = [];
  List<Podcast> _favoritePodcasts = [];
  List<Podcast> _subscribedPodcasts = [];
  List<Episode> _latestSubscriptionEpisodes = [];
  List<Podcast> _searchResults = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isSearching = false;
  bool _isRefreshingSubscriptions = false;
  String _searchQuery = '';
  String? _errorMessage;
  String? _successMessage;
  DateTime? _lastSubscriptionRefresh;

  // Getters
  List<Podcast> get podcasts => _podcasts;
  List<Podcast> get favoritePodcasts => _favoritePodcasts;
  List<Podcast> get subscribedPodcasts => _subscribedPodcasts;
  List<Episode> get latestSubscriptionEpisodes => _latestSubscriptionEpisodes;
  List<Podcast> get searchResults => _searchResults;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isRefreshingSubscriptions => _isRefreshingSubscriptions;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  DateTime? get lastSubscriptionRefresh => _lastSubscriptionRefresh;

  Future<void> initialize() async {
    await loadCategories();
    await loadPodcasts();
    await loadFavoritePodcasts();
    await loadSubscribedPodcasts();
  }

  Future<void> loadPodcasts({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPodcasts = await _podcastService.fetchPodcasts(
        category: category != 'All' ? category : null,
      );

      // Check subscription status for each podcast
      final podcastsWithStatus = <Podcast>[];
      for (final podcast in fetchedPodcasts) {
        final isSubscribed = await _databaseService.isSubscribed(podcast.id);
        final isFavorite = await _databaseService.isFavorite(podcast.id);
        podcastsWithStatus.add(podcast.copyWith(
          isSubscribed: isSubscribed,
          isFavorite: isFavorite,
        ));
      }

      _podcasts = podcastsWithStatus;

      // Save podcasts to local database
      for (final podcast in _podcasts) {
        await _databaseService.savePodcast(podcast);
      }
    } catch (e) {
      _errorMessage = 'Failed to load podcasts: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoritePodcasts() async {
    try {
      _favoritePodcasts = await _databaseService.getFavoritePodcasts();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load favorite podcasts: $e';
      notifyListeners();
    }
  }

  Future<void> loadSubscribedPodcasts() async {
    try {
      _subscribedPodcasts = await _databaseService.getSubscribedPodcasts();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load subscribed podcasts: $e';
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _podcastService.fetchCategories();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  Future<void> searchPodcasts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchQuery = query;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _podcastService.fetchPodcasts(searchQuery: query);

      // Check subscription status for each search result
      final resultsWithStatus = <Podcast>[];
      for (final podcast in results) {
        final isSubscribed = await _databaseService.isSubscribed(podcast.id);
        final isFavorite = await _databaseService.isFavorite(podcast.id);
        resultsWithStatus.add(podcast.copyWith(
          isSubscribed: isSubscribed,
          isFavorite: isFavorite,
        ));
      }

      _searchResults = resultsWithStatus;
    } catch (e) {
      _errorMessage = 'Search failed: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
      loadPodcasts(category: category);
    }
  }

  Future<void> toggleFavorite(Podcast podcast) async {
    try {
      final isFavorite = await _databaseService.isFavorite(podcast.id);

      if (isFavorite) {
        await _databaseService.removeFromFavorites(podcast.id);
      } else {
        await _databaseService.addToFavorites(podcast.id);
        await _databaseService.savePodcast(podcast);
      }

      // Update the podcast in the lists
      _updatePodcastInLists(podcast.copyWith(isFavorite: !isFavorite));
      await loadFavoritePodcasts();
    } catch (e) {
      _errorMessage = 'Failed to update favorite: $e';
      notifyListeners();
    }
  }

  Future<void> toggleSubscription(Podcast podcast) async {
    try {
      final isSubscribed = await _databaseService.isSubscribed(podcast.id);

      if (isSubscribed) {
        await _databaseService.removeFromSubscriptions(podcast.id);
      } else {
        await _databaseService.addToSubscriptions(podcast.id);
        await _databaseService.savePodcast(podcast);
      }

      // Update the podcast in the lists
      _updatePodcastInLists(podcast.copyWith(isSubscribed: !isSubscribed));
      await loadSubscribedPodcasts();

      // Show success message
      final message = isSubscribed
          ? 'Unsubscribed from ${podcast.title}'
          : 'Subscribed to ${podcast.title}';
      _successMessage = message;
      notifyListeners();

      // Clear success message after a delay
      Future.delayed(const Duration(seconds: 3), () {
        _successMessage = null;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to update subscription: $e';
      notifyListeners();
    }
  }

  void _updatePodcastInLists(Podcast updatedPodcast) {
    // Update in main podcasts list
    final podcastIndex = _podcasts.indexWhere((p) => p.id == updatedPodcast.id);
    if (podcastIndex != -1) {
      _podcasts[podcastIndex] = updatedPodcast;
    }

    // Update in search results
    final searchIndex =
        _searchResults.indexWhere((p) => p.id == updatedPodcast.id);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedPodcast;
    }

    notifyListeners();
  }

  Future<List<Episode>> fetchEpisodesByPodcastId(String podcastId) async {
    try {
      return await _podcastService.fetchEpisodesByPodcastId(podcastId);
    } catch (e) {
      _errorMessage = 'Failed to fetch episodes: $e';
      notifyListeners();
      return [];
    }
  }

  Future<Podcast?> fetchPodcastById(String id) async {
    try {
      return await _podcastService.fetchPodcastById(id);
    } catch (e) {
      _errorMessage = 'Failed to fetch podcast: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> ratePodcast(String podcastId, double rating) async {
    try {
      await _podcastService.ratePodcast(podcastId, rating);
      // Optionally refresh the podcast data
    } catch (e) {
      _errorMessage = 'Failed to rate podcast: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  Future<void> refreshPodcasts() async {
    await loadPodcasts(
        category: _selectedCategory != 'All' ? _selectedCategory : null);
  }

  Future<bool> isPodcastSubscribed(String podcastId) async {
    return await _databaseService.isSubscribed(podcastId);
  }

  Future<bool> isPodcastFavorite(String podcastId) async {
    return await _databaseService.isFavorite(podcastId);
  }

  // Enhanced Subscription Management Methods

  /// Refresh all subscriptions and get new episodes
  Future<void> refreshAllSubscriptions() async {
    _isRefreshingSubscriptions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final refreshResult = await _subscriptionService.refreshSubscriptions();

      if (refreshResult.success) {
        _lastSubscriptionRefresh = refreshResult.refreshTime;
        _latestSubscriptionEpisodes = refreshResult.allNewEpisodes;

        // Update subscribed podcasts list
        await loadSubscribedPodcasts();

        if (refreshResult.totalNewEpisodes > 0) {
          _successMessage =
              'Found ${refreshResult.totalNewEpisodes} new episodes!';
        } else {
          _successMessage = 'Subscriptions refreshed - no new episodes';
        }
      } else {
        _errorMessage =
            refreshResult.error ?? 'Failed to refresh subscriptions';
      }
    } catch (e) {
      _errorMessage = 'Failed to refresh subscriptions: $e';
    } finally {
      _isRefreshingSubscriptions = false;
      notifyListeners();

      // Clear success message after delay
      if (_successMessage != null) {
        Future.delayed(const Duration(seconds: 4), () {
          _successMessage = null;
          notifyListeners();
        });
      }
    }
  }

  /// Load latest episodes from subscriptions
  Future<void> loadLatestSubscriptionEpisodes() async {
    try {
      _latestSubscriptionEpisodes =
          await _subscriptionService.getLatestSubscriptionEpisodes();
      _lastSubscriptionRefresh =
          await _subscriptionService.getLastRefreshTime();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load latest episodes: $e';
      notifyListeners();
    }
  }

  /// Check for new episodes without refreshing
  Future<Map<String, List<Episode>>> checkForNewEpisodes() async {
    try {
      return await _subscriptionService.checkForNewEpisodes();
    } catch (e) {
      _errorMessage = 'Failed to check for new episodes: $e';
      notifyListeners();
      return {};
    }
  }

  /// Get subscription statistics
  Future<SubscriptionStats?> getSubscriptionStats() async {
    try {
      return await _subscriptionService.getSubscriptionStats();
    } catch (e) {
      _errorMessage = 'Failed to get subscription stats: $e';
      notifyListeners();
      return null;
    }
  }

  /// Auto refresh settings
  Future<bool> isAutoRefreshEnabled() async {
    return await _subscriptionService.isAutoRefreshEnabled();
  }

  Future<void> setAutoRefreshEnabled(bool enabled) async {
    await _subscriptionService.setAutoRefreshEnabled(enabled);
    notifyListeners();
  }

  /// New episode notifications settings
  Future<bool> areNewEpisodeNotificationsEnabled() async {
    return await _subscriptionService.areNewEpisodeNotificationsEnabled();
  }

  Future<void> setNewEpisodeNotificationsEnabled(bool enabled) async {
    await _subscriptionService.setNewEpisodeNotificationsEnabled(enabled);
    notifyListeners();
  }

  /// Enhanced subscription toggle with better UX
  Future<void> toggleSubscriptionEnhanced(Podcast podcast) async {
    try {
      final wasSubscribed = await _subscriptionService.isSubscribed(podcast.id);

      if (wasSubscribed) {
        final success =
            await _subscriptionService.unsubscribeFromPodcast(podcast.id);
        if (success) {
          _successMessage = 'Unsubscribed from ${podcast.title}';
        } else {
          _errorMessage = 'Failed to unsubscribe';
        }
      } else {
        final success =
            await _subscriptionService.subscribeToPodcast(podcast.id);
        if (success) {
          _successMessage = 'Subscribed to ${podcast.title}';
          // Save podcast details to local database
          await _databaseService.savePodcast(podcast);
        } else {
          _errorMessage = 'Failed to subscribe';
        }
      }

      // Update the podcast in all lists
      _updatePodcastInLists(podcast.copyWith(isSubscribed: !wasSubscribed));
      await loadSubscribedPodcasts();

      notifyListeners();

      // Clear success message after delay
      if (_successMessage != null) {
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to update subscription: $e';
      notifyListeners();
    }
  }

  /// Export subscriptions
  Future<String?> exportSubscriptions() async {
    try {
      return await _subscriptionService.exportSubscriptions();
    } catch (e) {
      _errorMessage = 'Failed to export subscriptions: $e';
      notifyListeners();
      return null;
    }
  }

  /// Import subscriptions
  Future<bool> importSubscriptions(String jsonData) async {
    try {
      final result = await _subscriptionService.importSubscriptions(jsonData);

      if (result.success) {
        _successMessage = 'Imported ${result.successCount} subscriptions';
        await loadSubscribedPodcasts();
      } else {
        _errorMessage = result.error ?? 'Failed to import subscriptions';
      }

      notifyListeners();

      if (result.success && _successMessage != null) {
        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });
      }

      return result.success;
    } catch (e) {
      _errorMessage = 'Failed to import subscriptions: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if auto refresh should happen
  Future<bool> shouldAutoRefresh() async {
    return await _subscriptionService.shouldAutoRefresh();
  }

  /// Perform auto refresh if needed
  Future<void> autoRefreshIfNeeded() async {
    if (await shouldAutoRefresh()) {
      await refreshAllSubscriptions();
    }
  }
}
