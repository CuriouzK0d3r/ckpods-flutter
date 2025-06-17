import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/podcast.dart';
import '../models/user.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite not supported on web platform');
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite not supported on web platform');
    }
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'podcast_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create podcasts table
    await db.execute('''
      CREATE TABLE podcasts (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        artworkUrl TEXT,
        publisher TEXT,
        category TEXT,
        language TEXT,
        episodeCount INTEGER DEFAULT 0,
        lastUpdated TEXT,
        rating REAL DEFAULT 0.0,
        ratingCount INTEGER DEFAULT 0,
        isFavorite INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create episodes table
    await db.execute('''
      CREATE TABLE episodes (
        id TEXT PRIMARY KEY,
        podcastId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        audioUrl TEXT NOT NULL,
        duration INTEGER NOT NULL,
        publishDate TEXT NOT NULL,
        thumbnailUrl TEXT,
        rating REAL DEFAULT 0.0,
        ratingCount INTEGER DEFAULT 0,
        isPlayed INTEGER DEFAULT 0,
        isDownloaded INTEGER DEFAULT 0,
        playbackPosition INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (podcastId) REFERENCES podcasts (id)
      )
    ''');

    // Create user settings table
    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        playbackSpeed REAL DEFAULT 1.0,
        volume REAL DEFAULT 1.0,
        autoPlay INTEGER DEFAULT 1,
        downloadOnWifi INTEGER DEFAULT 1,
        notificationsEnabled INTEGER DEFAULT 1,
        newEpisodeNotifications INTEGER DEFAULT 1,
        favoriteUpdatesNotifications INTEGER DEFAULT 1,
        streamingQuality TEXT DEFAULT 'standard',
        downloadQuality TEXT DEFAULT 'high',
        darkMode INTEGER DEFAULT 0,
        skipIntro INTEGER DEFAULT 0,
        skipIntroLength INTEGER DEFAULT 30000,
        skipOutro INTEGER DEFAULT 0,
        skipOutroLength INTEGER DEFAULT 30000
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        podcastId TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(podcastId)
      )
    ''');

    // Create subscriptions table
    await db.execute('''
      CREATE TABLE subscriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        podcastId TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(podcastId)
      )
    ''');

    // Insert default user settings
    await db.insert('user_settings', {
      'id': 1,
      'playbackSpeed': 1.0,
      'volume': 1.0,
      'autoPlay': 1,
      'downloadOnWifi': 1,
      'notificationsEnabled': 1,
      'newEpisodeNotifications': 1,
      'favoriteUpdatesNotifications': 1,
      'streamingQuality': 'standard',
      'downloadQuality': 'high',
      'darkMode': 0,
      'skipIntro': 0,
      'skipIntroLength': 30000,
      'skipOutro': 0,
      'skipOutroLength': 30000,
    });
  }

  Future<void> initDatabase() async {
    if (kIsWeb) {
      // On web, we'll use SharedPreferences for simple key-value storage
      // This is a simplified version for demo purposes
      debugPrint(
          'Database initialized for web platform using SharedPreferences');
      return;
    } else {
      // On mobile platforms, use SQLite
      await database; // This will trigger database initialization
    }
  }

  // Podcast operations
  Future<void> savePodcast(Podcast podcast) async {
    if (kIsWeb) {
      // For web, we'll skip database storage and just return
      // In a real app, you might use IndexedDB or a cloud storage solution
      debugPrint('Podcast save skipped on web: ${podcast.title}');
      return;
    }
    final db = await database;
    await db.insert(
      'podcasts',
      {
        'id': podcast.id,
        'title': podcast.title,
        'description': podcast.description,
        'artworkUrl': podcast.artworkUrl,
        'publisher': podcast.publisher,
        'category': podcast.category,
        'language': podcast.language,
        'episodeCount': podcast.episodeCount,
        'lastUpdated': podcast.lastUpdated?.toIso8601String(),
        'rating': podcast.rating,
        'ratingCount': podcast.ratingCount,
        'isFavorite': podcast.isFavorite ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Podcast>> getFavoritePodcasts() async {
    if (kIsWeb) {
      // For web, return empty list
      // In a real app, you'd use IndexedDB or cloud storage
      return [];
    }
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.* FROM podcasts p
      INNER JOIN favorites f ON p.id = f.podcastId
      ORDER BY f.createdAt DESC
    ''');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return Podcast(
        id: map['id'],
        title: map['title'],
        description: map['description'] ?? '',
        artworkUrl: map['artworkUrl'] ?? '',
        publisher: map['publisher'] ?? '',
        category: map['category'] ?? '',
        language: map['language'] ?? '',
        episodeCount: map['episodeCount'] ?? 0,
        lastUpdated: map['lastUpdated'] != null
            ? DateTime.parse(map['lastUpdated'])
            : null,
        rating: map['rating'] ?? 0.0,
        ratingCount: map['ratingCount'] ?? 0,
        isFavorite: map['isFavorite'] == 1,
      );
    });
  }

  Future<void> addToFavorites(String podcastId) async {
    final db = await database;
    await db.insert(
      'favorites',
      {'podcastId': podcastId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeFromFavorites(String podcastId) async {
    final db = await database;
    await db.delete(
      'favorites',
      where: 'podcastId = ?',
      whereArgs: [podcastId],
    );
  }

  Future<bool> isFavorite(String podcastId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'podcastId = ?',
      whereArgs: [podcastId],
    );
    return maps.isNotEmpty;
  }

  // Episode operations
  Future<void> saveEpisode(Episode episode) async {
    final db = await database;
    await db.insert(
      'episodes',
      {
        'id': episode.id,
        'podcastId': episode.podcastId,
        'title': episode.title,
        'description': episode.description,
        'audioUrl': episode.audioUrl,
        'duration': episode.duration.inMilliseconds,
        'publishDate': episode.publishDate.toIso8601String(),
        'thumbnailUrl': episode.thumbnailUrl,
        'rating': episode.rating,
        'ratingCount': episode.ratingCount,
        'isPlayed': episode.isPlayed ? 1 : 0,
        'isDownloaded': episode.isDownloaded ? 1 : 0,
        'playbackPosition': episode.playbackPosition?.inMilliseconds ?? 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateEpisodePlaybackPosition(
      String episodeId, Duration position) async {
    final db = await database;
    await db.update(
      'episodes',
      {'playbackPosition': position.inMilliseconds},
      where: 'id = ?',
      whereArgs: [episodeId],
    );
  }

  Future<void> markEpisodeAsPlayed(String episodeId) async {
    final db = await database;
    await db.update(
      'episodes',
      {'isPlayed': 1},
      where: 'id = ?',
      whereArgs: [episodeId],
    );
  }

  // User settings operations
  Future<UserSettings> getUserSettings() async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('user_settings');
      if (settingsJson != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(settingsJson);
          return UserSettings(
            playbackSpeed: (map['playbackSpeed'] as num?)?.toDouble() ?? 1.0,
            volume: (map['volume'] as num?)?.toDouble() ?? 1.0,
            autoPlay: map['autoPlay'] as bool? ?? true,
            downloadOnWifi: map['downloadOnWifi'] as bool? ?? true,
            notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
            newEpisodeNotifications:
                map['newEpisodeNotifications'] as bool? ?? true,
            favoriteUpdatesNotifications:
                map['favoriteUpdatesNotifications'] as bool? ?? true,
            streamingQuality: PlaybackQuality.values.firstWhere(
              (quality) => quality.name == map['streamingQuality'],
              orElse: () => PlaybackQuality.standard,
            ),
            downloadQuality: PlaybackQuality.values.firstWhere(
              (quality) => quality.name == map['downloadQuality'],
              orElse: () => PlaybackQuality.high,
            ),
            darkMode: map['darkMode'] as bool? ?? false,
            skipIntro: map['skipIntro'] as bool? ?? false,
            skipIntroLength:
                Duration(milliseconds: map['skipIntroLength'] ?? 30000),
            skipOutro: map['skipOutro'] as bool? ?? false,
            skipOutroLength:
                Duration(milliseconds: map['skipOutroLength'] ?? 30000),
          );
        } catch (e) {
          debugPrint('Error parsing user settings: $e');
          return UserSettings();
        }
      }
      return UserSettings();
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_settings',
        where: 'id = ?',
        whereArgs: [1],
      );

      if (maps.isEmpty) {
        return UserSettings();
      }

      final map = maps.first;
      return UserSettings(
        playbackSpeed: map['playbackSpeed'] ?? 1.0,
        volume: map['volume'] ?? 1.0,
        autoPlay: map['autoPlay'] == 1,
        downloadOnWifi: map['downloadOnWifi'] == 1,
        notificationsEnabled: map['notificationsEnabled'] == 1,
        newEpisodeNotifications: map['newEpisodeNotifications'] == 1,
        favoriteUpdatesNotifications: map['favoriteUpdatesNotifications'] == 1,
        streamingQuality: PlaybackQuality.values.firstWhere(
          (quality) => quality.name == map['streamingQuality'],
          orElse: () => PlaybackQuality.standard,
        ),
        downloadQuality: PlaybackQuality.values.firstWhere(
          (quality) => quality.name == map['downloadQuality'],
          orElse: () => PlaybackQuality.high,
        ),
        darkMode: map['darkMode'] == 1,
        skipIntro: map['skipIntro'] == 1,
        skipIntroLength:
            Duration(milliseconds: map['skipIntroLength'] ?? 30000),
        skipOutro: map['skipOutro'] == 1,
        skipOutroLength:
            Duration(milliseconds: map['skipOutroLength'] ?? 30000),
      );
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    if (kIsWeb) {
      // Use SharedPreferences for web
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> settingsMap = {
        'playbackSpeed': settings.playbackSpeed,
        'volume': settings.volume,
        'autoPlay': settings.autoPlay,
        'downloadOnWifi': settings.downloadOnWifi,
        'notificationsEnabled': settings.notificationsEnabled,
        'newEpisodeNotifications': settings.newEpisodeNotifications,
        'favoriteUpdatesNotifications': settings.favoriteUpdatesNotifications,
        'streamingQuality': settings.streamingQuality.name,
        'downloadQuality': settings.downloadQuality.name,
        'darkMode': settings.darkMode,
        'skipIntro': settings.skipIntro,
        'skipIntroLength': settings.skipIntroLength.inMilliseconds,
        'skipOutro': settings.skipOutro,
        'skipOutroLength': settings.skipOutroLength.inMilliseconds,
      };
      await prefs.setString('user_settings', jsonEncode(settingsMap));
    } else {
      final db = await database;
      await db.update(
        'user_settings',
        {
          'playbackSpeed': settings.playbackSpeed,
          'volume': settings.volume,
          'autoPlay': settings.autoPlay ? 1 : 0,
          'downloadOnWifi': settings.downloadOnWifi ? 1 : 0,
          'notificationsEnabled': settings.notificationsEnabled ? 1 : 0,
          'newEpisodeNotifications': settings.newEpisodeNotifications ? 1 : 0,
          'favoriteUpdatesNotifications':
              settings.favoriteUpdatesNotifications ? 1 : 0,
          'streamingQuality': settings.streamingQuality.name,
          'downloadQuality': settings.downloadQuality.name,
          'darkMode': settings.darkMode ? 1 : 0,
          'skipIntro': settings.skipIntro ? 1 : 0,
          'skipIntroLength': settings.skipIntroLength.inMilliseconds,
          'skipOutro': settings.skipOutro ? 1 : 0,
          'skipOutroLength': settings.skipOutroLength.inMilliseconds,
        },
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
