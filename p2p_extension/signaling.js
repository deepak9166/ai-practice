let socket;
let myId;

function connectSignaling(id) {
  myId = id;
  socket = new WebSocket("ws://localhost:3000");

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
