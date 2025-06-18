import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../services/subscription_service.dart';
import '../models/podcast.dart';
import '../widgets/podcast_card.dart';
import '../widgets/episode_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SubscriptionStats? _stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    await provider.loadSubscribedPodcasts();
    await provider.loadLatestSubscriptionEpisodes();

    final stats = await provider.getSubscriptionStats();
    if (mounted) {
      setState(() {
        _stats = stats;
      });
    }
  }

  Future<void> _refreshSubscriptions() async {
    final provider = Provider.of<PodcastProvider>(context, listen: false);
    await provider.refreshAllSubscriptions();
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subscriptions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.subscriptions), text: 'Podcasts'),
            Tab(icon: Icon(Icons.new_releases), text: 'Latest'),
            Tab(icon: Icon(Icons.analytics), text: 'Stats'),
          ],
        ),
        actions: [
          Consumer<PodcastProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isRefreshingSubscriptions
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isRefreshingSubscriptions
                    ? null
                    : _refreshSubscriptions,
                tooltip: 'Refresh Subscriptions',
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Subscription Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Export Subscriptions'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Import Subscriptions'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubscriptionsTab(),
          _buildLatestEpisodesTab(),
          _buildStatsTab(),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsTab() {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final subscriptions = provider.subscribedPodcasts;

        if (subscriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.subscriptions_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Subscriptions Yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Subscribe to podcasts to see them here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('/search'),
                  icon: const Icon(Icons.search),
                  label: const Text('Find Podcasts'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshSubscriptions,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subscriptions.length,
            itemBuilder: (context, index) {
              final podcast = subscriptions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PodcastCard(
                  podcast: podcast,
                  onTap: () => _navigateToPodcastDetail(podcast),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLatestEpisodesTab() {
    return Consumer<PodcastProvider>(
      builder: (context, provider, child) {
        if (provider.isRefreshingSubscriptions) {
          return const Center(child: CircularProgressIndicator());
        }

        final episodes = provider.latestSubscriptionEpisodes;

        if (episodes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.new_releases_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No New Episodes',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pull to refresh or check back later',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _refreshSubscriptions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Now'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshSubscriptions,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: EpisodeCard(
                  episode: episode,
                  showPodcastTitle: true,
                  onTap: () => _navigateToEpisodeDetail(episode),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatsTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_stats != null) ...[
              _buildStatsCard(
                  'Subscriptions', _stats!.totalSubscriptions.toString()),
              const SizedBox(height: 12),
              _buildStatsCard(
                  'Total Episodes', _stats!.totalEpisodes.toString()),
              const SizedBox(height: 12),
              _buildStatsCard(
                  'Listen Time', '${_stats!.totalListenTimeHours}h'),
              const SizedBox(height: 12),
              _buildStatsCard(
                  'New This Week', _stats!.newEpisodesThisWeek.toString()),
              const SizedBox(height: 24),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Updated',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Consumer<PodcastProvider>(
                      builder: (context, provider, child) {
                        final lastRefresh = provider.lastSubscriptionRefresh;
                        if (lastRefresh == null) {
                          return const Text('Never refreshed');
                        }

                        final now = DateTime.now();
                        final difference = now.difference(lastRefresh);

                        String timeAgo;
                        if (difference.inMinutes < 1) {
                          timeAgo = 'Just now';
                        } else if (difference.inHours < 1) {
                          timeAgo = '${difference.inMinutes} minutes ago';
                        } else if (difference.inDays < 1) {
                          timeAgo = '${difference.inHours} hours ago';
                        } else {
                          timeAgo = '${difference.inDays} days ago';
                        }

                        return Text(timeAgo);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Consumer<PodcastProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<bool>(
                          future: provider.isAutoRefreshEnabled(),
                          builder: (context, snapshot) {
                            final isEnabled = snapshot.data ?? true;
                            return SwitchListTile(
                              title: const Text('Auto Refresh'),
                              subtitle: const Text(
                                  'Automatically check for new episodes'),
                              value: isEnabled,
                              onChanged: (value) {
                                provider.setAutoRefreshEnabled(value);
                              },
                              contentPadding: EdgeInsets.zero,
                            );
                          },
                        );
                      },
                    ),
                    Consumer<PodcastProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<bool>(
                          future: provider.areNewEpisodeNotificationsEnabled(),
                          builder: (context, snapshot) {
                            final isEnabled = snapshot.data ?? true;
                            return SwitchListTile(
                              title: const Text('New Episode Notifications'),
                              subtitle: const Text(
                                  'Get notified when new episodes are available'),
                              value: isEnabled,
                              onChanged: (value) {
                                provider
                                    .setNewEpisodeNotificationsEnabled(value);
                              },
                              contentPadding: EdgeInsets.zero,
                            );
                          },
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
    );
  }

  Widget _buildStatsCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'settings':
        _showSubscriptionSettings();
        break;
      case 'export':
        _exportSubscriptions();
        break;
      case 'import':
        _importSubscriptions();
        break;
    }
  }

  void _showSubscriptionSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subscription Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<PodcastProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<bool>(
                  future: provider.isAutoRefreshEnabled(),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? true;
                    return SwitchListTile(
                      title: const Text('Auto Refresh'),
                      subtitle:
                          const Text('Check for new episodes every 6 hours'),
                      value: isEnabled,
                      onChanged: (value) {
                        provider.setAutoRefreshEnabled(value);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                );
              },
            ),
            Consumer<PodcastProvider>(
              builder: (context, provider, child) {
                return FutureBuilder<bool>(
                  future: provider.areNewEpisodeNotificationsEnabled(),
                  builder: (context, snapshot) {
                    final isEnabled = snapshot.data ?? true;
                    return SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle:
                          const Text('Notify when new episodes are found'),
                      value: isEnabled,
                      onChanged: (value) {
                        provider.setNewEpisodeNotificationsEnabled(value);
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                );
              },
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

  void _exportSubscriptions() async {
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
              const Text('Copy this data to backup your subscriptions:'),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  exportData,
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

  void _importSubscriptions() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Subscriptions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Paste your subscription data:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Paste subscription data here...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider =
                  Provider.of<PodcastProvider>(context, listen: false);
              final success =
                  await provider.importSubscriptions(controller.text);

              if (mounted) {
                Navigator.of(context).pop();
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Subscriptions imported successfully!')),
                  );
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _navigateToPodcastDetail(Podcast podcast) {
    Navigator.of(context).pushNamed('/podcast-detail', arguments: podcast);
  }

  void _navigateToEpisodeDetail(Episode episode) {
    Navigator.of(context).pushNamed('/episode-detail', arguments: episode);
  }
}
