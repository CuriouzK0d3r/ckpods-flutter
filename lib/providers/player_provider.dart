import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/podcast.dart';
import '../services/audio_player_service.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();

  Episode? _currentEpisode;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  double _volume = 1.0;
  String? _errorMessage;

  // Getters
  Episode? get currentEpisode => _currentEpisode;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  double get volume => _volume;
  String? get errorMessage => _errorMessage;
  
  double get progress => _duration.inMilliseconds > 0 
      ? _position.inMilliseconds / _duration.inMilliseconds 
      : 0.0;

  PlayerProvider() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to position changes
    _audioService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
      
      // Save playback position every 30 seconds
      if (_currentEpisode != null && 
          position.inSeconds % 30 == 0 && 
          position.inSeconds > 0) {
        _savePlaybackPosition();
      }
    });

    // Listen to duration changes
    _audioService.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    // Listen to player state changes
    _audioService.playerStateStream.listen((playerState) {
      _isPlaying = playerState.playing;
      _isLoading = playerState.processingState == ProcessingState.loading ||
                   playerState.processingState == ProcessingState.buffering;
      notifyListeners();

      // Update notification when playback state changes
      if (_currentEpisode != null) {
        _updatePlaybackNotification();
      }
    });

    // Listen to speed changes
    _audioService.speedStream.listen((speed) {
      _speed = speed;
      notifyListeners();
    });
  }

  Future<void> playEpisode(Episode episode) async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      await _audioService.playEpisode(episode);
      _currentEpisode = episode;
      
      // Save episode to database
      await _databaseService.saveEpisode(episode);
      
      // Show playback notification
      await _updatePlaybackNotification();
      
    } catch (e) {
      _errorMessage = 'Failed to play episode: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    try {
      await _audioService.play();
    } catch (e) {
      _errorMessage = 'Failed to play: $e';
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _audioService.pause();
      await _savePlaybackPosition();
    } catch (e) {
      _errorMessage = 'Failed to pause: $e';
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _audioService.stop();
      await _savePlaybackPosition();
      await _notificationService.cancelPlaybackNotification();
      _currentEpisode = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to stop: $e';
      notifyListeners();
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
      _position = position;
      notifyListeners();
      await _savePlaybackPosition();
    } catch (e) {
      _errorMessage = 'Failed to seek: $e';
      notifyListeners();
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _audioService.setSpeed(speed);
      _speed = speed;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set speed: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioService.setVolume(volume);
      _volume = volume;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set volume: $e';
      notifyListeners();
    }
  }

  Future<void> skipForward({Duration duration = const Duration(seconds: 30)}) async {
    try {
      await _audioService.skipForward(duration);
    } catch (e) {
      _errorMessage = 'Failed to skip forward: $e';
      notifyListeners();
    }
  }

  Future<void> skipBackward({Duration duration = const Duration(seconds: 15)}) async {
    try {
      await _audioService.skipBackward(duration);
    } catch (e) {
      _errorMessage = 'Failed to skip backward: $e';
      notifyListeners();
    }
  }

  Future<void> _savePlaybackPosition() async {
    if (_currentEpisode != null) {
      try {
        await _databaseService.updateEpisodePlaybackPosition(
          _currentEpisode!.id,
          _position,
        );
        
        // Mark as played if near the end (95% or more)
        if (_duration.inMilliseconds > 0 && 
            _position.inMilliseconds / _duration.inMilliseconds >= 0.95) {
          await _databaseService.markEpisodeAsPlayed(_currentEpisode!.id);
        }
      } catch (e) {
        // Silent fail for position saving
        debugPrint('Failed to save playback position: $e');
      }
    }
  }

  Future<void> _updatePlaybackNotification() async {
    if (_currentEpisode != null) {
      try {
        await _notificationService.showPlaybackNotification(
          episodeTitle: _currentEpisode!.title,
          podcastTitle: 'Podcast Episode', // You might want to pass podcast title
          isPlaying: _isPlaying,
        );
      } catch (e) {
        debugPrint('Failed to update notification: $e');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Enhanced player methods
  
  Future<void> togglePlayPause() async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.togglePlayPause();
    } catch (e) {
      _errorMessage = 'Failed to toggle playback: $e';
      notifyListeners();
    }
  }

  Future<void> seekToPercentage(double percentage) async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.seekToPercentage(percentage);
    } catch (e) {
      _errorMessage = 'Failed to seek: $e';
      notifyListeners();
    }
  }

  Future<void> seekToPosition(Duration position) async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.seek(position);
    } catch (e) {
      _errorMessage = 'Failed to seek: $e';
      notifyListeners();
    }
  }

  Future<void> skipForward30() async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.skipForward30();
    } catch (e) {
      _errorMessage = 'Failed to skip forward: $e';
      notifyListeners();
    }
  }

  Future<void> skipBackward15() async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.skipBackward15();
    } catch (e) {
      _errorMessage = 'Failed to skip backward: $e';
      notifyListeners();
    }
  }

  Future<void> replay10() async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.replay10();
    } catch (e) {
      _errorMessage = 'Failed to replay: $e';
      notifyListeners();
    }
  }

  Future<void> changeSpeed(double speed) async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.setSpeed(speed);
      _speed = speed;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to change speed: $e';
      notifyListeners();
    }
  }

  Future<void> changeVolume(double volume) async {
    if (_currentEpisode == null) return;
    
    try {
      await _audioService.setVolume(volume);
      _volume = volume;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to change volume: $e';
      notifyListeners();
    }
  }

  // Utility methods
  
  bool isEpisodePlaying(String episodeId) {
    return _audioService.isEpisodePlaying(episodeId);
  }

  bool isEpisodeLoaded(String episodeId) {
    return _audioService.isEpisodeLoaded(episodeId);
  }

  String get positionString => _audioService.positionString;
  String get durationString => _audioService.durationString;
  String get remainingTimeString => _audioService.remainingTimeString;

  double get progressPercentage => progress * 100;

  String get formattedProgress {
    return '$positionString / $durationString';
  }

  bool get hasEpisode => _currentEpisode != null;

  String? get currentEpisodeTitle => _currentEpisode?.title;
  String? get currentPodcastTitle => _currentEpisode?.podcastId; // Would need podcast title lookup

  // Episode completion check
  bool get isNearEnd {
    return _duration.inSeconds > 0 && 
           (_duration.inSeconds - _position.inSeconds) < 30;
  }

  bool get isCompleted {
    return _duration.inSeconds > 0 && 
           _position.inSeconds >= (_duration.inSeconds * 0.95); // 95% completion
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
