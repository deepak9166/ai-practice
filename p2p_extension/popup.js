// QR Code functionality
let currentOfferQR = null;
let currentAnswerQR = null;

// Log function for console and chat display
function log(msg) {
  console.log(msg);
  const chat = document.getElementById("chat");
  if (chat) {
    const div = document.createElement("div");
    div.textContent = msg;
    div.style.padding = "2px";
    div.style.fontSize = "11px";
    chat.appendChild(div);
    chat.scrollTop = chat.scrollHeight;
  }
}

// PeerJS connection handlers - these are called from peerjs-handler.js
// Note: peerConnected variable is managed in peerjs-handler.js
function onPeerConnected() {
  log("✅ P2P Connected via Peer ID!");
  // Update UI to show connected state
  updateConnectionStatus("Connected", "#4CAF50");
}

function onPeerDisconnected() {
  log("❌ Peer disconnected");
  // Update UI to show disconnected state
  updateConnectionStatus("Disconnected", "#d32f2f");
}

function updateConnectionStatus(status, color) {
  console.log('updateConnectionStatus called:', status, color);
  const statusEl = document.getElementById("statusText");
  if (statusEl) {
    statusEl.textContent = status;
    statusEl.style.color = color || "#666";
    console.log('Status updated in UI:', status);
  } else {
    console.warn('statusText element not found');
  }
  const connectionStatusEl = document.getElementById("connectionStatus");
  if (connectionStatusEl) {
    connectionStatusEl.style.display = "block";
  }
}

// Make function globally accessible
window.updateConnectionStatus = updateConnectionStatus;

function onPeerMessage(message) {
  // Handle incoming messages from peer
  log(`📨 Peer: ${message}`);
  // You can add UI updates here if needed
}

function onPeerDisconnected() {
  log("❌ Peer disconnected");
  // Update UI to show disconnected state
  const statusEl = document.getElementById("statusText");
  if (statusEl) {
    statusEl.textContent = "Disconnected";
  }
}

// Initialize PeerJS on page load
window.addEventListener('load', async () => {
  // Wait a bit for all scripts to load
  setTimeout(async () => {
    try {
      // Check if PeerJS is loaded - wait a bit more if needed
      let retries = 0;
      while (typeof Peer === 'undefined' && retries < 10) {
        await new Promise(resolve => setTimeout(resolve, 100));
        retries++;
      }
      
      if (typeof Peer === 'undefined') {
        log("❌ PeerJS library not loaded. Check console for details.");
        const statusEl = document.getElementById('peerIdValue');
        if (statusEl) {
          statusEl.textContent = "PeerJS library not loaded";
          statusEl.style.color = '#d32f2f';
        }
        console.error('PeerJS library check failed. Make sure peerjs.min.js is in the extension folder.');
        return;
      }
      
      console.log('✅ PeerJS library is loaded');

      log("Initializing PeerJS...");
      // Update status to show we're initializing
      const statusEl = document.getElementById('peerIdValue');
      if (statusEl) {
        statusEl.textContent = "Connecting to server...";
        statusEl.style.color = '#666';
      }
      
      const peerId = await initPeerJS();
      log(`✅ PeerJS ready! Your peer ID: ${peerId}`);
      
      // Ensure UI is updated - wait a bit more for DOM updates
      setTimeout(() => {
        const displayEl = document.getElementById('peerIdValue');
        if (displayEl) {
          if (myPeerId) {
            displayEl.textContent = myPeerId;
            displayEl.style.color = '#1976d2';
            displayEl.style.fontWeight = 'bold';
            console.log('✅ UI updated with peer ID:', myPeerId);
          } else {
            displayEl.textContent = "ID received but not set";
            displayEl.style.color = '#ff9800';
            console.warn('Peer ID received but myPeerId variable not set');
          }
        } else {
          console.error('peerIdValue element not found in DOM');
        }
      }, 500);
    } catch (error) {
      log(`⚠️ PeerJS initialization failed: ${error.message}`);
      log("You can still use manual SDP connection");
      console.error("PeerJS init error:", error);
      console.error("Error stack:", error.stack);
      
      // Update status to show error
      const statusEl = document.getElementById('peerIdValue');
      if (statusEl) {
        statusEl.textContent = `Failed: ${error.message}`;
        statusEl.style.color = '#d32f2f';
      }
    }
  }, 100);
});

// Peer ID connection
document.getElementById("connectPeerId").onclick = async () => {
  const customId = document.getElementById("myPeerId").value.trim();
  const targetPeerId = document.getElementById("peerIdInput").value.trim();
  
  if (!targetPeerId) {
    log("❌ Please enter a peer ID to connect to");
    return;
  }
  
  try {
    // Initialize if not already done
    if (!peer || !myPeerId) {
      log("Initializing PeerJS...");
      const customIdValue = customId || undefined;
      await initPeerJS(customIdValue);
      // Display is updated automatically in peerjs-handler.js
    }
    
    log(`🔗 Connecting to peer: ${targetPeerId}...`);
    updateConnectionStatus("Connecting...", "#ff9800");
    
    await connectToPeer(targetPeerId);
    log("✅ Connection initiated! Waiting for peer...");
    // Status will be updated to "Connected" when connection opens via setupDataConnection
  } catch (error) {
    log(`❌ Connection failed: ${error.message}`);
    console.error("Connection error:", error);
  }
};

