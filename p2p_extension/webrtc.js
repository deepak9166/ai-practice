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
      // Send ICE candidate in format Flutter expects
      sendSignal(peerId, "candidate", {
        candidate: e.candidate.candidate,
        sdpMid: e.candidate.sdpMid,
        sdpMLineIndex: e.candidate.sdpMLineIndex
      });
    } else {
      console.log("ICE gathering complete");
    }
  };

  pc.onconnectionstatechange = () => {
    console.log("Connection state:", pc.connectionState);
    log(`Connection: ${pc.connectionState}`);
  };

  pc.oniceconnectionstatechange = () => {
    console.log("ICE connection state:", pc.iceConnectionState);
    if (pc.iceConnectionState === "connected" || pc.iceConnectionState === "completed") {
      log("✅ WebRTC connection established!");
    } else if (pc.iceConnectionState === "failed") {
      log("❌ ICE connection failed");
    }
  };

  pc.ontrack = e => {
    console.log("Remote stream received from Flutter app");
    log("📹 Video/audio stream received from Flutter");
    // You can display the stream here if needed
    if (e.streams && e.streams[0]) {
      // Example: attach to video element
      // const video = document.createElement('video');
      // video.srcObject = e.streams[0];
      // video.autoplay = true;
      // document.body.appendChild(video);
    }
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
  dataChannel.onopen = () => {
    log("P2P Connected ✅");
    console.log("Data channel opened with Flutter app");
  };
  dataChannel.onmessage = e => {
    const message = typeof e.data === 'string' ? e.data : 'Binary data received';
    log("Flutter: " + message);
  };
  dataChannel.onerror = e => {
    console.error("Data channel error:", e);
    log("❌ Data channel error");
  };
  dataChannel.onclose = () => {
    log("Data channel closed");
    console.log("Data channel closed");
  };
}

/* ---------- SIGNAL HANDLER ---------- */

async function handleSignal(data) {
  try {
    if (data.type === "offer") {
      peerId = data.from;
      createPeer(false);
      
      // Handle SDP from Flutter (may come as object with sdp and type, or as RTCSessionDescription)
      const sdp = data.payload.sdp || data.payload;
      const type = data.payload.type || "offer";
      await pc.setRemoteDescription(new RTCSessionDescription({ sdp, type }));

      const answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      
      // Send answer in format Flutter expects
      sendSignal(peerId, "answer", {
        sdp: answer.sdp,
        type: answer.type
      });
      log("✅ Sent answer to Flutter app");
    }

    if (data.type === "answer") {
      // Handle SDP from Flutter
      const sdp = data.payload.sdp || data.payload;
      const type = data.payload.type || "answer";
      await pc.setRemoteDescription(new RTCSessionDescription({ sdp, type }));
      log("✅ Received answer from Flutter app");
    }

    if (data.type === "candidate") {
      // Handle ICE candidate from Flutter
      // Flutter sends: { candidate, sdpMid, sdpMLineIndex }
      // JavaScript expects: RTCIceCandidateInit
      const candidate = data.payload.candidate || data.payload;
      const sdpMid = data.payload.sdpMid || null;
      const sdpMLineIndex = data.payload.sdpMLineIndex ?? null;
      
      if (candidate) {
        await pc.addIceCandidate(new RTCIceCandidate({
          candidate: candidate,
          sdpMid: sdpMid,
          sdpMLineIndex: sdpMLineIndex
        }));
      }
    }
  } catch (error) {
    console.error("Error handling signal:", error);
    log("❌ Error: " + error.message);
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
