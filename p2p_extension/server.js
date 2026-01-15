const WebSocket = require('ws');

// Bind to 0.0.0.0 to accept connections from mobile devices on the same network
const wss = new WebSocket.Server({ host: '0.0.0.0', port: 3000 });
const clients = new Map(); // userId -> WebSocket

const os = require('os');
const networkInterfaces = os.networkInterfaces();
let localIP = 'localhost';

// Find local IP address for mobile connections
for (const interfaceName in networkInterfaces) {
  const addresses = networkInterfaces[interfaceName];
  for (const addr of addresses) {
    if (addr.family === 'IPv4' && !addr.internal) {
      localIP = addr.address;
      break;
    }
  }
  if (localIP !== 'localhost') break;
}

console.log('🚀 WebSocket Signaling Server running on:');
console.log(`   - ws://localhost:3000 (for same machine)`);
console.log(`   - ws://${localIP}:3000 (for mobile devices on same network)`);

wss.on('connection', (ws) => {
  console.log('📱 New client connected');

  ws.on('message', (message) => {
    try {
      const data = JSON.parse(message);
      
      if (data.join && data.userId) {
        // Client joining
        clients.set(data.userId, ws);
        console.log(`✅ User ${data.userId} joined. Total users: ${clients.size}`);
        return;
      }

      // Forward signaling message to target peer
      if (data.to && data.from) {
        const targetWs = clients.get(data.to);
        if (targetWs && targetWs.readyState === WebSocket.OPEN) {
          targetWs.send(JSON.stringify(data));
          console.log(`📤 Forwarded ${data.type} from ${data.from} to ${data.to}`);
        } else {
          console.log(`❌ User ${data.to} not found or not connected`);
        }
      }
    } catch (error) {
      console.error('❌ Error parsing message:', error);
    }
  });

  ws.on('close', () => {
    // Remove disconnected client
    for (const [userId, client] of clients.entries()) {
      if (client === ws) {
        clients.delete(userId);
        console.log(`👋 User ${userId} disconnected. Remaining: ${clients.size}`);
        break;
      }
    }
  });

  ws.on('error', (error) => {
    console.error('❌ WebSocket error:', error);
  });
});
