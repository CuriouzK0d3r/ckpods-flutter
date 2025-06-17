import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';

class PodcastListItem extends StatelessWidget {
  final Podcast podcast;
  final VoidCallback? onTap;

  const PodcastListItem({
    super.key,
    required this.podcast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: podcast.artworkUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 60,
              height: 60,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.podcast),
            ),
            errorWidget: (context, url, error) => Container(
              width: 60,
              height: 60,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.podcast),
            ),
          ),
        ),
        title: Text(
          podcast.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              podcast.publisher,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
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
                Icon(
                  Icons.library_music,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 2),
                Text(
                  '${podcast.episodeCount} episodes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Consumer<PodcastProvider>(
          builder: (context, podcastProvider, child) {
            return IconButton(
              icon: Icon(
                podcast.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: podcast.isFavorite 
                    ? Colors.red 
                    : Theme.of(context).colorScheme.outline,
              ),
              onPressed: () => podcastProvider.toggleFavorite(podcast),
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
