# Chrome Extension ↔ Flutter App Connection Guide

This guide explains how to connect the Chrome extension to a Flutter mobile app via WebRTC.

## Architecture

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────────┐
│ Chrome Extension│◄──WS───►│ Signaling    │◄──WS───►│ Flutter Mobile  │
│  (JavaScript)   │         │ Server       │         │     App         │
└────────┬────────┘         └──────┬───────┘         └────────┬────────┘
         │                          │                          │
         └──────────WebRTC──────────┴──────────WebRTC──────────┘
                    (Direct P2P Connection)
```

1. **WebSocket (Signaling)**: Exchange connection info (offers, answers, ICE candidates)
2. **WebRTC**: Direct peer-to-peer connection for data/media

## Setup Instructions

### Step 1: Start the Signaling Server

```bash
cd p2p_extension
npm install
npm start
```

The server will show:
```
🚀 WebSocket Signaling Server running on:
   - ws://localhost:3000 (for same machine)
   - ws://192.168.1.XXX:3000 (for mobile devices on same network)
```

**Note the IP address** - you'll need it for the Flutter app!

### Step 2: Configure Flutter App

1. Open `poc_app_extension/lib/call_screen.dart`
2. Find the `signalingUrl` variable (around line 25)
3. Replace `localhost` with your computer's IP address:

```dart
final String signalingUrl = "ws://192.168.1.XXX:3000"; // Use your computer's IP
```

**To find your IP:**
- Windows: Run `ipconfig` in CMD, look for "IPv4 Address"
- Mac/Linux: Run `ifconfig` or `ip addr`, look for your network interface

### Step 3: Load Chrome Extension

1. Open Chrome → `chrome://extensions/`
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select the `p2p_extension` folder

### Step 4: Run Flutter App

```bash
cd poc_app_extension
flutter pub get
flutter run
```

### Step 5: Connect

**Important:** Each side's User ID must match the other side's Peer ID!

**In Chrome Extension:**
1. Open the extension popup
2. Enter your User ID (e.g., "extension") - This is your identity
3. Enter Peer ID (e.g., "flutter") - This is the Flutter app's User ID
4. Click "Connect"

**In Flutter App:**
1. Enter your User ID (e.g., "flutter") - This is your identity
2. Enter Peer ID (e.g., "extension") - This is the Extension's User ID
3. Click "Connect"

**Connection Matching:**
```
Extension:  User ID = "extension"  →  Peer ID = "flutter"
Flutter:    User ID = "flutter"    →  Peer ID = "extension"
            ↑                              ↑
            These must match!              These must match!
```

**Important:** The extension must initiate the connection (be the caller).

## Connection Flow

1. Extension creates offer → sends via WebSocket → Server forwards to Flutter
2. Flutter receives offer → creates answer → sends via WebSocket → Server forwards to Extension
3. Both exchange ICE candidates via WebSocket
4. WebRTC establishes direct P2P connection
5. Data channel opens → "P2P Connected ✅" message appears

## Troubleshooting

### "User not found or not connected"
- Make sure both devices are connected to the signaling server
- Check that User IDs match exactly
- Verify the server is running

### "Connection failed"
- Check firewall settings (port 3000 must be open)
- Ensure both devices are on the same network
- Verify the IP address in Flutter app matches your computer's IP

### "WebSocket connection failed"
- Check if server is running: `npm start`
- Verify the URL in Flutter app (use IP, not localhost)
- Check network connectivity

### No video/audio
- Grant camera/microphone permissions in Chrome
- Grant permissions in Flutter app (Android/iOS settings)

## Testing on Same Machine

If testing extension and Flutter app on the same computer:
- Extension: Use `ws://localhost:3000`
- Flutter: Use `ws://localhost:3000` (works on Android emulator, not iOS simulator)

## Remote Connections

For connecting over the internet:
1. Deploy `server.js` to a cloud service (Heroku, Railway, etc.)
2. Update both extension and Flutter app with the server URL
3. Ensure the server has a public IP/domain

## Features Supported

✅ Text messaging via data channel
✅ File transfer via data channel
✅ Audio/Video calls
✅ Screen sharing (extension only)
