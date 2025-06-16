# Development Guide - CKPods Flutter App

## Quick Start

This comprehensive Flutter podcast app has been created with all the essential features for a modern podcast listening experience. Here's how to get started:

### 1. Prerequisites
- Flutter SDK 3.10+
- Dart 3.0+
- Android Studio or VS Code
- iOS Simulator or Android Emulator

### 2. Initial Setup

```bash
# Install dependencies
flutter pub get

# Generate JSON serialization files
flutter packages pub run build_runner build

# Run the app
flutter run
```

## Project Structure Overview

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── podcast.dart            # Podcast and Episode models
│   ├── user.dart               # User and UserSettings models
│   ├── podcast.g.dart          # Generated JSON serialization
│   └── user.g.dart             # Generated JSON serialization
├── services/                    # Business logic layer
│   ├── podcast_service.dart    # API integration
│   ├── audio_player_service.dart # Audio playback
│   ├── database_service.dart   # Local storage
│   └── notification_service.dart # Notifications
├── providers/                   # State management
│   ├── podcast_provider.dart   # Podcast data management
│   ├── player_provider.dart    # Audio player state
│   └── user_provider.dart      # User settings & profile
├── screens/                     # UI screens
│   ├── home_screen.dart        # Main navigation
│   ├── discover_screen.dart    # Podcast discovery
│   ├── search_screen.dart      # Search functionality
│   ├── library_screen.dart     # User's library
│   ├── profile_screen.dart     # User profile
│   └── settings_screen.dart    # App settings
├── widgets/                     # Reusable components
│   ├── podcast_card.dart       # Podcast display card
│   ├── podcast_list_item.dart  # List item widget
│   ├── category_chips.dart     # Category filter
│   ├── mini_player.dart        # Bottom mini player
│   ├── player_screen.dart      # Full screen player
│   └── loading_shimmer.dart    # Loading animations
└── utils/
    └── theme.dart              # App theming
```

## Key Features Implemented

### 🎧 Core Podcast Features
- **Podcast Discovery**: Browse and search podcasts
- **Episode Management**: Play, pause, seek, speed control
- **Favorites System**: Mark and manage favorite podcasts
- **Categories**: Filter podcasts by category
- **Search**: Full-text search across podcasts

### 📱 Audio Player
- **Background Playback**: Continue listening when app is minimized
- **Progress Tracking**: Resume episodes where you left off
- **Speed Control**: Variable playback speed (0.5x - 2.0x)
- **Skip Controls**: Configurable forward/backward skip
- **Media Controls**: Lock screen and notification controls

### 💾 Data Management
- **Local Database**: SQLite for offline data storage
- **User Settings**: Persistent app configuration
- **Caching**: Efficient image and data caching
- **State Management**: Provider pattern for reactive UI

### 🎨 User Interface
- **Material Design 3**: Modern, clean interface
- **Dark Mode**: System-aware theme switching
- **Responsive**: Adapts to different screen sizes
- **Accessibility**: Screen reader support

## API Integration

The app uses mock data by default. To integrate with a real podcast API:

1. **Get API Credentials**: Sign up for a service like Podcast Index API
2. **Update Service**: Modify `lib/services/podcast_service.dart`
3. **Add API Keys**: Update the `_apiKey` and `_apiSecret` constants

```dart
// In podcast_service.dart
static const String _apiKey = 'YOUR_ACTUAL_API_KEY';
static const String _apiSecret = 'YOUR_ACTUAL_API_SECRET';
```

## Database Schema

The app uses SQLite with the following main tables:

### Podcasts Table
```sql
CREATE TABLE podcasts (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  artworkUrl TEXT,
  publisher TEXT,
  category TEXT,
  language TEXT,
  episodeCount INTEGER DEFAULT 0,
  rating REAL DEFAULT 0.0,
  isFavorite INTEGER DEFAULT 0
);
```

### Episodes Table
```sql
CREATE TABLE episodes (
  id TEXT PRIMARY KEY,
  podcastId TEXT NOT NULL,
  title TEXT NOT NULL,
  audioUrl TEXT NOT NULL,
  duration INTEGER NOT NULL,
  playbackPosition INTEGER DEFAULT 0,
  isPlayed INTEGER DEFAULT 0
);
```

## Development Tasks

### Adding New Features

1. **Create Model**: Add to `models/` directory
2. **Update Service**: Add business logic to appropriate service
3. **Create Provider**: Add state management if needed
4. **Build UI**: Create screens and widgets
5. **Test**: Add unit and widget tests

### Common Development Commands

```bash
# Hot reload during development
flutter run

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .

# Generate code (after model changes)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## State Management Flow

The app uses Provider for state management:

1. **PodcastProvider**: Manages podcast data, search, favorites
2. **PlayerProvider**: Controls audio playback state
3. **UserProvider**: Handles user settings and preferences

### Example Usage

```dart
// Reading state
Consumer<PodcastProvider>(
  builder: (context, podcastProvider, child) {
    return Text('${podcastProvider.podcasts.length} podcasts');
  },
)

// Modifying state
context.read<PlayerProvider>().playEpisode(episode);
```

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service layer business logic
- Provider state changes

### Widget Tests
- UI component rendering
- User interaction handling
- Navigation flows

### Integration Tests
- End-to-end user flows
- Database operations
- API integration

## Performance Considerations

### Optimizations Implemented
- **Image Caching**: Using `cached_network_image`
- **Lazy Loading**: Lists load items on demand
- **Database Indexing**: Optimized queries
- **Memory Management**: Proper disposal of resources

### Monitoring
- Track app performance in debug mode
- Monitor memory usage during audio playback
- Profile build times and widget rebuilds

## Deployment

### Android
1. Generate signing key
2. Configure `android/app/build.gradle`
3. Build: `flutter build appbundle --release`
4. Upload to Google Play Console

### iOS
1. Configure Xcode project
2. Set up provisioning profiles
3. Build: `flutter build ios --release`
4. Upload via Xcode or Application Loader

## Troubleshooting

### Common Issues

**Build Errors**: Run `flutter clean && flutter pub get`

**JSON Errors**: Run `flutter packages pub run build_runner build --delete-conflicting-outputs`

**Audio Issues**: Check device permissions and audio service configuration

**Database Errors**: Clear app data or increment database version

### Debug Tools
- Flutter Inspector for widget debugging
- Observatory for performance profiling
- Device logs for runtime errors

## Next Steps

### Planned Enhancements
- [ ] Playlist management
- [ ] Social features (sharing, comments)
- [ ] Podcast recommendations
- [ ] Cross-device sync
- [ ] Advanced analytics
- [ ] Voice commands
- [ ] Car integration

### Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider State Management](https://pub.dev/packages/provider)
- [just_audio Plugin](https://pub.dev/packages/just_audio)
- [Material Design 3](https://m3.material.io/)

---

This development guide should help you understand and extend the CKPods Flutter application. The app is structured to be modular, testable, and maintainable while providing a rich user experience for podcast listeners.
