import 'package:flutter/foundation.dart';
import '../models/podcast.dart';
import '../services/podcast_service.dart';
import '../services/database_service.dart';

class PodcastProvider with ChangeNotifier {
  final PodcastService _podcastService = PodcastService();
  final DatabaseService _databaseService = DatabaseService();

  List<Podcast> _podcasts = [];
  List<Podcast> _favoritePodcasts = [];
  List<Podcast> _searchResults = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';
  String? _errorMessage;

  // Getters
  List<Podcast> get podcasts => _podcasts;
  List<Podcast> get favoritePodcasts => _favoritePodcasts;
  List<Podcast> get searchResults => _searchResults;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    await loadCategories();
    await loadPodcasts();
    await loadFavoritePodcasts();
  }

  Future<void> loadPodcasts({String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedPodcasts = await _podcastService.fetchPodcasts(
        category: category != 'All' ? category : null,
      );
      
      _podcasts = fetchedPodcasts;
      
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
      _searchResults = results;
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

  void _updatePodcastInLists(Podcast updatedPodcast) {
    // Update in main podcasts list
    final podcastIndex = _podcasts.indexWhere((p) => p.id == updatedPodcast.id);
    if (podcastIndex != -1) {
      _podcasts[podcastIndex] = updatedPodcast;
    }

    // Update in search results
    final searchIndex = _searchResults.indexWhere((p) => p.id == updatedPodcast.id);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedPodcast;
    }

    notifyListeners();
  }

  Future<Podcast?> getPodcastById(String id) async {
    try {
      return await _podcastService.fetchPodcastById(id);
    } catch (e) {
      _errorMessage = 'Failed to load podcast details: $e';
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

  Future<void> refreshPodcasts() async {
    await loadPodcasts(category: _selectedCategory != 'All' ? _selectedCategory : null);
  }
}
