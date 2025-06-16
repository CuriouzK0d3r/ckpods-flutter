# CKPods - Comprehensive Podcast App

A feature-rich podcast application built with Flutter that allows users to discover, listen to, and manage their favorite podcasts.

## Features

### 🎧 Audio Playback
- High-quality audio streaming
- Play/pause controls with background playback support
- Variable playback speed (0.5x to 2x)
- Skip forward/backward controls (15s/30s)
- Volume control
- Sleep timer functionality
- Resume playback from last position

### 📱 User Interface
- Modern Material Design 3 UI
- Dark and light theme support
- Responsive layout for all screen sizes
- Beautiful animations and transitions
- Shimmer loading effects
- Mini player with quick controls

### 🔍 Discovery & Search
- Browse trending and recommended podcasts
- Category-based filtering
- Real-time search functionality
- Advanced search filters
- Podcast ratings and reviews

### 📚 Library Management
- Favorite podcasts
- Subscription management
- Downloaded episodes for offline listening
- Listening history
- Personal playlists

### ⚙️ Customization
- Personalized settings
- Playback preferences
- Download quality options
- Notification preferences
- Auto-play settings
- Skip intro/outro controls

### 🔔 Notifications
- New episode alerts
- Download completion notifications
- Playback controls in notification panel
- Favorite podcast updates

### 💾 Data Management
- Local SQLite database for offline data
- Smart caching for improved performance
- Sync across devices (future feature)
- Export/import settings

## Technical Architecture

### State Management
- **Provider Pattern**: Used for managing app-wide state
- **PodcastProvider**: Handles podcast data and search
- **PlayerProvider**: Manages audio playback state
- **UserProvider**: Manages user preferences and settings

### Audio Playback
- **just_audio**: High-performance audio playback
- **audio_service**: Background audio with media controls
- Support for various audio formats (MP3, AAC, etc.)

### Data Persistence
- **SQLite**: Local database for user data and cache
- **SharedPreferences**: User settings and preferences
- **Cached Network Images**: Optimized image loading and caching

### Networking
- **HTTP/Dio**: RESTful API communication
- **Mock Data**: Demo podcasts for development
- Error handling and retry mechanisms

### UI Components
- **Material Design 3**: Latest design system
- **Custom Widgets**: Reusable UI components
- **Shimmer Effects**: Loading placeholders
- **Cached Images**: Optimized image rendering

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── podcast.dart            # Podcast and Episode models
│   ├── user.dart               # User and Settings models
│   └── *.g.dart               # Generated JSON serialization
├── services/                   # Business logic services
│   ├── podcast_service.dart    # API and data fetching
│   ├── audio_player_service.dart # Audio playback management
│   ├── database_service.dart   # Local data persistence
│   └── notification_service.dart # Push notifications
├── providers/                  # State management
│   ├── podcast_provider.dart   # Podcast state
│   ├── player_provider.dart    # Audio player state
│   └── user_provider.dart      # User preferences state
├── screens/                    # UI screens
│   ├── home_screen.dart        # Main navigation
│   ├── discover_screen.dart    # Podcast discovery
│   ├── search_screen.dart      # Search functionality
│   ├── library_screen.dart     # User library
│   ├── profile_screen.dart     # User profile
│   └── settings_screen.dart    # App settings
├── widgets/                    # Reusable UI components
│   ├── podcast_card.dart       # Podcast display card
│   ├── mini_player.dart        # Bottom mini player
│   ├── player_screen.dart      # Full-screen player
│   ├── category_chips.dart     # Category filters
│   ├── loading_shimmer.dart    # Loading animations
│   └── podcast_list_item.dart  # List item widget
└── utils/                      # Utilities and themes
    └── theme.dart              # App theming
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- iOS development setup (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ckpods-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform Setup

#### Android
- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Required permissions configured in `android/app/src/main/AndroidManifest.xml`

#### iOS
- Minimum iOS version: 12.0
- Background audio capabilities configured
- Required permissions in `ios/Runner/Info.plist`

## Dependencies

### Core Dependencies
- `provider`: State management
- `just_audio`: Audio playback
- `audio_service`: Background audio
- `sqflite`: Local database
- `http` & `dio`: Network requests
- `cached_network_image`: Image caching
- `shared_preferences`: Settings storage

### UI Dependencies
- `flutter_rating_bar`: Rating widgets
- `shimmer`: Loading animations
- `flutter_local_notifications`: Push notifications

### Development Dependencies
- `build_runner`: Code generation
- `json_serializable`: JSON serialization
- `flutter_lints`: Code analysis

## Features in Detail

### Podcast Discovery
- Browse by categories (News, Comedy, Technology, etc.)
- Trending podcasts section
- Search with filters
- Detailed podcast information
- Episode listings

### Audio Player
- Beautiful full-screen player interface
- Mini player for background listening
- Playback speed control (0.5x - 2x)
- Skip controls (customizable duration)
- Volume slider
- Progress tracking with seek functionality

### User Library
- Favorite podcasts management
- Subscription tracking
- Download management for offline listening
- Listening history
- Personal statistics

### Settings & Customization
- Audio quality preferences
- Auto-download settings
- Notification preferences
- Theme selection
- Playback behavior customization

## API Integration

The app is designed to work with podcast APIs but currently uses mock data for demonstration. To integrate with a real API:

1. Update `PodcastService` with actual API endpoints
2. Configure authentication if required
3. Update data models to match API response format
4. Implement error handling for network failures

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the excellent framework
- Just Audio team for the audio playback solution
- Material Design team for the design system
- Open source community for various packages used

## Support

For support, email support@ckpods.com or create an issue in the repository.

---

Built with ❤️ using Flutter
