import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../providers/player_provider.dart';
import '../providers/user_provider.dart';
import 'discover_screen.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DiscoverScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Schedule initialization for after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });

    // Listen for success and error messages
    context.read<PodcastProvider>().addListener(_handlePodcastProviderMessages);
  }

  @override
  void dispose() {
    context
        .read<PodcastProvider>()
        .removeListener(_handlePodcastProviderMessages);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final podcastProvider = context.read<PodcastProvider>();
    final userProvider = context.read<UserProvider>();

    // Initialize providers
    await Future.wait([
      podcastProvider.initialize(),
      userProvider.initialize(),
    ]);
  }

  void _handlePodcastProviderMessages() {
    final podcastProvider = context.read<PodcastProvider>();

    if (podcastProvider.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(podcastProvider.successMessage!),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (podcastProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(podcastProvider.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => podcastProvider.clearError(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main content
          Expanded(
            child: _screens[_currentIndex],
          ),
          // Mini player
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              if (playerProvider.currentEpisode == null) {
                return const SizedBox.shrink();
              }
              return const MiniPlayer();
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
