import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'providers/podcast_provider.dart';
import 'providers/player_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/podcast_detail_screen.dart';
import 'screens/episode_detail_screen.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'services/audio_service_manager.dart';
import 'services/android_media_notification_helper.dart';
import 'utils/theme.dart';
import 'models/podcast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services (skip database on web due to SQLite limitations)
  try {
    if (!kIsWeb) {
      await DatabaseService().initDatabase();
      await NotificationService().initialize();
      
      // Initialize audio service for background playback and lockscreen controls
      await AudioServiceManager.instance.initialize();
      
      // Initialize Android-specific media notification helper
      if (Platform.isAndroid) {
        await AndroidMediaNotificationHelper().initialize();
      }
    }
  } catch (e) {
    debugPrint('Service initialization warning: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PodcastProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'CKPods - Podcast App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: kIsWeb ? ThemeMode.light : ThemeMode.system, // Force light theme on web
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
        // Add routes for navigation
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/podcast-detail':
              final podcast = settings.arguments as Podcast;
              return MaterialPageRoute(
                builder: (context) => PodcastDetailScreen(podcast: podcast),
              );
            case '/episode-detail':
              final episode = settings.arguments as Episode;
              return MaterialPageRoute(
                builder: (context) => EpisodeDetailScreen(episode: episode),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
