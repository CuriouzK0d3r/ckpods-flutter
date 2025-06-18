import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/podcast.dart';
import '../widgets/playback_controller.dart';
import '../widgets/episode_card.dart';
import '../screens/episode_detail_screen.dart';
import '../widgets/mini_player.dart';

/// Example screen demonstrating episode playback functionality
class PlaybackExampleScreen extends StatefulWidget {
  const PlaybackExampleScreen({super.key});

  @override
  State<PlaybackExampleScreen> createState() => _PlaybackExampleScreenState();
}

class _PlaybackExampleScreenState extends State<PlaybackExampleScreen> {
  late List<Episode> _sampleEpisodes;

  @override
  void initState() {
    super.initState();
    _sampleEpisodes = _generateSampleEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode Playback Demo'),
        actions: [
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              if (playerProvider.hasEpisode) {
                return IconButton(
                  icon: const Icon(Icons.queue_music),
                  onPressed: () => _showNowPlaying(context),
                  tooltip: 'Now Playing',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Current playback status
          _buildPlaybackStatus(),
          
          // Episode list
          Expanded(
            child: _buildEpisodeList(),
          ),
        ],
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildPlaybackStatus() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        if (!playerProvider.hasEpisode) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.music_off,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'No episode playing. Tap play on any episode to start.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (playerProvider.isLoading) ...[
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        const Text('Loading...'),
                      ] else if (playerProvider.isPlaying) ...[
                        Icon(
                          Icons.play_circle_filled,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        const Text('Playing'),
                      ] else ...[
                        const Icon(Icons.pause_circle_filled),
                        const SizedBox(width: 4),
                        const Text('Paused'),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    playerProvider.currentEpisodeTitle ?? 'Unknown Episode',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Text(
                        playerProvider.formattedProgress,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Speed: ${playerProvider.speed}x',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  LinearProgressIndicator(
                    value: playerProvider.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEpisodeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _sampleEpisodes.length,
      itemBuilder: (context, index) {
        final episode = _sampleEpisodes[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              // Example 1: Episode card with integrated play button
              if (index == 0) ...[
                Text(
                  'Example 1: Episode Card with Playback',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                EpisodeCard(
                  episode: episode,
                  showPodcastTitle: true,
                  onTap: () => _openEpisodeDetail(episode),
                ),
                const SizedBox(height: 24),
              ],
              
              // Example 2: Simple play button
              if (index == 1) ...[
                Text(
                  'Example 2: Quick Play Button',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    title: Text(episode.title),
                    subtitle: Text(episode.formattedDuration),
                    trailing: QuickPlayButton(episode: episode),
                    onTap: () => _openEpisodeDetail(episode),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Example 3: Full playback controls
              if (index == 2) ...[
                Text(
                  'Example 3: Full Playback Controls',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          episode.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        FullPlaybackControls(
                          episode: episode,
                          showProgress: true,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              // Regular episode cards for the rest
              if (index > 2) ...[
                EpisodeCard(
                  episode: episode,
                  onTap: () => _openEpisodeDetail(episode),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _openEpisodeDetail(Episode episode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EpisodeDetailScreen(episode: episode),
      ),
    );
  }

  void _showNowPlaying(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildNowPlayingSheet(),
    );
  }

  Widget _buildNowPlayingSheet() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final episode = playerProvider.currentEpisode;
        if (episode == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Now Playing',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      episode.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    FullPlaybackControls(
                      episode: episode,
                      showProgress: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _openEpisodeDetail(episode);
                            },
                            child: const Text('Episode Details'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Episode> _generateSampleEpisodes() {
    final now = DateTime.now();
    return [
      Episode(
        id: 'episode_1',
        podcastId: 'podcast_1',
        title: 'Introduction to Flutter Audio',
        description: 'Learn how to implement audio playback in Flutter applications with just_audio package.',
        audioUrl: 'https://example.com/audio1.mp3',
        duration: const Duration(minutes: 45, seconds: 30),
        publishDate: now.subtract(const Duration(days: 1)),
        rating: 4.8,
        ratingCount: 156,
      ),
      Episode(
        id: 'episode_2',
        podcastId: 'podcast_1',
        title: 'Advanced Audio Features',
        description: 'Explore advanced audio features like speed control, seek functionality, and background playback.',
        audioUrl: 'https://example.com/audio2.mp3',
        duration: const Duration(minutes: 38, seconds: 15),
        publishDate: now.subtract(const Duration(days: 3)),
        rating: 4.6,
        ratingCount: 142,
      ),
      Episode(
        id: 'episode_3',
        podcastId: 'podcast_1',
        title: 'Audio Service Integration',
        description: 'How to integrate audio_service for background playback and media notifications.',
        audioUrl: 'https://example.com/audio3.mp3',
        duration: const Duration(minutes: 52, seconds: 45),
        publishDate: now.subtract(const Duration(days: 7)),
        rating: 4.9,
        ratingCount: 189,
      ),
      Episode(
        id: 'episode_4',
        podcastId: 'podcast_1',
        title: 'Podcast App UI Design',
        description: 'Creating beautiful and intuitive user interfaces for podcast applications.',
        audioUrl: 'https://example.com/audio4.mp3',
        duration: const Duration(minutes: 41, seconds: 20),
        publishDate: now.subtract(const Duration(days: 10)),
        rating: 4.7,
        ratingCount: 203,
      ),
      Episode(
        id: 'episode_5',
        podcastId: 'podcast_1',
        title: 'State Management for Audio',
        description: 'Managing audio state across your Flutter app with Provider and other state management solutions.',
        audioUrl: 'https://example.com/audio5.mp3',
        duration: const Duration(minutes: 36, seconds: 55),
        publishDate: now.subtract(const Duration(days: 14)),
        rating: 4.5,
        ratingCount: 167,
      ),
    ];
  }
}
