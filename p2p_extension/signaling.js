let socket;
let myId;

// Configure your signaling server URL here
// For localhost: run server.js on your machine
// For remote: use your server's IP/domain (e.g., "ws://your-server.com:3000")
const SIGNALING_SERVER = "ws://localhost:3000";

function connectSignaling(id) {
  myId = id;
  socket = new WebSocket(SIGNALING_SERVER);

  socket.onopen = () => {
    socket.send(JSON.stringify({ join: true, userId: myId }));
  };

  socket.onmessage = e => {
    const data = JSON.parse(e.data);
    handleSignal(data);
  };
}

function sendSignal(to, type, payload) {
  socket.send(JSON.stringify({
    from: myId,
    to,
    type,
    payload
  }));
}
