import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/podcast_provider.dart';
import '../widgets/podcast_list_item.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Library'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Favorites'),
            Tab(text: 'Subscriptions'),
            Tab(text: 'Downloads'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoritesTab(),
          _buildSubscriptionsTab(),
          _buildDownloadsTab(),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<PodcastProvider>(
      builder: (context, podcastProvider, child) {
        if (podcastProvider.favoritePodcasts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorite Podcasts',
            subtitle: 'Podcasts you mark as favorites will appear here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: podcastProvider.favoritePodcasts.length,
          itemBuilder: (context, index) {
            final podcast = podcastProvider.favoritePodcasts[index];
            return PodcastListItem(
              podcast: podcast,
              onTap: () {
                // Navigate to podcast details
                Navigator.of(context).pushNamed(
                  '/podcast-details',
                  arguments: podcast,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSubscriptionsTab() {
    return _buildEmptyState(
      icon: Icons.subscriptions,
      title: 'No Subscriptions',
      subtitle: 'Podcasts you subscribe to will appear here',
    );
  }

  Widget _buildDownloadsTab() {
    return _buildEmptyState(
      icon: Icons.download,
      title: 'No Downloads',
      subtitle: 'Episodes you download will appear here',
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
