import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
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
    // Set up audio session
    await _audioPlayer.setAudioSource(
      ConcatenatingAudioSource(children: []),
    );
  }

  Future<void> playEpisode(Episode episode) async {
    try {
      _currentEpisode = episode;
      
      // Set the media item for the notification
      mediaItem.add(MediaItem(
        id: episode.id,
        album: episode.podcastId,
        title: episode.title,
        artist: 'Podcast Episode',
        duration: episode.duration,
        artUri: episode.thumbnailUrl != null ? Uri.parse(episode.thumbnailUrl!) : null,
      ));

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

  @override
  Future<void> onTaskRemoved() async {
    await stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
