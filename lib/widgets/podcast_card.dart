import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';
import '../providers/player_provider.dart';
import 'player_screen.dart';

class PodcastCard extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback? onTap;
  final bool showSubscribeButton;

  const PodcastCard({
    super.key,
    required this.podcast,
    this.onTap,
    this.showSubscribeButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _showPodcastDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Podcast Artwork
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: podcast.artworkUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(
                          Icons.podcasts,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  // Action Buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<PodcastProvider>(
                      builder: (context, podcastProvider, child) {
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: Icon(
                                  podcast.isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: podcast.isFavorite
                                      ? Colors.red
                                      : Colors.white,
                                ),
                                onPressed: () =>
                                    podcastProvider.toggleFavorite(podcast),
                              ),
                            ),
                            const SizedBox(height: 4),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.black54,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                icon: Icon(
                                  podcast.isSubscribed
                                      ? Icons.notifications_active
                                      : Icons.notifications_none,
                                  color: podcast.isSubscribed
                                      ? Colors.blue
                                      : Colors.white,
                                ),
                                onPressed: () =>
                                    podcastProvider.toggleSubscription(podcast),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Podcast Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    podcast.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    podcast.publisher,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Rating
                      if (podcast.rating > 0) ...[
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          podcast.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Episode Count
                      Icon(
                        Icons.library_music,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${podcast.episodeCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPodcastDetails(BuildContext context) {
    // Navigate to podcast details screen
    // This would be implemented with proper navigation
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PodcastDetailsBottomSheet(podcast: podcast),
    );
  }
}

class PodcastDetailsBottomSheet extends StatefulWidget {
  final Podcast podcast;

  const PodcastDetailsBottomSheet({
    super.key,
    required this.podcast,
  });

  @override
  State<PodcastDetailsBottomSheet> createState() =>
      _PodcastDetailsBottomSheetState();
}

class _PodcastDetailsBottomSheetState extends State<PodcastDetailsBottomSheet> {
  List<Episode>? episodes;
  bool isLoadingEpisodes = true;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  Future<void> _loadEpisodes() async {
    try {
      final podcastProvider = context.read<PodcastProvider>();
      final loadedEpisodes =
          await podcastProvider.fetchEpisodesByPodcastId(widget.podcast.id);

      if (mounted) {
        setState(() {
          episodes = loadedEpisodes;
          isLoadingEpisodes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          episodes = [];
          isLoadingEpisodes = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcast = widget.podcast;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artwork
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: podcast.artworkUrl,
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 120,
                            height: 120,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.podcasts, size: 48),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 120,
                            height: 120,
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: const Icon(Icons.podcasts, size: 48),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              podcast.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              podcast.publisher,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                // Subscribe Button
                                Expanded(
                                  child: Consumer<PodcastProvider>(
                                    builder: (context, podcastProvider, child) {
                                      return ElevatedButton.icon(
                                        onPressed: () => podcastProvider
                                            .toggleSubscription(podcast),
                                        icon: Icon(
                                          podcast.isSubscribed
                                              ? Icons.notifications_active
                                              : Icons.notifications_none,
                                        ),
                                        label: Text(
                                          podcast.isSubscribed
                                              ? 'Subscribed'
                                              : 'Subscribe',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: podcast.isSubscribed
                                              ? Colors.blue
                                              : null,
                                          foregroundColor: podcast.isSubscribed
                                              ? Colors.white
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Favorite Button
                                Consumer<PodcastProvider>(
                                  builder: (context, podcastProvider, child) {
                                    return IconButton.filled(
                                      onPressed: () => podcastProvider
                                          .toggleFavorite(podcast),
                                      icon: Icon(
                                        podcast.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: podcast.isFavorite
                                            ? Colors.red
                                            : null,
                                        foregroundColor: podcast.isFavorite
                                            ? Colors.white
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                          context, '${podcast.episodeCount}', 'Episodes'),
                      _buildStat(
                          context, podcast.rating.toStringAsFixed(1), 'Rating'),
                      _buildStat(context, podcast.category, 'Category'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    podcast.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Episodes Section
                  Text(
                    'Episodes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  // Episodes Section
                  if (isLoadingEpisodes)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Loading episodes...'),
                          ],
                        ),
                      ),
                    )
                  else if (episodes != null && episodes!.isNotEmpty)
                    ...episodes!
                        .map((episode) => _buildEpisodeCard(context, episode))
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'No episodes available',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }

  Widget _buildEpisodeCard(BuildContext context, Episode episode) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Handle episode tap - could play episode or show details
          _playEpisode(context, episode);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Play button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Episode details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      episode.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      episode.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(episode.duration),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(episode.publishDate),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // More options
              IconButton(
                onPressed: () => _showEpisodeOptions(context, episode),
                icon: const Icon(Icons.more_vert),
                iconSize: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _playEpisode(BuildContext context, Episode episode) {
    // Use PlayerProvider to play the episode
    final playerProvider = context.read<PlayerProvider>();
    playerProvider.playEpisode(episode);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing: ${episode.title}'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Player',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PlayerScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEpisodeOptions(BuildContext context, Episode episode) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
              _playEpisode(context, episode);
            },
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement download
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement share
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else {
      return '${(difference / 7).floor()}w ago';
    }
  }
}
