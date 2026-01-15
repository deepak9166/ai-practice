# Quick Start: Chrome Extension ↔ Flutter App

## 🚀 3-Step Setup

### 1. Start Signaling Server
```bash
cd p2p_extension
npm install
npm start
```
**Copy the IP address shown** (e.g., `192.168.1.100`)

### 2. Update Flutter App
Edit `poc_app_extension/lib/call_screen.dart`:
```dart
final String signalingUrl = "ws://192.168.1.100:3000"; // Your IP from step 1
```

### 3. Connect

**Important:** Each side's User ID must match the other side's Peer ID!

- **Extension**: 
  - User ID = "extension" (your identity)
  - Peer ID = "flutter" (who you want to connect to - the Flutter app's User ID)
  - Click "Connect"

- **Flutter App**: 
  - User ID = "flutter" (your identity)
  - Peer ID = "extension" (who you want to connect to - the Extension's User ID)
  - Click "Connect"

**Example:**
```
Extension:  User ID = "extension"  →  Peer ID = "flutter"
Flutter:    User ID = "flutter"    →  Peer ID = "extension"
            ↑                              ↑
            These must match!              These must match!
```

## ✅ What Works Now

- ✅ WebRTC peer-to-peer connection between extension and Flutter
- ✅ Text messaging via data channel
- ✅ File transfer
- ✅ Audio/Video calls
- ✅ Screen sharing (extension)

## 📝 Key Changes Made

1. **Server** - Now accepts connections from mobile devices (binds to 0.0.0.0)
2. **SDP Format** - Fixed compatibility between JavaScript and Flutter
3. **ICE Candidates** - Fixed format for cross-platform compatibility
4. **Error Handling** - Added better logging and connection state tracking

See `CONNECTION_GUIDE.md` for detailed instructions and troubleshooting.
