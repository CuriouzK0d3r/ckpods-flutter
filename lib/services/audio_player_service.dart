import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import '../models/podcast.dart';

class AudioPlayerService extends BaseAudioHandler {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  Episode? _currentEpisode;
  
  // Stream getters
  Stream<Duration> get positionStream => _audioPlayer.positionStream;
  Stream<Duration?> get durationStream => _audioPlayer.durationStream;
  Stream<PlayerState> get playerStateStream => _audioPlayer.playerStateStream;
  Stream<double> get speedStream => _audioPlayer.speedStream;
  
  // Getters
  Episode? get currentEpisode => _currentEpisode;
  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;
  bool get isPlaying => _audioPlayer.playing;
  double get speed => _audioPlayer.speed;

  Future<void> initialize() async {
    // Initialize audio session for background playback
    try {
      // Set up audio session for background playback
      await _audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: []),
      );
      
      // Listen to player state changes and update playback state
      _audioPlayer.playerStateStream.listen((playerState) {
        final isPlaying = playerState.playing;
        final processingState = _mapProcessingState(playerState.processingState);
        
        playbackState.add(PlaybackState(
          controls: [
            MediaControl.rewind,
            if (isPlaying) MediaControl.pause else MediaControl.play,
            MediaControl.fastForward,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.rewind,
            MediaAction.fastForward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: processingState,
          playing: isPlaying,
          updatePosition: _audioPlayer.position,
          bufferedPosition: _audioPlayer.bufferedPosition,
          speed: _audioPlayer.speed,
          queueIndex: 0,
        ));
      });

      // Listen to position updates
      _audioPlayer.positionStream.listen((position) {
        playbackState.add(playbackState.value.copyWith(
          updatePosition: position,
          bufferedPosition: _audioPlayer.bufferedPosition,
        ));
      });

    } catch (e) {
      debugPrint('AudioPlayerService initialization error: $e');
    }
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      _currentEpisode = episode;
      
      // Create a detailed media item for rich lockscreen display
      final mediaItem = MediaItem(
        id: episode.id,
        album: 'Podcast Episode',
        title: episode.title,
        artist: 'CKPods',
        duration: episode.duration,
        artUri: episode.thumbnailUrl != null ? Uri.parse(episode.thumbnailUrl!) : null,
        displayTitle: episode.title,
        displaySubtitle: 'Podcast Episode',
        displayDescription: episode.description,
        extras: {
          'episodeId': episode.id,
          'podcastId': episode.podcastId,
          'audioUrl': episode.audioUrl,
        },
      );

      // Set the media item for the notification and lockscreen
      this.mediaItem.add(mediaItem);

      // Load and play the audio
      await _audioPlayer.setUrl(episode.audioUrl);
      
      // If there's a saved position, seek to it
      if (episode.playbackPosition != null) {
        await _audioPlayer.seek(episode.playbackPosition!);
      }
      
      await _audioPlayer.play();
    } catch (e) {
      throw Exception('Failed to play episode: $e');
    }
  }

  @override
  Future<void> play() async {
    await _audioPlayer.play();
  }

  @override
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentEpisode = null;
    mediaItem.add(null);
  }

  @override
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  @override
  Future<void> fastForward() async {
    await skipForward30();
  }

  @override
  Future<void> rewind() async {
    await skipBackward15();
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> skipForward(Duration duration) async {
    final newPosition = _audioPlayer.position + duration;
    final maxPosition = _audioPlayer.duration ?? Duration.zero;
    await _audioPlayer.seek(newPosition > maxPosition ? maxPosition : newPosition);
  }

  Future<void> skipBackward(Duration duration) async {
    final newPosition = _audioPlayer.position - duration;
    await _audioPlayer.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  // Enhanced playback methods
  
  Future<void> playNext() async {
    // This would be implemented with a queue system
    // For now, it's a placeholder
  }

  Future<void> playPrevious() async {
    // This would be implemented with a queue system
    // For now, it's a placeholder
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekToPercentage(double percentage) async {
    final duration = _audioPlayer.duration;
    if (duration != null) {
      final newPosition = Duration(
        milliseconds: (duration.inMilliseconds * percentage).round(),
      );
      await seek(newPosition);
    }
  }

  Future<void> skipForward30() async {
    await skipForward(const Duration(seconds: 30));
  }

  Future<void> skipBackward15() async {
    await skipBackward(const Duration(seconds: 15));
  }

  Future<void> replay10() async {
    await skipBackward(const Duration(seconds: 10));
  }

  // Get formatted position and duration strings
  String get positionString {
    return _formatDuration(_audioPlayer.position);
  }

  String get durationString {
    final duration = _audioPlayer.duration;
    return duration != null ? _formatDuration(duration) : '--:--';
  }

  String get remainingTimeString {
    final duration = _audioPlayer.duration;
    if (duration != null) {
      final remaining = duration - _audioPlayer.position;
      return '-${_formatDuration(remaining)}';
    }
    return '--:--';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Check if episode is currently playing
  bool isEpisodePlaying(String episodeId) {
    return _currentEpisode?.id == episodeId && _audioPlayer.playing;
  }

  // Check if episode is currently loaded (but may be paused)
  bool isEpisodeLoaded(String episodeId) {
    return _currentEpisode?.id == episodeId;
  }

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
