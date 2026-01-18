// PeerJS handler for simple peer ID connections
let peer = null;
let dataConnection = null;
let myPeerId = null;
let peerConnected = false; // Track connection state

// Make connection state globally accessible
window.getPeerConnectionState = function() {
  return {
    peerConnected: peerConnected,
    hasDataConnection: !!dataConnection,
    isDataConnectionOpen: dataConnection ? dataConnection.open : false,
    myPeerId: myPeerId
  };
};

// Log function - will be overridden by popup.js if available
function log(msg) {
  console.log(msg);
  // Try to update chat if available
  try {
    const chat = document.getElementById("chat");
    if (chat) {
      const div = document.createElement("div");
      div.textContent = msg;
      div.style.padding = "2px";
      div.style.fontSize = "11px";
      chat.appendChild(div);
      chat.scrollTop = chat.scrollHeight;
    }
  } catch (e) {
    // Ignore if DOM not ready
  }
}

// Initialize PeerJS connection
function initPeerJS(customId = null) {
  return new Promise((resolve, reject) => {
    try {
      // Check if PeerJS is loaded
      if (typeof Peer === 'undefined') {
        const error = new Error('PeerJS library not loaded. Please check if the CDN is accessible.');
        console.error('❌ PeerJS not available:', error);
        log('❌ PeerJS library not loaded');
        reject(error);
        return;
      }

      console.log('✅ PeerJS library found, initializing...');
      
      // Use PeerJS free public server or configure your own
      const peerConfig = {
        host: '0.peerjs.com',
        port: 443,
        path: '/',
        secure: true,
        config: {
          iceServers: [
            { urls: 'stun:stun.l.google.com:19302' },
            { urls: 'stun:stun1.l.google.com:19302' }
          ]
        }
      };

      console.log('Creating Peer instance with config:', peerConfig);
      
      if (customId) {
        peer = new Peer(customId, peerConfig);
        console.log('Peer created with custom ID:', customId);
      } else {
        peer = new Peer(peerConfig);
        console.log('Peer created with auto-generated ID');
      }

      if (!peer) {
        const error = new Error('Failed to create Peer instance');
        console.error('❌ Peer creation failed');
        reject(error);
        return;
      }

      console.log('Peer instance created, waiting for open event...');

      // Add timeout for connection
      const connectionTimeout = setTimeout(() => {
        if (!myPeerId) {
          const error = new Error('Connection timeout - PeerJS server may be unreachable');
          console.error('❌ PeerJS connection timeout');
          log('❌ Connection timeout. Check your internet connection or try again.');
          
          // Update UI
          setTimeout(() => {
            const statusEl = document.getElementById('peerIdValue');
            if (statusEl) {
              statusEl.textContent = "Connection timeout";
              statusEl.style.color = '#d32f2f';
            }
          }, 100);
          
          reject(error);
        }
      }, 10000); // 10 second timeout

      peer.on('open', (id) => {
        clearTimeout(connectionTimeout); // Clear timeout on success
        myPeerId = id;
        console.log('PeerJS opened with ID:', id);
        log(`✅ Connected to PeerJS server. Your Peer ID: ${id}`);
        
        // Update UI with peer ID - ensure DOM is ready
        function updatePeerIdDisplay() {
          const displayEl = document.getElementById('peerIdValue');
          const fullDisplayEl = document.getElementById('myPeerIdDisplay');
          
          console.log('Updating peer ID display. Elements found:', {
            displayEl: !!displayEl,
            fullDisplayEl: !!fullDisplayEl,
            id: id
          });
          
          if (displayEl) {
            displayEl.textContent = id;
            displayEl.style.color = '#1976d2';
            displayEl.style.fontWeight = 'bold';
            console.log('Updated peerIdValue element with:', id);
          }
          
          if (fullDisplayEl) {
            fullDisplayEl.innerHTML = `<strong>Your Peer ID:</strong> <span id="peerIdValue" style="font-family:monospace;color:#1976d2;font-weight:bold;">${id}</span>`;
            console.log('Updated myPeerIdDisplay element with:', id);
          }
          
          // If elements don't exist yet, try again after a short delay
          if (!displayEl && !fullDisplayEl) {
            console.warn('Peer ID display elements not found, retrying...');
            setTimeout(updatePeerIdDisplay, 100);
          }
        }
        
        // Try immediately, then retry if needed
        updatePeerIdDisplay();
        setTimeout(updatePeerIdDisplay, 100);
        setTimeout(updatePeerIdDisplay, 500);
        
        resolve(id);
      });

      peer.on('error', (err) => {
        console.error('PeerJS error:', err);
        console.error('Error type:', err.type);
        console.error('Error message:', err.message);
        log(`❌ PeerJS error: ${err.type} - ${err.message}`);
        
        // Update UI to show error
        setTimeout(() => {
          const statusEl = document.getElementById('peerIdValue');
          if (statusEl) {
            statusEl.textContent = `Error: ${err.type || err.message}`;
            statusEl.style.color = '#d32f2f';
          }
        }, 100);
        
        reject(err);
      });

      peer.on('connection', (conn) => {
        console.log('=== Incoming connection received ===');
        console.log('From peer:', conn.peer);
        log('📥 Incoming connection from: ' + conn.peer);
        dataConnection = conn; // Store the connection immediately
        setupDataConnection(conn);
      });

      peer.on('disconnected', () => {
        log('⚠️ Disconnected from PeerJS server. Reconnecting...');
        if (!peer.destroyed) {
          peer.reconnect();
        }
      });

      peer.on('close', () => {
        log('❌ PeerJS connection closed');
        myPeerId = null;
      });

    } catch (error) {
      console.error('Error initializing PeerJS:', error);
      reject(error);
    }
  });
}

