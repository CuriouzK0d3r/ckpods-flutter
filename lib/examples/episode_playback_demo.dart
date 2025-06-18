import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/player_provider.dart';
import '../widgets/episode_card.dart';
import '../widgets/playback_controller.dart';
import '../widgets/mini_player.dart';
import '../widgets/player_screen.dart';

/// Demo screen showcasing episode playback functionality
/// This demonstrates how to implement episode playback in your app
class EpisodePlaybackDemo extends StatelessWidget {
  const EpisodePlaybackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode Playback Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(context, 'Episode Cards with Playback'),
                  const SizedBox(height: 16),
                  ..._mockEpisodes.map((episode) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: EpisodeCard(
                          episode: episode,
                          showPodcastTitle: true,
                          onTap: () => _showEpisodeDetail(context, episode),
                        ),
                      )),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Individual Playback Controls'),
                  const SizedBox(height: 16),
                  
                  // Simple Play Button Examples
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Play Buttons',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _mockEpisodes.take(3).map((episode) => 
                              Column(
                                children: [
                                  QuickPlayButton(episode: episode, size: 32),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      episode.title,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Full Controls Example
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Playback Controls',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          FullPlaybackControls(
                            episode: _mockEpisodes.first,
                            showProgress: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Player State Information'),
                  const SizedBox(height: 16),
                  
                  Consumer<PlayerProvider>(
                    builder: (context, playerProvider, child) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Player State',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              _buildStateRow('Episode Playing:', 
                                  playerProvider.currentEpisode?.title ?? 'None'),
                              _buildStateRow('Is Playing:', 
                                  playerProvider.isPlaying ? 'Yes' : 'No'),
                              _buildStateRow('Position:', 
                                  playerProvider.positionString),
                              _buildStateRow('Duration:', 
                                  playerProvider.durationString),
                              _buildStateRow('Speed:', 
                                  '${playerProvider.speed}x'),
                              _buildStateRow('Progress:', 
                                  '${(playerProvider.progress * 100).toStringAsFixed(1)}%'),
                              if (playerProvider.errorMessage != null)
                                _buildStateRow('Error:', 
                                    playerProvider.errorMessage!, isError: true),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, 'Action Buttons'),
                  const SizedBox(height: 16),
                  
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showPlayerScreen(context),
                        icon: const Icon(Icons.open_in_full),
                        label: const Text('Show Full Player'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _playRandomEpisode(context),
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Play Random'),
                      ),
                      Consumer<PlayerProvider>(
                        builder: (context, playerProvider, child) {
                          return ElevatedButton.icon(
                            onPressed: playerProvider.currentEpisode != null 
                                ? () => playerProvider.stop()
                                : null,
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Mini Player at the bottom
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
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildStateRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isError ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEpisodeDetail(BuildContext context, Episode episode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      episode.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    FullPlaybackControls(
                      episode: episode,
                      showProgress: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlayerScreen(BuildContext context) {
    final playerProvider = context.read<PlayerProvider>();
    if (playerProvider.currentEpisode != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PlayerScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No episode currently playing'),
        ),
      );
    }
  }

  void _playRandomEpisode(BuildContext context) {
    final randomEpisode = (_mockEpisodes..shuffle()).first;
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.playEpisode(randomEpisode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${randomEpisode.title}'),
        action: SnackBarAction(
          label: 'Show Player',
          onPressed: () => _showPlayerScreen(context),
        ),
      ),
    );
  }

  static final List<Episode> _mockEpisodes = [
    Episode(
      id: 'demo_ep_1',
      podcastId: 'demo_podcast',
      title: 'Introduction to Flutter Audio',
      description: 'Learn the basics of implementing audio playback in Flutter applications. We cover just_audio, audio_service, and best practices for media apps.',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 45, seconds: 30),
      publishDate: DateTime.now().subtract(const Duration(days: 1)),
      rating: 4.8,
      ratingCount: 234,
    ),
    Episode(
      id: 'demo_ep_2',
      podcastId: 'demo_podcast',
      title: 'Advanced Player Features',
      description: 'Dive deep into advanced features like background playback, queue management, and custom controls for your audio apps.',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 52, seconds: 15),
      publishDate: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4.6,
      ratingCount: 189,
      playbackPosition: const Duration(minutes: 15),
    ),
    Episode(
      id: 'demo_ep_3',
      podcastId: 'demo_podcast',
      title: 'Podcast UI Design Patterns',
      description: 'Explore common UI patterns in podcast apps, including mini players, full-screen players, and episode lists.',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 38, seconds: 45),
      publishDate: DateTime.now().subtract(const Duration(days: 5)),
      rating: 4.9,
      ratingCount: 156,
    ),
    Episode(
      id: 'demo_ep_4',
      podcastId: 'demo_podcast',
      title: 'Performance Optimization',
      description: 'Learn how to optimize your audio app for better performance, including memory management and efficient buffering.',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      duration: const Duration(minutes: 41, seconds: 20),
      publishDate: DateTime.now().subtract(const Duration(days: 7)),
      rating: 4.5,
      ratingCount: 98,
    ),
  ];
}
