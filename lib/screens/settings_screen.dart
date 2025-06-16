import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final settings = userProvider.settings;

          return ListView(
            children: [
              // Playback Settings
              _buildSectionHeader(context, 'Playback'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.speed),
                      title: const Text('Playback Speed'),
                      subtitle: Text(userProvider.formatSpeed(settings.playbackSpeed)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showSpeedSelector(context, userProvider),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.volume_up),
                      title: const Text('Volume'),
                      subtitle: Text('${(settings.volume * 100).round()}%'),
                      trailing: SizedBox(
                        width: 100,
                        child: Slider(
                          value: settings.volume,
                          onChanged: (value) => userProvider.updateVolume(value),
                          min: 0.0,
                          max: 1.0,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.play_arrow),
                      title: const Text('Auto Play'),
                      subtitle: const Text('Automatically play next episode'),
                      value: settings.autoPlay,
                      onChanged: userProvider.updateAutoPlay,
                    ),
                  ],
                ),
              ),

              // Skip Settings
              _buildSectionHeader(context, 'Skip Controls'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.skip_next),
                      title: const Text('Skip Intro'),
                      subtitle: Text('Skip ${userProvider.formatSkipDuration(settings.skipIntroLength)}'),
                      value: settings.skipIntro,
                      onChanged: userProvider.updateSkipIntro,
                    ),
                    if (settings.skipIntro) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('Skip Duration'),
                        subtitle: Text(userProvider.formatSkipDuration(settings.skipIntroLength)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showSkipDurationSelector(
                          context,
                          userProvider,
                          'Intro Skip Duration',
                          settings.skipIntroLength,
                          userProvider.updateSkipIntroLength,
                        ),
                      ),
                    ],
                    const Divider(height: 1),
                    SwitchListTile(
                      secondary: const Icon(Icons.skip_previous),
                      title: const Text('Skip Outro'),
                      subtitle: Text('Skip ${userProvider.formatSkipDuration(settings.skipOutroLength)}'),
                      value: settings.skipOutro,
                      onChanged: userProvider.updateSkipOutro,
                    ),
                    if (settings.skipOutro) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const SizedBox(width: 24),
                        title: const Text('Skip Duration'),
                        subtitle: Text(userProvider.formatSkipDuration(settings.skipOutroLength)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showSkipDurationSelector(
                          context,
                          userProvider,
                          'Outro Skip Duration',
                          settings.skipOutroLength,
                          userProvider.updateSkipOutroLength,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Download Settings
              _buildSectionHeader(context, 'Downloads'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.wifi),
                      title: const Text('Download on WiFi Only'),
                      subtitle: const Text('Save mobile data'),
                      value: settings.downloadOnWifi,
                      onChanged: userProvider.updateDownloadOnWifi,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.high_quality),
                      title: const Text('Streaming Quality'),
                      subtitle: Text(settings.streamingQuality.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showQualitySelector(
                        context,
                        userProvider,
                        'Streaming Quality',
                        settings.streamingQuality,
                        userProvider.updateStreamingQuality,
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download Quality'),
                      subtitle: Text(settings.downloadQuality.displayName),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showQualitySelector(
                        context,
                        userProvider,
                        'Download Quality',
                        settings.downloadQuality,
                        userProvider.updateDownloadQuality,
                      ),
                    ),
                  ],
                ),
              ),

              // Notification Settings
              _buildSectionHeader(context, 'Notifications'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.notifications),
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive app notifications'),
                      value: settings.notificationsEnabled,
                      onChanged: userProvider.updateNotificationsEnabled,
                    ),
                    if (settings.notificationsEnabled) ...[
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const SizedBox(width: 24),
                        title: const Text('New Episodes'),
                        subtitle: const Text('Notify when new episodes are available'),
                        value: settings.newEpisodeNotifications,
                        onChanged: userProvider.updateNewEpisodeNotifications,
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const SizedBox(width: 24),
                        title: const Text('Favorite Updates'),
                        subtitle: const Text('Notify when favorite podcasts update'),
                        value: settings.favoriteUpdatesNotifications,
                        onChanged: userProvider.updateFavoriteUpdatesNotifications,
                      ),
                    ],
                  ],
                ),
              ),

              // Appearance Settings
              _buildSectionHeader(context, 'Appearance'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SwitchListTile(
                  secondary: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: settings.darkMode,
                  onChanged: userProvider.updateDarkMode,
                ),
              ),

              // About Section
              _buildSectionHeader(context, 'About'),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Open privacy policy
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Terms of Service'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () {
                        // Open terms of service
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100), // Bottom padding for mini player
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSkipDurationSelector(
    BuildContext context,
    UserProvider userProvider,
    String title,
    Duration currentValue,
    Function(Duration) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...userProvider.skipDurationOptions.map(
              (duration) => ListTile(
                title: Text(userProvider.formatSkipDuration(duration)),
                trailing: currentValue == duration
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  onChanged(duration);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualitySelector(
    BuildContext context,
    UserProvider userProvider,
    String title,
    PlaybackQuality currentValue,
    Function(PlaybackQuality) onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...PlaybackQuality.values.map(
              (quality) => ListTile(
                title: Text(quality.displayName),
                trailing: currentValue == quality
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  onChanged(quality);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
