# Lockscreen Audio Controls

This implementation adds comprehensive lockscreen media controls for the CKPods Flutter podcast app.

## Features Added

### Background Audio Playback
- Audio continues playing when the app is minimized or the device is locked
- Proper audio session management for both Android and iOS
- Background processing capabilities

### Lockscreen Controls
- **Play/Pause**: Toggle playback directly from the lockscreen
- **Skip Forward**: 30-second skip forward button
- **Skip Backward**: 15-second rewind button  
- **Stop**: Stop playback and clear the media session
- **Seek**: Scrub through the episode timeline (on supported platforms)

### Rich Media Information
- Episode title displayed prominently
- Podcast name as subtitle
- Episode artwork/thumbnail when available
- Current playback position and duration
- Buffer progress indication

### Platform-Specific Features

#### Android
- Foreground service for uninterrupted playback
- Media notification with custom controls
- Lockscreen media controls
- Support for media button events (headphone controls)
- Compact notification view with essential controls

#### iOS
- Background audio capability
- Control Center integration
- Lockscreen media controls
- Support for hardware media buttons

## Implementation Details

### Key Components

1. **AudioPlayerService**: Extended `BaseAudioHandler` with rich media controls
2. **AudioServiceManager**: Singleton manager for audio service lifecycle
3. **PlayerProvider**: Updated to use the new audio service architecture
4. **Platform Configurations**: Android manifest and iOS plist updates

### Audio Service Features

- **MediaItem**: Rich metadata for episodes including title, artist, artwork
- **PlaybackState**: Real-time state updates with available controls
- **SystemActions**: Support for seek, skip forward/backward
- **Background Processing**: Continues playback when app is not in foreground

### Usage

The lockscreen controls are automatically available when:
1. An episode is loaded and playing
2. The device is locked or the app is backgrounded
3. The user accesses media controls via:
   - Lockscreen media player
   - Notification shade (Android)
   - Control Center (iOS)
   - Hardware media buttons

### Code Structure

```
lib/services/
├── audio_player_service.dart      # Core audio handler with lockscreen support
├── audio_service_manager.dart     # Service lifecycle management
└── notification_service.dart      # Local notifications (existing)

lib/providers/
└── player_provider.dart           # Updated to use audio service manager

Platform configurations:
├── android/app/src/main/AndroidManifest.xml  # Android permissions & services
└── ios/Runner/Info.plist                     # iOS background modes
```

## Benefits

1. **Better User Experience**: Users can control podcast playback without unlocking device
2. **System Integration**: Native platform media controls and notifications
3. **Battery Efficiency**: Proper background audio handling
4. **Accessibility**: Standard media controls work with assistive technologies
5. **Hardware Support**: Works with Bluetooth headphones and car systems

## Testing

To test the lockscreen controls:
1. Start playing an episode
2. Lock the device or minimize the app
3. Access lockscreen media controls or notification
4. Verify play/pause, skip forward/backward functionality
5. Test with Bluetooth headphones or car systems

The implementation follows platform best practices for background audio and provides a seamless podcast listening experience.
