# Episode Playback Feature

## Overview

The Episode Playback feature in CKPods provides a comprehensive audio playback system for podcast episodes. This feature is built on top of `just_audio` and `audio_service` packages to provide seamless background playback and media controls.

## Key Components

### 1. AudioPlayerService (`lib/services/audio_player_service.dart`)
- Core audio playback functionality
- Background audio service integration
- Media session handling for lock screen controls
- Support for various audio formats

### 2. PlayerProvider (`lib/providers/player_provider.dart`)
- State management for audio playback
- Progress tracking and position saving
- Error handling and loading states
- Integration with database for playback history

### 3. UI Components

#### MiniPlayer (`lib/widgets/mini_player.dart`)
- Persistent bottom player with basic controls
- Shows currently playing episode
- Quick access to full player

#### PlayerScreen (`lib/widgets/player_screen.dart`)
- Full-screen player interface
- Complete playback controls (play, pause, seek, speed, volume)
- Episode information display
- Additional features (rating, sharing, sleep timer)

#### PlaybackController (`lib/widgets/playback_controller.dart`)
- Reusable playback control widgets
- QuickPlayButton for simple play/pause
- FullPlaybackControls with all features
- Customizable appearance

#### EpisodeCard (`lib/widgets/episode_card.dart`)
- Episode display with integrated playback controls
- Progress indicators for partially played episodes
- Episode metadata and descriptions

## Features

### ✅ Implemented Features

1. **Basic Playback**
   - Play/pause episodes
   - Seek to any position
   - Skip forward/backward (10s, 15s, 30s)
   - Variable playback speed (0.5x - 2.0x)
   - Volume control

2. **Progress Tracking**
   - Automatic position saving
   - Resume playback from last position
   - Visual progress indicators
   - Completion tracking (95% completion mark)

3. **Background Playback**
   - Continue playing when app is minimized
   - Lock screen media controls
   - Notification controls
   - Audio focus management

4. **User Interface**
   - Mini player for persistent access
   - Full-screen player with complete controls
   - Episode cards with quick play buttons
   - Real-time progress updates

5. **State Management**
   - Current episode tracking
   - Playback state synchronization
   - Error handling and user feedback
   - Loading states during transitions

## Usage Examples

### Playing an Episode

```dart
// Get the player provider
final playerProvider = context.read<PlayerProvider>();

// Play an episode
await playerProvider.playEpisode(episode);
```

### Using QuickPlayButton

```dart
QuickPlayButton(
  episode: episode,
  size: 32,
  color: Colors.blue,
)
```

### Using FullPlaybackControls

```dart
FullPlaybackControls(
  episode: episode,
  showProgress: true,
)
```

### Monitoring Player State

```dart
Consumer<PlayerProvider>(
  builder: (context, playerProvider, child) {
    return Text('Currently playing: ${playerProvider.currentEpisode?.title ?? 'None'}');
  },
)
```

## Implementation Guide

### 1. Add to Your App

Ensure your app has the PlayerProvider in the widget tree:

```dart
MultiProvider(
  providers: [
    // Other providers...
    ChangeNotifierProvider(create: (_) => PlayerProvider()),
  ],
  child: MyApp(),
)
```

### 2. Add MiniPlayer to Your Layout

Include the MiniPlayer in your main scaffold:

```dart
Scaffold(
  body: Column(
    children: [
      Expanded(child: YourMainContent()),
      Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          if (playerProvider.currentEpisode == null) {
            return const SizedBox.shrink();
          }
          return const MiniPlayer();
        },
      ),
    ],
  ),
)
```

### 3. Integrate with Episode Lists

Use EpisodeCard or add playback controls to your episode lists:

```dart
ListView.builder(
  itemBuilder: (context, index) {
    final episode = episodes[index];
    return EpisodeCard(
      episode: episode,
      onTap: () => _showEpisodeDetails(episode),
    );
  },
)
```

## Configuration

### Audio Quality Settings

Audio quality can be configured through the UserProvider settings:

```dart
enum PlaybackQuality {
  low,     // 64 kbps
  standard, // 128 kbps
  high,    // 256 kbps
  ultra,   // 320 kbps
}
```

### Skip Durations

Default skip durations can be customized:
- Replay: 10 seconds
- Skip backward: 15 seconds  
- Skip forward: 30 seconds

## Demo

Try the Episode Playback Demo available in the Profile screen to see all features in action:

1. Open the app
2. Go to Profile tab
3. Tap on "Episode Playback Demo"
4. Explore different playback controls and features

## Technical Details

### Dependencies

```yaml
dependencies:
  just_audio: ^0.9.34
  audio_service: ^0.18.10
  provider: ^6.0.5
```

### Permissions

Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

iOS (`ios/Runner/Info.plist`):
```xml
<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

### Performance Considerations

- Episodes are loaded on-demand
- Playback position is saved every 30 seconds
- Memory-efficient audio streaming
- Automatic cleanup of unused resources

## Troubleshooting

### Common Issues

1. **Audio not playing**: Check internet connection and URL validity
2. **Background playback not working**: Verify permissions and audio session setup
3. **Progress not saving**: Ensure database service is initialized
4. **Controls not responding**: Check PlayerProvider state and error messages

### Debug Information

Use the Episode Playback Demo to view current player state and debug issues:
- Current episode
- Playback position
- Player state
- Error messages

## Future Enhancements

Potential improvements for the playback system:

1. **Queue Management**: Play next/previous episodes
2. **Offline Playback**: Download episodes for offline listening
3. **Smart Speed**: Automatically adjust speed based on content
4. **Chapter Support**: Skip to specific chapters in episodes
5. **Sleep Timer**: Auto-stop playback after specified time
6. **Cross-fade**: Smooth transitions between episodes
7. **Equalizer**: Audio enhancement controls

---

This documentation covers the complete episode playback system. For more detailed implementation examples, refer to the source code and the Episode Playback Demo screen.