// Create QR code for Peer ID
document.getElementById("createPeerIdQR").onclick = async () => {
  try {
    // Ensure peer is initialized
    if (!peer || !myPeerId) {
      log("Initializing PeerJS...");
      await initPeerJS();
    }
    
    if (!myPeerId) {
      log("❌ Peer ID not available. Please wait for initialization.");
      return;
    }
    
    log("Creating QR code for Peer ID: " + myPeerId);
    showQRCode(myPeerId, "Your Peer ID QR Code");
    log("✅ QR code displayed - Share this to connect!");
  } catch (error) {
    log("❌ Error creating QR code: " + error.message);
    console.error("QR creation error:", error);
    alert("Error creating QR code: " + error.message);
  }
};

// Scan Peer ID QR code
document.getElementById("scanPeerIdQR").onclick = () => {
  // For scanning, we'll use a simple prompt (in real app, use camera API)
  const scannedPeerId = prompt("Paste the Peer ID from QR code here:");
  if (scannedPeerId && scannedPeerId.trim()) {
    const peerIdInput = document.getElementById("peerIdInput");
    if (peerIdInput) {
      peerIdInput.value = scannedPeerId.trim();
      log("✅ Peer ID entered: " + scannedPeerId.trim());
      log("Click 'Connect by Peer ID' to connect");
    }
  }
};

function processConnectionData(data) {
  try {
    const parsed = JSON.parse(data);
    if (parsed.type === "offer") {
      handleOfferFromQR(parsed.sdp, parsed.sdpType).then(answer => {
        const answerQR = JSON.stringify({
          type: "answer",
          sdp: answer.sdp,
          sdpType: answer.type
        });
        currentAnswerQR = answerQR;
        showQRCode(answerQR, "Answer QR Code - Scan with Flutter app");
        log("✅ Answer created - Show QR code to Flutter app");
      }).catch(err => {
        log("❌ Error creating answer: " + err.message);
      });
    } else if (parsed.type === "answer") {
      handleAnswerFromQR(parsed.sdp, parsed.sdpType);
      log("✅ Answer received - Connecting...");
    }
  } catch (e) {
    log("❌ Error parsing SDP data: " + e.message);
    log("Make sure the SDP data is valid JSON with 'type', 'sdp', and 'sdpType' fields");
  }
}

document.getElementById("send").onclick = () => {
  const msgInput = document.getElementById("msg");
  if (msgInput && msgInput.value.trim()) {
    const message = msgInput.value.trim();
    
    // Check connection state using global function
    let connectionState = { peerConnected: false, hasDataConnection: false, isDataConnectionOpen: false };
    if (typeof getPeerConnectionState === 'function') {
      connectionState = getPeerConnectionState();
    }
    
    console.log('Send message - Connection state:', connectionState);
    console.log('sendPeerMessage available:', typeof sendPeerMessage === 'function');
    
    // Try PeerJS first if connected, fallback to manual WebRTC
    if ((connectionState.peerConnected || connectionState.isDataConnectionOpen) && typeof sendPeerMessage === 'function') {
      const result = sendPeerMessage(message);
      if (result) {
        msgInput.value = "";
        return;
      } else {
        log("⚠️ PeerJS send failed, trying fallback...");
      }
    }
    
    // Fallback to manual WebRTC
    if (typeof sendMessage === 'function') {
      sendMessage(message);
      msgInput.value = "";
    } else {
      log("❌ No connection available. Connection state: " + (isConnected ? "Connected" : "Not connected"));
      log("Data connection: " + (hasDataConnection ? "Open" : "Closed/None"));
    }
  }
};

document.getElementById("call").onclick = () => startCall();
document.getElementById("screen").onclick = () => startScreenShare();

document.getElementById("file").onchange = e => {
  if (e.target.files && e.target.files[0]) {
    const file = e.target.files[0];
    
    // Try PeerJS first if connected, fallback to manual WebRTC
    if (peerConnected && typeof sendPeerFile === 'function') {
      sendPeerFile(file);
      log(`📎 Sending file via PeerJS: ${file.name}`);
      return;
    }
    
    // Fallback to manual WebRTC
    if (typeof sendFile === 'function') {
      sendFile(file);
      log(`📎 Sending file via WebRTC: ${file.name}`);
    } else {
      log("❌ No connection available for file transfer");
    }
  }
};

