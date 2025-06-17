import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../providers/player_provider.dart';
import '../providers/user_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final bool _showSpeedOptions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer2<PlayerProvider, UserProvider>(
        builder: (context, playerProvider, userProvider, child) {
          final episode = playerProvider.currentEpisode;
          if (episode == null) {
            return const Center(child: Text('No episode playing'));
          }

          return SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        onPressed: () => Navigator.of(context).pop(),
                        iconSize: 32,
                      ),
                      const Spacer(),
                      Text(
                        'Now Playing',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () => _showMoreOptions(context),
                        iconSize: 24,
                      ),
                    ],
                  ),
                ),

                // Episode Artwork
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: episode.thumbnailUrl != null
                          ? CachedNetworkImage(
                              imageUrl: episode.thumbnailUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.music_note, size: 64),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                child: const Icon(Icons.music_note, size: 64),
                              ),
                            )
                          : Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              child: const Icon(Icons.music_note, size: 64),
                            ),
                    ),
                  ),
                ),

                // Episode Info and Controls
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Episode Title and Description
                        Text(
                          episode.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Podcast Episode', // You might want to pass podcast title
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Progress Bar
                        Column(
                          children: [
                            Slider(
                              value: playerProvider.progress.clamp(0.0, 1.0),
                              onChanged: (value) {
                                final newPosition = Duration(
                                  milliseconds: (value *
                                          playerProvider
                                              .duration.inMilliseconds)
                                      .round(),
                                );
                                playerProvider.seek(newPosition);
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    playerProvider.formattedPosition,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    playerProvider.formattedDuration,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Playback Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Speed Control
                            IconButton(
                              icon: Text(
                                '${playerProvider.speed}x',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () =>
                                  _showSpeedSelector(context, userProvider),
                            ),
                            // Skip Backward
                            IconButton(
                              icon: const Icon(Icons.replay),
                              onPressed: () => playerProvider.skipBackward(),
                              iconSize: 32,
                            ),
                            // Play/Pause
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: playerProvider.isLoading
                                  ? const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        playerProvider.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                      onPressed: playerProvider.togglePlayPause,
                                      iconSize: 32,
                                    ),
                            ),
                            // Skip Forward
                            IconButton(
                              icon: const Icon(Icons.forward_30),
                              onPressed: () => playerProvider.skipForward(),
                              iconSize: 32,
                            ),
                            // Volume Control
                            IconButton(
                              icon: Icon(
                                userProvider.settings.volume > 0.5
                                    ? Icons.volume_up
                                    : userProvider.settings.volume > 0
                                        ? Icons.volume_down
                                        : Icons.volume_off,
                              ),
                              onPressed: () =>
                                  _showVolumeSlider(context, userProvider),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Additional Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.star_border),
                              onPressed: () => _showRatingDialog(context),
                              tooltip: 'Rate Episode',
                            ),
                            IconButton(
                              icon: const Icon(Icons.share),
                              onPressed: () => _shareEpisode(context, episode),
                              tooltip: 'Share',
                            ),
                            IconButton(
                              icon: const Icon(Icons.download_for_offline),
                              onPressed: () =>
                                  _downloadEpisode(context, episode),
                              tooltip: 'Download',
                            ),
                            IconButton(
                              icon: const Icon(Icons.timer),
                              onPressed: () => _showSleepTimer(context),
                              tooltip: 'Sleep Timer',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Episode Details'),
              onTap: () {
                Navigator.pop(context);
                // Show episode details
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to Playlist'),
              onTap: () {
                Navigator.pop(context);
                // Add to playlist
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                // Report issue
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSpeedSelector(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Playback Speed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...userProvider.speedOptions.map(
              (speed) => ListTile(
                title: Text(userProvider.formatSpeed(speed)),
                trailing: userProvider.settings.playbackSpeed == speed
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  userProvider.updatePlaybackSpeed(speed);
                  context.read<PlayerProvider>().setSpeed(speed);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVolumeSlider(BuildContext context, UserProvider userProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Volume',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.volume_down),
                Expanded(
                  child: Slider(
                    value: userProvider.settings.volume,
                    onChanged: (value) {
                      userProvider.updateVolume(value);
                      context.read<PlayerProvider>().setVolume(value);
                    },
                  ),
                ),
                const Icon(Icons.volume_up),
              ],
            ),
            Text('${(userProvider.settings.volume * 100).round()}%'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate this Episode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How would you rate this episode?'),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                // Handle rating
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _shareEpisode(BuildContext context, episode) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Share functionality would be implemented here')),
    );
  }

  void _downloadEpisode(BuildContext context, episode) {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Download functionality would be implemented here')),
    );
  }

  void _showSleepTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sleep Timer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('15 minutes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('30 minutes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('45 minutes'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('1 hour'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('End of episode'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