// Connect to another peer by ID
function connectToPeer(peerId) {
  return new Promise((resolve, reject) => {
    if (!peer) {
      reject(new Error('PeerJS not initialized. Call initPeerJS first.'));
      return;
    }
    
    // Check if peer is open (has an ID)
    if (!myPeerId) {
      reject(new Error('PeerJS not ready yet. Wait for initialization to complete.'));
      return;
    }

    try {
      log(`🔗 Connecting to peer: ${peerId}...`);
      const newConnection = peer.connect(peerId, {
        reliable: true,
        serialization: 'none' // Send as string, not binary
      });

      if (!newConnection) {
        reject(new Error('Failed to create connection'));
        return;
      }

      console.log('Created outgoing connection:', newConnection);
      dataConnection = newConnection; // Store immediately

      // Set up connection handlers
      setupDataConnection(newConnection);
      
      // Wait for connection to open before resolving
      newConnection.on('open', () => {
        console.log('=== Outgoing connection opened ===');
        console.log('Connection.open:', newConnection.open);
        resolve(newConnection);
      });
      
      newConnection.on('error', (err) => {
        console.error('Data connection error during setup:', err);
        reject(err);
      });
    } catch (error) {
      console.error('Error connecting to peer:', error);
      reject(error);
    }
  });
}

