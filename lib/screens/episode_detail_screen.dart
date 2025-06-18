import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/podcast.dart';
import '../providers/player_provider.dart';
import '../widgets/playback_controller.dart';

class EpisodeDetailScreen extends StatefulWidget {
  final Episode episode;

  const EpisodeDetailScreen({
    super.key,
    required this.episode,
  });

  @override
  State<EpisodeDetailScreen> createState() => _EpisodeDetailScreenState();
}

class _EpisodeDetailScreenState extends State<EpisodeDetailScreen> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Episode Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Share Episode'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Download'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Add to Playlist'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Episode artwork and basic info
            _buildEpisodeHeader(),
            
            // Playback controls
            _buildPlaybackSection(),
            
            // Episode details
            _buildEpisodeDetails(),
            
            // Related episodes or podcast info
            _buildRelatedContent(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildEpisodeHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Episode artwork
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.episode.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.episode.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.music_note,
                            size: 64,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Episode title
          Text(
            widget.episode.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Podcast title (would need to fetch from podcast data)
          Text(
            'Podcast Episode', // In a real app, you'd fetch the podcast title
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Episode metadata
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                widget.episode.formattedDuration,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(widget.episode.publishDate),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaybackSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Main playback controls
          FullPlaybackControls(
            episode: widget.episode,
            showProgress: true,
          ),
          
          const SizedBox(height: 16),
          
          // Additional playback info
          Consumer<PlayerProvider>(
            builder: (context, playerProvider, child) {
              final isCurrentEpisode = playerProvider.isEpisodeLoaded(widget.episode.id);
              
              if (!isCurrentEpisode) {
                return const SizedBox.shrink();
              }
              
              return Column(
                children: [
                  // Progress text
                  Text(
                    playerProvider.formattedProgress,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Playback speed
                  Text(
                    'Speed: ${playerProvider.speed}x',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodeDetails() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            widget.episode.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
            ),
            maxLines: _showFullDescription ? null : 4,
            overflow: _showFullDescription ? null : TextOverflow.ellipsis,
          ),
          
          if (widget.episode.description.length > 200) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _showFullDescription = !_showFullDescription;
                });
              },
              child: Text(_showFullDescription ? 'Show Less' : 'Show More'),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Episode stats
          if (widget.episode.rating > 0) ...[
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.episode.rating.toStringAsFixed(1)} (${widget.episode.ratingCount} ratings)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _shareEpisode(),
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
              OutlinedButton.icon(
                onPressed: () => _downloadEpisode(),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
              ),
              OutlinedButton.icon(
                onPressed: () => _addToPlaylist(),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add to Playlist'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'More from this Podcast',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subscription button for the podcast
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.podcasts,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Podcast Title', // Would fetch from podcast data
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Subscribe to get notified of new episodes',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Would use actual podcast data here
                // SubscriptionButton(podcast: podcast),
                ElevatedButton(
                  onPressed: () => _subscribeToPodcast(),
                  child: const Text('Subscribe'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final isCurrentEpisode = playerProvider.isEpisodeLoaded(widget.episode.id);
        
        if (!isCurrentEpisode) {
          return Container(
            padding: const EdgeInsets.all(16),
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
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () => playerProvider.playEpisode(widget.episode),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Episode'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _shareEpisode();
        break;
      case 'download':
        _downloadEpisode();
        break;
      case 'add_to_playlist':
        _addToPlaylist();
        break;
    }
  }

  void _shareEpisode() {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality would be implemented here')),
    );
  }

  void _downloadEpisode() {
    // Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download functionality would be implemented here')),
    );
  }

  void _addToPlaylist() {
    // Implement add to playlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add to playlist functionality would be implemented here')),
    );
  }

  void _subscribeToPodcast() {
    // Implement subscription functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription functionality would be implemented here')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }
}
