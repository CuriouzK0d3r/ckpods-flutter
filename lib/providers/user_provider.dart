import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/database_service.dart';

class UserProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  User? _user;
  UserSettings _settings = UserSettings();
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await loadUserSettings();
      // In a real app, you would also load user profile data
      _user = User(
        id: '1',
        name: 'Demo User',
        email: 'demo@example.com',
        settings: _settings,
        createdAt: DateTime.now(),
        lastActiveAt: DateTime.now(),
      );
    } catch (e) {
      _errorMessage = 'Failed to initialize user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserSettings() async {
    try {
      _settings = await _databaseService.getUserSettings();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user settings: $e';
      notifyListeners();
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      await _databaseService.saveUserSettings(newSettings);
      _settings = newSettings;
      
      // Update user object if it exists
      if (_user != null) {
        _user = _user!.copyWith(settings: newSettings);
      }
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update settings: $e';
      notifyListeners();
    }
  }

  Future<void> updatePlaybackSpeed(double speed) async {
    final newSettings = _settings.copyWith(playbackSpeed: speed);
    await updateSettings(newSettings);
  }

  Future<void> updateVolume(double volume) async {
    final newSettings = _settings.copyWith(volume: volume);
    await updateSettings(newSettings);
  }

  Future<void> updateAutoPlay(bool autoPlay) async {
    final newSettings = _settings.copyWith(autoPlay: autoPlay);
    await updateSettings(newSettings);
  }

  Future<void> updateDownloadOnWifi(bool downloadOnWifi) async {
    final newSettings = _settings.copyWith(downloadOnWifi: downloadOnWifi);
    await updateSettings(newSettings);
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(notificationsEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateNewEpisodeNotifications(bool enabled) async {
    final newSettings = _settings.copyWith(newEpisodeNotifications: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateFavoriteUpdatesNotifications(bool enabled) async {
    final newSettings = _settings.copyWith(favoriteUpdatesNotifications: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateStreamingQuality(PlaybackQuality quality) async {
    final newSettings = _settings.copyWith(streamingQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateDownloadQuality(PlaybackQuality quality) async {
    final newSettings = _settings.copyWith(downloadQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateDarkMode(bool darkMode) async {
    final newSettings = _settings.copyWith(darkMode: darkMode);
    await updateSettings(newSettings);
  }

  Future<void> updateSkipIntro(bool skipIntro) async {
    final newSettings = _settings.copyWith(skipIntro: skipIntro);
    await updateSettings(newSettings);
  }

  Future<void> updateSkipIntroLength(Duration length) async {
    final newSettings = _settings.copyWith(skipIntroLength: length);
    await updateSettings(newSettings);
  }

  Future<void> updateSkipOutro(bool skipOutro) async {
    final newSettings = _settings.copyWith(skipOutro: skipOutro);
    await updateSettings(newSettings);
  }

  Future<void> updateSkipOutroLength(Duration length) async {
    final newSettings = _settings.copyWith(skipOutroLength: length);
    await updateSettings(newSettings);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Utility methods for UI
  List<double> get speedOptions => [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  String formatSpeed(double speed) {
    if (speed == 1.0) return 'Normal';
    return '${speed}x';
  }

  List<Duration> get skipDurationOptions => [
    const Duration(seconds: 10),
    const Duration(seconds: 15),
    const Duration(seconds: 30),
    const Duration(seconds: 45),
    const Duration(minutes: 1),
    const Duration(minutes: 2),
  ];

  String formatSkipDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}
