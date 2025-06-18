import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast.dart';
import '../providers/podcast_provider.dart';

class SubscriptionButton extends StatelessWidget {
  final Podcast podcast;
  final bool showLabel;
  final bool isCompact;

  const SubscriptionButton({
    super.key,
    required this.podcast,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        if (isCompact) {
          return IconButton(
            icon: Icon(
              podcast.isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color:
                  podcast.isSubscribed ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () => provider.toggleSubscriptionEnhanced(podcast),
            tooltip: podcast.isSubscribed ? 'Unsubscribe' : 'Subscribe',
          );
        }

        if (showLabel) {
          return ElevatedButton.icon(
            onPressed: () => provider.toggleSubscriptionEnhanced(podcast),
            icon: Icon(
              podcast.isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none,
            ),
            label: Text(podcast.isSubscribed ? 'Subscribed' : 'Subscribe'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  podcast.isSubscribed ? Theme.of(context).primaryColor : null,
              foregroundColor: podcast.isSubscribed ? Colors.white : null,
            ),
          );
        }

        return CircleAvatar(
          backgroundColor: podcast.isSubscribed
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.outline,
          child: IconButton(
            icon: Icon(
              podcast.isSubscribed
                  ? Icons.notifications_active
                  : Icons.notifications_none,
              color: Colors.white,
            ),
            onPressed: () => provider.toggleSubscriptionEnhanced(podcast),
          ),
        );
      },
    );
  }
}

class QuickSubscribeButton extends StatefulWidget {
  final String podcastId;
  final String podcastTitle;
  final VoidCallback? onSubscriptionChanged;

  const QuickSubscribeButton({
    super.key,
    required this.podcastId,
    required this.podcastTitle,
    this.onSubscriptionChanged,
  });

  @override
  State<QuickSubscribeButton> createState() => _QuickSubscribeButtonState();
}

class _QuickSubscribeButtonState extends State<QuickSubscribeButton> {
  bool _isSubscribed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  Future<void> _checkSubscriptionStatus() async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final isSubscribed = await provider.isPodcastSubscribed(widget.podcastId);

    if (mounted) {
      setState(() {
        _isSubscribed = isSubscribed;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleSubscription() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<PodcastProvider>(context, listen: false);

      // Create a minimal podcast object for the subscription
      final podcast = Podcast(
        id: widget.podcastId,
        title: widget.podcastTitle,
        description: '',
        artworkUrl: '',
        publisher: '',
        category: '',
        language: 'en',
        isSubscribed: _isSubscribed,
      );

      await provider.toggleSubscriptionEnhanced(podcast);

      if (mounted) {
        setState(() {
          _isSubscribed = !_isSubscribed;
        });
        widget.onSubscriptionChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return IconButton(
      icon: Icon(
        _isSubscribed ? Icons.notifications_active : Icons.notifications_none,
        color: _isSubscribed ? Theme.of(context).primaryColor : null,
      ),
      onPressed: _toggleSubscription,
      tooltip: _isSubscribed ? 'Unsubscribe' : 'Subscribe',
    );
  }
}

class SubscriptionFloatingActionButton extends StatelessWidget {
  final Podcast podcast;

  const SubscriptionFloatingActionButton({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        return FloatingActionButton.extended(
          onPressed: () => provider.toggleSubscriptionEnhanced(podcast),
          icon: Icon(
            podcast.isSubscribed
                ? Icons.notifications_active
                : Icons.notifications_none,
          ),
          label: Text(podcast.isSubscribed ? 'Subscribed' : 'Subscribe'),
          backgroundColor:
              podcast.isSubscribed ? Theme.of(context).primaryColor : null,
          foregroundColor: podcast.isSubscribed ? Colors.white : null,
        );
      },
    );
  }
}
