import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/player_provider.dart';
import 'player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final episode = playerProvider.currentEpisode;
        if (episode == null) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: playerProvider.progress,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 2,
              ),
              // Player Controls
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: episode.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: episode.thumbnailUrl!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 48,
                            height: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.music_note),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 48,
                            height: 48,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.music_note),
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.music_note),
                        ),
                ),
                title: Text(
                  episode.title,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  playerProvider.formattedProgress,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                trailing: _buildPlayerControls(playerProvider),
                onTap: () => _showPlayerScreen(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerControls(PlayerProvider playerProvider) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skip Backward Button
        IconButton(
          icon: const Icon(Icons.replay_10),
          onPressed: () => playerProvider.replay10(),
          iconSize: 24,
          tooltip: 'Replay 10s',
        ),
        // Play/Pause Button
        if (playerProvider.isLoading)
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        else
          IconButton(
            icon: Icon(
              playerProvider.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
            onPressed: playerProvider.togglePlayPause,
            iconSize: 32,
            tooltip: playerProvider.isPlaying ? 'Pause' : 'Play',
          ),
        // Skip Forward Button
        IconButton(
          icon: const Icon(Icons.forward_30),
          onPressed: () => playerProvider.skipForward30(),
          iconSize: 24,
          tooltip: 'Skip 30s',
        ),
      ],
    );
  }

  void _showPlayerScreen(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const PlayerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}
