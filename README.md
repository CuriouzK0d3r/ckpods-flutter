# CKPods Flutter

A Flutter podcast app for listening to podcasts with a clean, modern interface.

## Features

- **Search Screen**: Search for podcasts using the iTunes API
- **Subscriptions Screen**: View your subscribed podcasts
- **Podcast Details Screen**: Browse episodes and subscribe to podcasts
- **Episode Player Screen**: Full-featured audio player with media controls

## Screens

### Search Screen
- Search for podcasts using iTunes API
- Display search results in a beautiful list format
- Tap on any podcast to view details

### Subscriptions Screen
- View all your subscribed podcasts
- Quick access to podcast details
- Persistent storage using SharedPreferences

### Podcast Details Screen
- Display podcast artwork and information
- Subscribe/unsubscribe to podcasts
- Browse all available episodes
- Play episodes directly from the list

### Episode Player Screen
- Full-screen episode player
- Media controls (play/pause, skip forward/backward)
- Progress bar with seek functionality
- Episode artwork and information display

## Dependencies

- `http`: For API calls to iTunes and RSS feeds
- `shared_preferences`: For storing subscriptions locally
- `just_audio`: For audio playback functionality
- `xml`: For parsing podcast RSS feeds
- `cached_network_image`: For efficient image loading and caching
- `provider`: For state management

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

## Design

The app follows a clean, modern design inspired by popular podcast apps with:
- Card-based layouts
- Smooth animations
- Intuitive navigation
- Beautiful typography
- Responsive design

## Architecture

The app uses Provider for state management with:
- `PodcastProvider`: Manages podcast search, subscriptions, and audio playback
- `PodcastService`: Handles API calls and RSS feed parsing
- Model classes for `Podcast` and `Episode`

## Audio Features

- Background audio playback
- Seek functionality
- Skip forward (30s) and backward (15s)
- Persistent playback state
- Mini-player when navigating between screens
