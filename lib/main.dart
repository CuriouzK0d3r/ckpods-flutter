import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/podcast_provider.dart';
import 'providers/player_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/database_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services (skip database on web due to SQLite limitations)
  try {
    if (!kIsWeb) {
      await DatabaseService().initDatabase();
    }
    if (!kIsWeb) {
      await NotificationService().initialize();
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
      ),
    );
  }
}
