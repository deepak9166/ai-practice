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
      // ICE candidates will be included in SDP when gathering completes
      console.log("ICE candidate:", e.candidate.candidate);
    } else {
      console.log("ICE gathering complete");
      // Notify that SDP is ready for QR code
      if (isCaller) {
        log("✅ Offer ready - Show QR code");
      } else {
        log("✅ Answer ready - Show QR code");
      }
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
  };
}

// Create offer and wait for ICE gathering
async function createOfferForQR() {
  try {
    log("Initializing peer connection...");
    createPeer(true);
    
    log("Creating offer...");
    const offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    
    log("Waiting for ICE gathering to complete...");
    // Wait for ICE gathering to complete
    await waitForIceGathering();
    
    log("ICE gathering complete, getting final SDP...");
    // Get the updated SDP with all ICE candidates from local description
    const finalSdp = pc.localDescription;
    
    if (!finalSdp) {
      throw new Error("Failed to get local description");
    }
    
    log("✅ Offer created successfully");
    return {
      sdp: finalSdp.sdp,
      type: finalSdp.type
    };
  } catch (error) {
    log("❌ Error in createOfferForQR: " + error.message);
    console.error("createOfferForQR error:", error);
    throw error;
  }
}

// Handle offer from QR code
async function handleOfferFromQR(sdp, sdpType) {
  try {
    log("Handling offer from QR code...");
    createPeer(false);
    await pc.setRemoteDescription(new RTCSessionDescription({ sdp, type: sdpType }));
    
    log("Creating answer...");
    const answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);
    
    log("Waiting for ICE gathering...");
    // Wait for ICE gathering
    await waitForIceGathering();
    
    log("Getting final answer SDP...");
    // Get the updated SDP with all ICE candidates from local description
    const finalSdp = pc.localDescription;
    
    if (!finalSdp) {
      throw new Error("Failed to get local description");
    }
    
    log("✅ Answer created successfully");
    return {
      sdp: finalSdp.sdp,
      type: finalSdp.type
    };
  } catch (error) {
    log("❌ Error in handleOfferFromQR: " + error.message);
    console.error("handleOfferFromQR error:", error);
    throw error;
  }
}

// Handle answer from QR code
async function handleAnswerFromQR(sdp, sdpType) {
  if (!pc) {
    throw new Error("No peer connection");
  }
  await pc.setRemoteDescription(new RTCSessionDescription({ sdp, type: sdpType }));
  log("✅ Answer received - Connection establishing");
}

// Wait for ICE gathering to complete
function waitForIceGathering() {
  return new Promise((resolve) => {
    if (!pc) {
      console.error("No peer connection for ICE gathering");
      resolve();
      return;
    }
    
    // Check if already complete
    if (pc.iceGatheringState === "complete") {
      log("ICE gathering already complete");
      resolve();
      return;
    }
    
    // Listen for gathering state change
    const onGatheringStateChange = () => {
      log(`ICE gathering state: ${pc.iceGatheringState}`);
      if (pc.iceGatheringState === "complete") {
        pc.removeEventListener("icegatheringstatechange", onGatheringStateChange);
        clearInterval(checkInterval);
        log("ICE gathering completed");
        resolve();
      }
    };
    
    pc.addEventListener("icegatheringstatechange", onGatheringStateChange);
    
    // Also poll as backup
    const checkInterval = setInterval(() => {
      if (pc.iceGatheringState === "complete") {
        pc.removeEventListener("icegatheringstatechange", onGatheringStateChange);
        clearInterval(checkInterval);
        log("ICE gathering completed (polling)");
        resolve();
      }
    }, 200);
    
    // Timeout after 15 seconds
    setTimeout(() => {
      pc.removeEventListener("icegatheringstatechange", onGatheringStateChange);
      clearInterval(checkInterval);
      log("⚠️ ICE gathering timeout - proceeding anyway");
      resolve(); // Resolve anyway
    }, 15000);
  });
}

/* ---------- CHAT ---------- */

function sendMessage(msg) {
  if (dataChannel && dataChannel.readyState === "open") {
    dataChannel.send(msg);
    log("Me: " + msg);
  }
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
  const chat = document.getElementById("chat");
  if (chat) {
    chat.innerHTML += `<div>${msg}</div>`;
    chat.scrollTop = chat.scrollHeight;
  }
  console.log(msg);
}
