import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../models/podcast.dart';

class PlaybackController extends StatelessWidget {
  final Episode episode;
  final bool showFullControls;
  final bool showProgress;
  final double? iconSize;
  final Color? primaryColor;

  const PlaybackController({
    super.key,
    required this.episode,
    this.showFullControls = false,
    this.showProgress = false,
    this.iconSize,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconSize = iconSize ?? (showFullControls ? 32.0 : 24.0);
    final effectivePrimaryColor = primaryColor ?? Theme.of(context).primaryColor;

    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final isCurrentEpisode = playerProvider.isEpisodeLoaded(episode.id);
        final isPlaying = playerProvider.isEpisodePlaying(episode.id);
        final isLoading = playerProvider.isLoading && isCurrentEpisode;

        if (showFullControls) {
          return _buildFullControls(
            context,
            playerProvider,
            isCurrentEpisode,
            isPlaying,
            isLoading,
            effectiveIconSize,
            effectivePrimaryColor,
          );
        } else {
          return _buildSimpleControls(
            context,
            playerProvider,
            isCurrentEpisode,
            isPlaying,
            isLoading,
            effectiveIconSize,
            effectivePrimaryColor,
          );
        }
      },
    );
  }

  Widget _buildSimpleControls(
    BuildContext context,
    PlayerProvider playerProvider,
    bool isCurrentEpisode,
    bool isPlaying,
    bool isLoading,
    double iconSize,
    Color primaryColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showProgress && isCurrentEpisode) ...[
          LinearProgressIndicator(
            value: playerProvider.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          const SizedBox(height: 8),
        ],
        _buildPlayButton(
          context,
          playerProvider,
          isCurrentEpisode,
          isPlaying,
          isLoading,
          iconSize,
          primaryColor,
        ),
      ],
    );
  }

  Widget _buildFullControls(
    BuildContext context,
    PlayerProvider playerProvider,
    bool isCurrentEpisode,
    bool isPlaying,
    bool isLoading,
    double iconSize,
    Color primaryColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showProgress && isCurrentEpisode) ...[
          _buildProgressBar(context, playerProvider, primaryColor),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Replay 10 seconds
            if (isCurrentEpisode) ...[
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.replay, size: iconSize * 0.8),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '10',
                        style: TextStyle(
                          fontSize: iconSize * 0.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => playerProvider.replay10(),
                tooltip: 'Replay 10 seconds',
              ),
            ],

            // Skip backward 15 seconds
            if (isCurrentEpisode) ...[
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.fast_rewind, size: iconSize * 0.8),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '15',
                        style: TextStyle(
                          fontSize: iconSize * 0.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => playerProvider.skipBackward15(),
                tooltip: 'Skip back 15 seconds',
              ),
            ],

            // Main play/pause button
            _buildPlayButton(
              context,
              playerProvider,
              isCurrentEpisode,
              isPlaying,
              isLoading,
              iconSize * 1.2,
              primaryColor,
            ),

            // Skip forward 30 seconds
            if (isCurrentEpisode) ...[
              IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.fast_forward, size: iconSize * 0.8),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '30',
                        style: TextStyle(
                          fontSize: iconSize * 0.25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => playerProvider.skipForward30(),
                tooltip: 'Skip forward 30 seconds',
              ),
            ],

            // Speed control
            if (isCurrentEpisode) ...[
              PopupMenuButton<double>(
                icon: Icon(
                  Icons.speed,
                  size: iconSize * 0.8,
                ),
                tooltip: 'Playback speed',
                onSelected: (speed) => playerProvider.changeSpeed(speed),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 1.75, child: Text('1.75x')),
                  const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                ],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.speed, size: iconSize * 0.8),
                    Positioned(
                      bottom: 0,
                      child: Text(
                        '${playerProvider.speed}x',
                        style: TextStyle(
                          fontSize: iconSize * 0.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPlayButton(
    BuildContext context,
    PlayerProvider playerProvider,
    bool isCurrentEpisode,
    bool isPlaying,
    bool isLoading,
    double iconSize,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: _getPlayButtonIcon(isCurrentEpisode, isPlaying, isLoading, iconSize),
        onPressed: isLoading
            ? null
            : () => _handlePlayButtonTap(context, playerProvider, isCurrentEpisode),
        color: Colors.white,
        iconSize: iconSize,
        tooltip: isCurrentEpisode
            ? (isPlaying ? 'Pause' : 'Play')
            : 'Play episode',
      ),
    );
  }

  Widget _getPlayButtonIcon(bool isCurrentEpisode, bool isPlaying, bool isLoading, double iconSize) {
    if (isLoading) {
      return SizedBox(
        width: iconSize * 0.7,
        height: iconSize * 0.7,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (isCurrentEpisode && isPlaying) {
      return Icon(Icons.pause, size: iconSize);
    }

    return Icon(Icons.play_arrow, size: iconSize);
  }

  void _handlePlayButtonTap(BuildContext context, PlayerProvider playerProvider, bool isCurrentEpisode) {
    if (isCurrentEpisode) {
      playerProvider.togglePlayPause();
    } else {
      playerProvider.playEpisode(episode);
    }
  }

  Widget _buildProgressBar(BuildContext context, PlayerProvider playerProvider, Color primaryColor) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 4,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          ),
          child: Slider(
            value: playerProvider.progress.clamp(0.0, 1.0),
            onChanged: (value) {
              playerProvider.seekToPercentage(value);
            },
            activeColor: primaryColor,
            inactiveColor: Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                playerProvider.positionString,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                playerProvider.remainingTimeString,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickPlayButton extends StatelessWidget {
  final Episode episode;
  final double? size;
  final Color? color;

  const QuickPlayButton({
    super.key,
    required this.episode,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PlaybackController(
      episode: episode,
      showFullControls: false,
      showProgress: false,
      iconSize: size ?? 24,
      primaryColor: color,
    );
  }
}

class FullPlaybackControls extends StatelessWidget {
  final Episode episode;
  final bool showProgress;

  const FullPlaybackControls({
    super.key,
    required this.episode,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return PlaybackController(
      episode: episode,
      showFullControls: true,
      showProgress: showProgress,
    );
  }
}
