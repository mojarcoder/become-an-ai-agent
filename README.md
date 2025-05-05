# Become an AI Agent

A Flutter application to track skills, projects, and learning materials for AI development. This cross-platform app runs on iOS, Android, and macOS.

<img src="assets/icons/app_icon.png" alt="App Icon" width="100" height="100"/>

## Features

### 1. Dashboard
- Track and visualize your AI learning progress
- View personalized skill statistics
- Access quick links to important resources

### 2. Profile Management
- Custom profile setup for AI developers
- Track your learning journey and skill development
- Set and monitor learning goals

### 3. Asset Protection System
- SHA-256 checksum validation for app assets
- Protection against tampering with critical app resources
- Secure asset loading with integrity verification

### 4. Cross-Platform Support
- iOS and Android mobile support
- Full macOS desktop support with file system access

## Technical Details

### File Access Implementation
- Proper file access entitlements for macOS
- Platform-specific permission request methods
- FilePicker configuration with improved parameters

### UI Layout Features
- Responsive design that works across device sizes
- Grid layout with optimized constraints
- Efficient stat display system

### Asset Protection
- Comprehensive asset protection using crypto package
- SHA-256 checksums with security seed
- Different validation behavior for debug/release modes

## Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Dart SDK (3.7.2 or higher)
- Xcode (for iOS/macOS development)
- Android Studio (for Android development)

### Installation
1. Clone the repository:
```
git clone https://github.com/yourusername/become_an_ai_agent.git
```

2. Navigate to the project directory:
```
cd become_an_ai_agent
```

3. Install dependencies:
```
flutter pub get
```

4. Run the app:
```
flutter run
```

## Building Release Versions

### Android
```
flutter build apk --release
```

### iOS
```
flutter build ios --release
```

### macOS
```
flutter build macos --release
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributors

[Your Name] - *Initial work* - [Your GitHub Profile]