function showQRCode(data, title) {
  // Create or update QR modal
  let modal = document.getElementById("qrModal");
  if (!modal) {
    modal = document.createElement("div");
    modal.id = "qrModal";
    modal.style.cssText = "position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);display:flex;align-items:center;justify-content:center;z-index:1000;";
    document.body.appendChild(modal);
  }
  
  modal.innerHTML = `
    <div style="background:white;padding:24px;border-radius:12px;text-align:center;max-width:500px;max-height:90vh;overflow-y:auto;">
      <h3 style="margin-top:0;">${title}</h3>
      
      <!-- QR Code Section -->
      <div style="margin-bottom:20px;">
        <div id="qrcode" style="margin:20px 0;display:flex;justify-content:center;align-items:center;min-height:250px;"></div>
        <p style="font-size:12px;color:#666;margin-top:10px;">Scan this QR code with the other device</p>
      </div>
      
      <!-- Manual Input Section -->
      <div style="border-top:1px solid #eee;padding-top:20px;margin-top:20px;">
        <p style="font-size:12px;color:#666;margin-bottom:10px;">Or copy/paste the Peer ID:</p>
        <div style="display:flex;gap:8px;margin-bottom:10px;">
          <textarea id="connectionIdText" readonly style="flex:1;padding:8px;border:1px solid #ddd;border-radius:4px;font-size:11px;font-family:monospace;resize:none;min-height:80px;" onclick="this.select();">${data}</textarea>
        </div>
        <button id="copyPeerIdBtn" style="padding:8px 16px;background:#4CAF50;color:white;border:none;border-radius:4px;cursor:pointer;margin-right:8px;">Copy ID</button>
        <button id="closeQRBtn" style="padding:8px 16px;background:#667eea;color:white;border:none;border-radius:4px;cursor:pointer;">Close</button>
      </div>
    </div>
  `;
  
  // Generate QR code
  const qrcodeDiv = document.getElementById("qrcode");
  
  // Check if QRCode library is loaded
  if (typeof QRCode !== 'undefined' && QRCode.toCanvas) {
    try {
      // Create a canvas element
      const canvas = document.createElement("canvas");
      qrcodeDiv.innerHTML = ""; // Clear any existing content
      qrcodeDiv.appendChild(canvas);
      
      // Generate QR code on canvas using promise
      QRCode.toCanvas(canvas, data, {
        width: 250,
        margin: 2,
        color: {
          dark: '#000000',
          light: '#FFFFFF'
        }
      })
      .then(() => {
        console.log("✅ QR Code generated successfully");
      })
      .catch((error) => {
        console.error("❌ QR Code generation error:", error);
        qrcodeDiv.innerHTML = `<p style="color:red;">Error generating QR code: ${error.message}</p><p style="font-size:10px;word-break:break-all;">${data.substring(0, 100)}...</p>`;
      });
    } catch (error) {
      console.error("❌ QR Code generation exception:", error);
      qrcodeDiv.innerHTML = `<p style="color:red;">Error: ${error.message}</p><p style="font-size:10px;word-break:break-all;">${data.substring(0, 100)}...</p>`;
    }
  } else {
    // Fallback: Show data as text if QRCode library not available
    console.warn("⚠️ QRCode library not loaded, showing text fallback");
    console.log("QRCode type:", typeof QRCode);
    console.log("QRCode object:", QRCode);
    qrcodeDiv.innerHTML = `<p style="color:orange;">QR Code library not loaded</p><p style="font-size:10px;word-break:break-all;max-width:300px;">${data.substring(0, 200)}...</p>`;
  }
  
  // Attach event listeners for buttons (after modal is created)
  setTimeout(() => {
    const closeBtn = document.getElementById("closeQRBtn");
    const copyBtn = document.getElementById("copyPeerIdBtn");
    
    if (closeBtn) {
      closeBtn.addEventListener('click', () => {
        closeQRModal();
      });
    }
    
    if (copyBtn) {
      copyBtn.addEventListener('click', () => {
        copyConnectionId();
      });
    }
    
    // Also close when clicking outside the modal
    modal.addEventListener('click', (e) => {
      if (e.target === modal) {
        closeQRModal();
      }
    });
  }, 100);
}

function closeQRModal() {
  const modal = document.getElementById("qrModal");
  if (modal) {
    modal.remove();
  }
}

window.closeQRModal = closeQRModal;

function copyConnectionId() {
  const textarea = document.getElementById("connectionIdText");
  const copyBtn = document.getElementById("copyPeerIdBtn");
  
  if (textarea) {
    textarea.select();
    document.execCommand('copy');
    log("✅ Peer ID copied to clipboard!");
    
    // Show temporary feedback
    if (copyBtn) {
      const originalText = copyBtn.textContent;
      copyBtn.textContent = "Copied!";
      copyBtn.style.background = "#4CAF50";
      setTimeout(() => {
        copyBtn.textContent = originalText;
        copyBtn.style.background = "#4CAF50";
      }, 2000);
    }
  }
}

window.copyConnectionId = copyConnectionId;
