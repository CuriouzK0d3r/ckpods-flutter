import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:ckpods_flutter/models/podcast.dart';
import 'package:ckpods_flutter/services/podcast_service.dart';

class PodcastProvider extends ChangeNotifier {
  final PodcastService _podcastService = PodcastService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Podcast> _searchResults = [];
  List<Podcast> _subscriptions = [];
  Episode? _currentEpisode;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  List<Podcast> get searchResults => _searchResults;
  List<Podcast> get subscriptions => _subscriptions;
  Episode? get currentEpisode => _currentEpisode;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isLoading => _isLoading;
  AudioPlayer get audioPlayer => _audioPlayer;

  PodcastProvider() {
    _initializeAudioPlayer();
    _loadSubscriptions();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.playbackEventStream.listen((event) {
      _totalDuration = event.duration ?? Duration.zero;
      _currentPosition = event.updatePosition;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });
  }

  Future<void> searchPodcasts(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _podcastService.searchPodcasts(query);
    } catch (e) {
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<Episode>> getEpisodes(Podcast podcast) async {
    try {
      return await _podcastService.getEpisodes(podcast);
    } catch (e) {
      return [];
    }
  }

  bool isSubscribed(Podcast podcast) {
    return _subscriptions.any((p) => p.id == podcast.id);
  }

  Future<void> toggleSubscription(Podcast podcast) async {
    if (isSubscribed(podcast)) {
      _subscriptions.removeWhere((p) => p.id == podcast.id);
    } else {
      _subscriptions.add(podcast);
    }
    await _saveSubscriptions();
    notifyListeners();
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      _currentEpisode = episode;
      await _audioPlayer.setUrl(episode.audioUrl);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      print('Error playing episode: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> skipForward() async {
    final newPosition = _currentPosition + const Duration(seconds: 30);
    await seek(newPosition);
  }

  Future<void> skipBackward() async {
    final newPosition = _currentPosition - const Duration(seconds: 15);
    await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
  }

  Future<void> _loadSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = prefs.getStringList('subscriptions') ?? [];
      _subscriptions = subscriptionsJson
          .map((json) => Podcast.fromJson(jsonDecode(json)))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading subscriptions: $e');
    }
  }

  Future<void> _saveSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionsJson = _subscriptions
          .map((podcast) => jsonEncode({
                'collectionId': podcast.id,
                'collectionName': podcast.name,
                'artistName': podcast.artist,
                'artworkUrl600': podcast.imageUrl,
                'feedUrl': podcast.feedUrl,
                'description': podcast.description,
              }))
          .toList();
      await prefs.setStringList('subscriptions', subscriptionsJson);
    } catch (e) {
      print('Error saving subscriptions: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
