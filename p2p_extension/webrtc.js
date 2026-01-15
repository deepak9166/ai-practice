let pc;
let dataChannel;
let peerId;

const config = {
  iceServers: [{ urls: "stun:stun.l.google.com:19302" }]
};

function createPeer(isCaller) {
  pc = new RTCPeerConnection(config);

  pc.onicecandidate = e => {
    if (e.candidate) {
      sendSignal(peerId, "candidate", e.candidate);
    }
  };

  pc.ontrack = e => {
    console.log("Remote stream received");
  };

  pc.ondatachannel = e => {
    dataChannel = e.channel;
    setupDataChannel();
  };

  if (isCaller) {
    dataChannel = pc.createDataChannel("data");
    setupDataChannel();
  }
}

function setupDataChannel() {
  dataChannel.onopen = () => log("P2P Connected ✅");
  dataChannel.onmessage = e => log("Peer: " + e.data);
}

/* ---------- SIGNAL HANDLER ---------- */

async function handleSignal(data) {
  if (data.type === "offer") {
    peerId = data.from;
    createPeer(false);
    await pc.setRemoteDescription(data.payload);

    const answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    sendSignal(peerId, "answer", answer);
  }

  if (data.type === "answer") {
    await pc.setRemoteDescription(data.payload);
  }

  if (data.type === "candidate") {
    await pc.addIceCandidate(data.payload);
  }
}

/* ---------- CHAT ---------- */

function sendMessage(msg) {
  dataChannel.send(msg);
  log("Me: " + msg);
}

/* ---------- FILE TRANSFER ---------- */

function sendFile(file) {
  const chunkSize = 16000;
  let offset = 0;

  const reader = new FileReader();
  reader.onload = () => {
    dataChannel.send(reader.result);
    offset += chunkSize;
    if (offset < file.size) readSlice(offset);
  };

  function readSlice(o) {
    reader.readAsArrayBuffer(file.slice(o, o + chunkSize));
  }

  readSlice(0);
}

/* ---------- MEDIA ---------- */

async function startCall() {
  const stream = await navigator.mediaDevices.getUserMedia({
    audio: true,
    video: true
  });
  stream.getTracks().forEach(t => pc.addTrack(t, stream));
}

async function startScreenShare() {
  const stream = await navigator.mediaDevices.getDisplayMedia({
    video: true,
    audio: true
  });
  stream.getTracks().forEach(t => pc.addTrack(t, stream));
}

/* ---------- UI ---------- */

function log(msg) {
  document.getElementById("chat").innerHTML += `<div>${msg}</div>`;
}
