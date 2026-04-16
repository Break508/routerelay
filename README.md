# RouteRelay

A Flutter-based mesh networking application for voice communication over Bluetooth and network connectivity. RouteRelay enables users to form mobile mesh networks for real-time voice communication with PTT (Push-To-Talk) controls.

## Features

- **Mesh Networking**: Connect devices through BLE and network protocols for distributed voice communication
- **Voice Communication**: Real-time audio streaming with Opus codec compression
- **Push-To-Talk (PTT)**: Hardware volume key integration for hands-free PTT operation
- **MapLibre Integration**: Real-time location tracking and visualization on interactive maps
- **QR Code Scanning**: Device discovery and pairing via QR codes
- **Telemetry Tracking**: Monitor network members' status and location data
- **Local Storage**: SQLite with Isar database for persistent state management
- **BLE Peripheral Support**: Act as both BLE central and peripheral for flexible connectivity

## Tech Stack

- **Framework**: Flutter 3.11.4+
- **Language**: Dart
- **Databases**: Isar 3.1.0+ (local storage)
- **Networking**: 
  - Flutter Blue Plus 2.2.1 (Bluetooth LE)
  - Flutter BLE Peripheral 2.1.0
- **Maps**: MapLibre GL 0.25.0
- **Audio**: 
  - Audioplayers 6.1.0
  - Record 6.1.1
  - Opus Flutter 3.0.1 (codec)
- **Security**: 
  - Cryptography 2.9.0
  - Crypto 3.0.7
- **Mobile Scanner**: 7.2.0 (QR code scanning)
- **Data**: Protocol Buffers 6.0.0 for mesh protocol

## Project Structure

```
routerelay/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── telemetry_state.dart # Telemetry data models
│   ├── services/
│   │   ├── audio_service.dart   # Audio recording/playback
│   │   ├── mesh_service.dart    # Mesh networking logic
│   │   └── l2cap_plugin.dart    # Custom Kotlin plugin
│   └── ui/
│       ├── map_screen.dart      # Main map UI
│       └── widgets/
│           ├── convoy_sidebar.dart
│           └── ptt_button.dart
├── android/                      # Android native code
│   ├── app/
│   │   └── src/
│   │       └── main/
│   │           ├── kotlin/
│   │           │   └── L2CapPlugin.kt
│   │           └── res/         # UI resources
│   └── build.gradle.kts
├── ios/                         # iOS configuration
├── protos/
│   └── mesh.proto              # Protocol buffer definitions
├── test/                        # Unit and widget tests
├── pubspec.yaml                # Dart dependencies
└── analysis_options.yaml       # Linting rules
```

## Getting Started

### Prerequisites

- Flutter SDK 3.11.4 or higher
- Dart SDK (included with Flutter)
- Android SDK (for Android development)
  - Minimum SDK: 21
  - Target SDK: 34+
  - Java 17+
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/routerelay.git
   cd routerelay
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate protocol buffers**
   ```bash
   dart pub global activate protoc_plugin
   protoc --dart_out=grpc:lib/generated protos/*.proto
   ```

4. **Generate Dart code for Isar database**
   ```bash
   flutter pub run build_runner build
   ```

### Running the App

**Debug Mode**
```bash
flutter run
```

**Release Mode**
```bash
flutter run --release
```

### Building

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle**
```bash
flutter build appbundle --release
```

**iOS App**
```bash
flutter build ios --release
```

## Configuration

### Permissions

The app requires the following permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `android.permission.BLUETOOTH` - Bluetooth connectivity
- `android.permission.BLUETOOTH_ADMIN` - Bluetooth control
- `android.permission.BLUETOOTH_SCAN` - Scan for BLE devices
- `android.permission.BLUETOOTH_CONNECT` - Connect to BLE devices
- `android.permission.RECORD_AUDIO` - Audio recording for voice
- `android.permission.ACCESS_FINE_LOCATION` - Location tracking
- `android.permission.CAMERA` - QR code scanning
- `android.permission.READ_EXTERNAL_STORAGE` - File access

**iOS** (`ios/Runner/Info.plist`):
- NSBluetoothPeripheralUsageDescription
- NSBluetoothCentralUsageDescription
- NSMicrophoneUsageDescription
- NSLocationWhenInUseUsageDescription
- NSCameraUsageDescription

### MapLibre Configuration

MapLibre requires a valid map style URL. Configure in your map initialization:
```dart
MapLibreMap(
  styleString: 'https://your-maplibre-style-url/style.json',
  // ... other config
)
```

## Core Services

### AudioService
Handles recording and playback of audio using the Record and Audioplayers packages. Integrates with Opus codec for compression.

```dart
final audioService = AudioService();
await audioService.startRecording((audioData) {
  meshService.broadcastVoice(audioData);
});
```

### MeshService
Manages network topology, device discovery, and voice data routing across the mesh network.

### L2CapPlugin
Custom Kotlin plugin for direct L2CAP socket communication on Android when available.

## Testing

Run tests with:
```bash
flutter test
```

Generate coverage report:
```bash
flutter test --coverage
```

## Development

### Code Generation

Generate code for protocol buffers and Isar models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

Run the linter:
```bash
flutter analyze
```

Fix automatically fixable issues:
```bash
dart fix --apply
```

### Hot Reload

During development:
```bash
flutter run
# Then press 'r' for hot reload or 'R' for hot restart
```

## Troubleshooting

### Common Issues

**"APK starts and immediately stops"**
- Ensure JNI plugin is properly initialized
- Verify MapLibre configuration is correct
- Check Android permissions are granted

**Audio not working**
- Confirm microphone permission is granted
- Check audio service initialization

**Map not displaying**
- Verify MapLibre style URL is valid and accessible
- Check internet connectivity

**BLE Connection Issues**
- Ensure Bluetooth is enabled
- Verify location permissions are granted (required for BLE scanning on Android 6+)
- Check device compatibility

## Build Troubleshooting

### Gradle Build Issues
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --debug
```

### Plugin Issues
Regenerate plugin registration:
```bash
flutter clean
flutter pub get
```

## Known Issues

**APK Crash on Startup (Fixed)**
- **Issue**: App crashes immediately with JNI ClassNotFoundException
- **Cause**: Missing explicit `jni` dependency in pubspec.yaml
- **Solution**: Added `jni: ^0.9.1` to dependencies ✓
- **Status**: FIXED

**Vulkan Rendering Crash (Emulator)**
- **Issue**: SIGSEGV in Impeller/Vulkan rendering pipeline on certain emulators
- **Platform**: Waydroid x86_64 with Intel Vulkan driver
- **Note**: Not reproducible on physical devices; appears to be emulator-specific

## Contributing

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
3. Push to the branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Check existing issues for similar problems
- Review the Flutter documentation at https://flutter.dev

## Acknowledgments

- Flutter team for the excellent framework
- MapLibre contributors
- Flutter community plugins:
  - flutter_blue_plus
  - maplibre_gl
  - isar
  - audioplayers
  - record
  - opus_flutter

## Roadmap

- [ ] iOS Bluetooth optimization
- [ ] Mesh network visualization improvements
- [ ] End-to-end encryption for voice
- [ ] Group management UI enhancements
- [ ] Background service support for continuous operation
- [ ] Desktop platform support
- [ ] Web dashboard for network monitoring
