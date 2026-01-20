# WebRTC Chrome Extension

A Chrome Extension that connects to a Flutter mobile app using WebRTC. The connection is initiated by displaying a QR code containing the SDP offer.

## Features

- ✅ WebRTC P2P connection via QR codes
- ✅ Reliable, ordered DataChannel
- ✅ Chat messaging with JSON format
- ✅ File sharing with progress tracking
- ✅ Modern, clean UI
- ✅ Error handling and retry mechanisms

## Setup Instructions

### 1. Add Extension Icons

Create three icon files in the `web_rtc_extension` directory:
- `icon16.png` (16x16 pixels)
- `icon48.png` (48x48 pixels)
- `icon128.png` (128x128 pixels)

You can use any image editor or online tool to create these icons.

### 2. Load Extension in Chrome

1. Open Chrome and navigate to `chrome://extensions/`
2. Enable "Developer mode" (toggle in top right)
3. Click "Load unpacked"
4. Select the `web_rtc_extension` folder

### 3. Use the Extension

1. Click the extension icon in Chrome toolbar
2. Click "Create Offer (Show QR)" to generate a QR code
3. Scan the QR code with your Flutter app
4. Once connected, you can:
   - Send chat messages
   - Transfer files
   - See connection status

## Architecture

### Modules

- **webrtc.js**: Handles RTCPeerConnection, DataChannel, and SDP exchange
- **qr.js**: QR code generation and SDP encoding/decoding
- **chat.js**: Chat message formatting and display
- **fileTransfer.js**: File transfer with chunking (16KB chunks)
- **popup.js**: Main UI controller coordinating all modules

### SDP Format

The extension encodes SDP offers/answers as Base64 JSON:

```json
{
  "type": "offer",
  "sdp": "<SDP_OFFER>",
  "meta": {
    "source": "chrome_extension",
    "version": "1.0.0"
  }
}
```

### Chat Message Format

```json
{
  "type": "chat",
  "message": "Hello from extension",
  "timestamp": 1710000000,
  "sender": "extension"
}
```

### File Transfer Format

1. **Metadata** (sent first):
```json
{
  "type": "file_meta",
  "name": "file.pdf",
  "size": 123456,
  "mime": "application/pdf"
}
```

2. **Binary chunks** (16KB each, sent as ArrayBuffer)
3. **Completion signal**:
```json
{
  "type": "file_complete",
  "name": "file.pdf"
}
```

## WebRTC Configuration

- **STUN Server**: `stun:stun.l.google.com:19302`
- **DataChannel**: `data_channel` (reliable, ordered)
- **ICE Gathering**: Waits for completion before generating QR code

## Error Handling

The extension handles:
- Invalid SDP format
- DataChannel disconnection
- Connection timeouts
- File transfer errors

Users can regenerate QR codes or retry connections if errors occur.

## Browser Compatibility

- Chrome/Edge (Chromium-based browsers)
- Requires WebRTC support
- Manifest V3 compatible

## Development

### File Structure

```
web_rtc_extension/
├── manifest.json          # Extension manifest
├── popup.html             # Extension popup UI
├── popup.js               # Main controller
├── webrtc.js              # WebRTC logic
├── qr.js                  # QR code handling
├── chat.js                # Chat functionality
├── fileTransfer.js        # File transfer logic
├── background.js          # Service worker
├── styles.css             # UI styles
└── README.md              # This file
```

### Testing

1. Load extension in Chrome
2. Open extension popup
3. Create offer and scan with Flutter app
4. Test chat and file transfer

## Notes

- The extension uses a CDN for the QR code library (qrcode.js from unpkg.com)
- Files are transferred in 16KB chunks for reliability
- Connection state is displayed in real-time
- Received files are automatically available for download

