import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../services/notification_service.dart';
import '../screens/subscription_screen.dart';
import '../widgets/subscription_button.dart';
import '../models/podcast.dart';

/// Example integration of the subscription system
class SubscriptionIntegrationExample extends StatefulWidget {
  const SubscriptionIntegrationExample({super.key});

  @override
  State<SubscriptionIntegrationExample> createState() =>
      _SubscriptionIntegrationExampleState();
}

class _SubscriptionIntegrationExampleState
    extends State<SubscriptionIntegrationExample> {
  @override
  void initState() {
    super.initState();
    _initializeSubscriptionSystem();
  }

  Future<void> _initializeSubscriptionSystem() async {
    // Initialize notification service
    await NotificationService().initialize();

    // Check if auto-refresh should run
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    await provider.autoRefreshIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription System Demo'),
        actions: [
          // Add subscription screen navigation
          IconButton(
            icon: const Icon(Icons.subscriptions),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Basic subscription button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example 1: Basic Subscription Button',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SubscriptionButton(
                      podcast: _getExamplePodcast(),
                      showLabel: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Example 2: Compact subscription button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example 2: Compact Subscription Button',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SubscriptionButton(
                          podcast: _getExamplePodcast(),
                          isCompact: true,
                        ),
                        const SizedBox(width: 8),
                        const Text('Subscribe to get notifications'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Example 3: Quick subscribe button
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example 3: Quick Subscribe Button',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        QuickSubscribeButton(
                          podcastId: 'example-podcast-id',
                          podcastTitle: 'Example Podcast',
                        ),
                        SizedBox(width: 8),
                        Text('Minimal subscription button'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Example 4: Subscription actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example 4: Subscription Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Consumer<PodcastProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: provider.isRefreshingSubscriptions
                                  ? null
                                  : () => provider.refreshAllSubscriptions(),
                              icon: provider.isRefreshingSubscriptions
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.refresh),
                              label: const Text('Refresh Subscriptions'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showSubscriptionStats(context),
                              icon: const Icon(Icons.analytics),
                              label: const Text('View Stats'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _exportSubscriptions(context),
                              icon: const Icon(Icons.upload),
                              label: const Text('Export Subscriptions'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Example 5: Subscription settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example 5: Subscription Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Consumer<PodcastProvider>(
                      builder: (context, provider, child) {
                        return Column(
                          children: [
                            FutureBuilder<bool>(
                              future: provider.isAutoRefreshEnabled(),
                              builder: (context, snapshot) {
                                final isEnabled = snapshot.data ?? true;
                                return SwitchListTile(
                                  title: const Text('Auto Refresh'),
                                  subtitle: const Text(
                                      'Check for new episodes automatically'),
                                  value: isEnabled,
                                  onChanged: (value) {
                                    provider.setAutoRefreshEnabled(value);
                                  },
                                  contentPadding: EdgeInsets.zero,
                                );
                              },
                            ),
                            FutureBuilder<bool>(
                              future:
                                  provider.areNewEpisodeNotificationsEnabled(),
                              builder: (context, snapshot) {
                                final isEnabled = snapshot.data ?? true;
                                return SwitchListTile(
                                  title:
                                      const Text('New Episode Notifications'),
                                  subtitle: const Text(
                                      'Get notified about new episodes'),
                                  value: isEnabled,
                                  onChanged: (value) {
                                    provider.setNewEpisodeNotificationsEnabled(
                                        value);
                                  },
                                  contentPadding: EdgeInsets.zero,
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SubscriptionFloatingActionButton(
        podcast: _getExamplePodcast(),
      ),
    );
  }

  Podcast _getExamplePodcast() {
    return Podcast(
      id: 'example-podcast-123',
      title: 'Example Podcast',
      description: 'This is an example podcast for demonstration purposes.',
      artworkUrl: 'https://example.com/artwork.jpg',
      publisher: 'Example Publisher',
      category: 'Technology',
      language: 'en',
      episodeCount: 50,
      rating: 4.5,
      ratingCount: 1234,
      isSubscribed: false,
      isFavorite: false,
    );
  }

  Future<void> _showSubscriptionStats(BuildContext context) async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final stats = await provider.getSubscriptionStats();

    if (stats != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Subscription Stats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Subscriptions: ${stats.totalSubscriptions}'),
              Text('Total Episodes: ${stats.totalEpisodes}'),
              Text('Total Listen Time: ${stats.totalListenTimeHours}h'),
              Text('New Episodes This Week: ${stats.newEpisodesThisWeek}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _exportSubscriptions(BuildContext context) async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    final exportData = await provider.exportSubscriptions();

    if (exportData != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export Subscriptions'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Subscription data exported successfully!'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  exportData.length > 200
                      ? '${exportData.substring(0, 200)}...'
                      : exportData,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
