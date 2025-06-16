# Assets Directory

This directory contains the app's static assets including:

## Images
- `images/` - App logos, icons, and other images
- `logo.png` - Main app logo
- `splash_screen.png` - Splash screen image

## Icons
- `icons/` - Custom icons used throughout the app
- App launcher icons are configured in `android/` and `ios/` directories

## Usage

To add new assets:
1. Place files in appropriate subdirectories
2. Add references to `pubspec.yaml` under the `flutter:` → `assets:` section
3. Run `flutter pub get` to update asset bundles

Example usage in code:
```dart
Image.asset('assets/images/logo.png')
```

For app icons, use the `flutter_launcher_icons` package to generate platform-specific icons.
