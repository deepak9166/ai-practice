# P2P Extension - Setup Guide

## How WebSocket Signaling Works

**WebSocket is NOT WebRTC** - it's used for **signaling** (exchanging connection info).

### The Flow:
1. **WebSocket (Signaling)** → Exchange "I want to connect" messages, offers, answers, ICE candidates
2. **WebRTC** → Once connected, handles all peer-to-peer data/media directly

### Why localhost:3000?

- `localhost:3000` means the WebSocket server runs on **your own computer**
- Both peers must be on the **same machine** for this to work
- For real-world use, you need a **remote signaling server**

## Setup Instructions

### 1. Install Dependencies
```bash
cd p2p_extension
npm install
```

### 2. Start the Signaling Server
```bash
npm start
```

The server will run on `ws://localhost:3000`

### 3. Load the Extension
1. Open Chrome → `chrome://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select the `p2p_extension` folder

### 4. Use the Extension
1. Open two browser windows
2. In each window, open the extension popup
3. Enter different User IDs (e.g., "user1" and "user2")
4. Enter the peer's ID
5. Click "Connect"

## For Remote Connections

To connect peers on different machines:

1. **Deploy the server** (`server.js`) to a cloud service (Heroku, Railway, etc.)
2. **Update `signaling.js`** line 5:
   ```javascript
   const SIGNALING_SERVER = "ws://your-server.com:3000";
   ```

## Alternative Signaling Methods

You can replace WebSocket with:
- HTTP long polling
- Server-Sent Events (SSE)
- Firebase Realtime Database
- Any message-passing service

But WebSocket is the most efficient for real-time signaling.