// Setup data channel handlers
function setupDataConnection(conn) {
  // Prevent duplicate setup
  if (conn._setupComplete) {
    console.log('Connection already set up, skipping...');
    return;
  }
  conn._setupComplete = true;
  
  conn.on('open', () => {
    console.log('=== Data connection opened ===');
    console.log('Peer:', conn.peer);
    console.log('Connection.open:', conn.open);
    
    log(`✅ Connected to peer: ${conn.peer}`);
    dataChannel = conn; // For compatibility with existing code
    dataConnection = conn; // Ensure dataConnection is set
    peerConnected = true;
    
    // Update status in UI - try multiple ways
    setTimeout(() => {
      if (typeof window.updateConnectionStatus === 'function') {
        window.updateConnectionStatus("Connected", "#4CAF50");
      } else if (typeof updateConnectionStatus === 'function') {
        updateConnectionStatus("Connected", "#4CAF50");
      } else {
        // Direct update as fallback
        const statusEl = document.getElementById("statusText");
        if (statusEl) {
          statusEl.textContent = "Connected";
          statusEl.style.color = "#4CAF50";
        }
      }
    }, 100);
    
    if (typeof onPeerConnected === 'function') {
      onPeerConnected();
    }
  });

  conn.on('data', (data) => {
    console.log('Received data:', data, 'Type:', typeof data);
    let message;
    if (typeof data === 'string') {
      message = data;
    } else if (data && typeof data === 'object') {
      // Handle object data
      message = JSON.stringify(data);
    } else {
      message = String(data);
    }
    console.log('Processed message:', message);
    log(`📨 Peer ${conn.peer}: ${message}`);
    if (typeof onPeerMessage === 'function') {
      onPeerMessage(message);
    }
  });

  conn.on('close', () => {
    console.log('Data connection closed with peer:', conn.peer);
    log(`❌ Connection closed with peer: ${conn.peer}`);
    peerConnected = false;
    
    // Update status in UI
    if (typeof updateConnectionStatus === 'function') {
      updateConnectionStatus("Disconnected", "#d32f2f");
    }
    
    if (typeof onPeerDisconnected === 'function') {
      onPeerDisconnected();
    }
  });

  conn.on('error', (err) => {
    console.error('Data connection error:', err);
    log(`❌ Connection error: ${err.message}`);
  });
}

// Send message via PeerJS
function sendPeerMessage(message) {
  console.log('=== sendPeerMessage called ===');
  console.log('Message:', message);
  console.log('dataConnection exists:', !!dataConnection);
  console.log('peerConnected:', peerConnected);
  
  if (dataConnection) {
    console.log('dataConnection.open:', dataConnection.open);
    console.log('dataConnection.readyState:', dataConnection.readyState);
    console.log('dataConnection type:', typeof dataConnection);
  }
  
  // Check if we have a data connection
  if (!dataConnection) {
    console.error('❌ No dataConnection object');
    log('❌ No data connection available');
    return false;
  }
  
  // Check if connection is open - PeerJS uses 'open' property
  const isOpen = dataConnection.open === true;
  
  console.log('Connection check - isOpen:', isOpen, 'peerConnected:', peerConnected);
  
  // Allow sending if connection is open OR if peerConnected flag is true (connection established)
  if (isOpen || peerConnected) {
    try {
      console.log('Attempting to send message...');
      dataConnection.send(message);
      console.log('✅ Message sent successfully:', message);
      log(`Me: ${message}`);
      return true;
    } catch (error) {
      console.error('❌ Error sending message:', error);
      log(`❌ Error sending message: ${error.message}`);
      return false;
    }
  } else {
    console.error('❌ Data connection not open');
    console.error('Connection state:', {
      exists: !!dataConnection,
      open: dataConnection.open,
      readyState: dataConnection.readyState,
      peerConnected: peerConnected
    });
    log('❌ Data connection not open yet. Please wait...');
    return false;
  }
}

// Send file via PeerJS
function sendPeerFile(file) {
  if (!dataConnection || !dataConnection.open) {
    log('❌ No active connection');
    return;
  }

  const reader = new FileReader();
  reader.onload = () => {
    dataConnection.send({
      type: 'file',
      name: file.name,
      size: file.size,
      data: reader.result
    });
    log(`📎 Sent file: ${file.name}`);
  };
  reader.readAsDataURL(file);
}

// Close PeerJS connection
function closePeerJS() {
  if (dataConnection) {
    dataConnection.close();
    dataConnection = null;
  }
  if (peer && !peer.destroyed) {
    peer.destroy();
    peer = null;
  }
  myPeerId = null;
  log('🔌 PeerJS connection closed');
}
