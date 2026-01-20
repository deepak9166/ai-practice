# WebRTC Mobile App

A Flutter mobile application (Android & iOS) that connects to a Chrome Extension via WebRTC by scanning a QR code. The app supports real-time chat and file transfer over WebRTC data channels.

## Features

- ✅ QR Code Scanning - Scan SDP offer from Chrome Extension
- ✅ WebRTC Connection - Establish peer-to-peer connection using STUN servers
- ✅ Real-time Chat - Send and receive messages over data channel
- ✅ File Transfer - Transfer files with chunked transfer (16KB chunks)
- ✅ Connection Status - Monitor connection state and display SDP answer as QR code
- ✅ Clean Architecture - MVVM pattern with Riverpod state management

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with **Riverpod** for state management:

```
lib/
├── models/              # Data models
│   ├── sdp_offer.dart
│   ├── chat_message.dart
│   ├── file_metadata.dart
│   └── connection_state.dart
├── services/            # Business logic services
│   ├── qr_service.dart
│   ├── webrtc_service.dart
│   └── file_transfer_service.dart
├── viewmodels/          # ViewModels (MVVM)
│   ├── webrtc_viewmodel.dart
│   ├── chat_viewmodel.dart
│   └── file_transfer_viewmodel.dart
├── screens/             # UI Screens
│   ├── home_screen.dart
│   ├── qr_scanner_screen.dart
│   ├── connection_status_screen.dart
│   ├── chat_screen.dart
│   └── file_transfer_screen.dart
└── main.dart            # App entry point
```

## Dependencies

- `flutter_webrtc` - WebRTC implementation
- `mobile_scanner` - QR code scanning
- `qr_flutter` - QR code generation
- `file_picker` - File selection
- `flutter_riverpod` - State management
- `path_provider` - File system access
- `clipboard` - Clipboard operations

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Run on Android/iOS:
```bash
flutter run
```

## Usage Flow

1. **Scan QR Code**: Open the app and tap "Scan QR Code"
2. **Process Offer**: The app decodes the SDP offer from the QR code
3. **Create Answer**: The app creates an SDP answer and displays it as a QR code
4. **Connect**: Once connected, you can:
   - Chat in real-time
   - Transfer files
   - Monitor connection status

## WebRTC Flow

1. Chrome Extension generates SDP offer → Encodes as Base64 JSON → Displays as QR code
2. Mobile app scans QR → Decodes SDP offer → Creates RTCPeerConnection
3. Mobile app sets remote description → Creates answer → Sets local description
4. Mobile app displays SDP answer as QR code (for Chrome Extension to scan)
5. Data channel opens → Chat and file transfer enabled

## File Transfer Protocol

Files are transferred in chunks (16KB each):

1. **Metadata Packet**: JSON with file info (name, size, mime type, file ID)
2. **Binary Chunks**: File data split into 16KB chunks
3. **Completion Signal**: JSON indicating transfer complete

## Permissions

### Android
- Camera (for QR scanning)
- Internet (for WebRTC)
- Storage (for file access)

### iOS
- Camera (NSCameraUsageDescription)
- Photo Library (NSPhotoLibraryUsageDescription)

## Code Quality

- ✅ Clean architecture with separation of concerns
- ✅ MVVM pattern implementation
- ✅ Riverpod for reactive state management
- ✅ Well-commented, production-ready code
- ✅ Error handling and connection state management
- ✅ Stream-based communication for real-time updates

## Notes

- Uses STUN server only (no TURN server)
- Data channel is reliable and ordered
- Supports reconnection
- Handles connection failures gracefully
