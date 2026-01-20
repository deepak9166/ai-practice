/**
 * WebRTC Module
 * Handles RTCPeerConnection, DataChannel, and SDP exchange
 */

class WebRTCManager {
  constructor() {
    this.pc = null;
    this.dataChannel = null;
    this.isCaller = false;
    
    // Callbacks
    this.onConnectionStateChange = null;
    this.onDataChannelOpen = null;
    this.onDataChannelMessage = null;
    this.onDataChannelError = null;
    this.onDataChannelClose = null;
  }

  /**
   * Create RTCPeerConnection with STUN servers
   */
  createPeerConnection() {
    const configuration = {
      iceServers: [
        { urls: 'stun:stun.l.google.com:19302' }
      ],
      iceCandidatePoolSize: 10 // Pre-gather candidates for faster connection
    };

    this.pc = new RTCPeerConnection(configuration);

    // Handle ICE connection state
    this.pc.oniceconnectionstatechange = () => {
      const state = this.pc.iceConnectionState;
      console.log('ICE Connection State:', state);
      
      if (this.onConnectionStateChange) {
        this.onConnectionStateChange(state);
      }

      if (state === 'failed' || state === 'disconnected') {
        if (this.onDataChannelClose) {
          this.onDataChannelClose();
        }
      }
    };

    // Handle ICE candidates
    this.pc.onicecandidate = (event) => {
      if (event.candidate) {
        console.log('ICE Candidate:', event.candidate.candidate);
      } else {
        console.log('ICE candidate gathering complete');
      }
    };

    // Handle connection state
    this.pc.onconnectionstatechange = () => {
      console.log('Connection State:', this.pc.connectionState);
    };
  }

  /**
   * Create offer and set local description
   * Returns the SDP offer
   */
  async createOffer() {
    if (!this.pc) {
      this.createPeerConnection();
    }

    this.isCaller = true;

    // Create reliable, ordered data channel
    // Reliability is achieved by not setting maxRetransmits or maxPacketLifeTime
    this.dataChannel = this.pc.createDataChannel('data_channel', {
      ordered: true
      // No maxRetransmits or maxPacketLifeTime = reliable channel
    });

    this.setupDataChannel();

    // Create offer
    const offer = await this.pc.createOffer();
    await this.pc.setLocalDescription(offer);

    // Wait for ICE gathering to complete (with timeout)
    // If it times out, we'll proceed with the candidates we have
    try {
      await this.waitForIceGathering();
    } catch (error) {
      console.warn('ICE gathering timeout or failed, proceeding with available candidates:', error.message);
      // Continue anyway - we have some candidates and can proceed
    }

    // Return the SDP with all gathered candidates
    return {
      type: 'offer',
      sdp: this.pc.localDescription.sdp
    };
  }

  /**
   * Set remote description from answer
   */
  async setAnswer(answerSdp) {
    if (!this.pc) {
      throw new Error('No peer connection. Create offer first.');
    }

    try {
      console.log('Setting remote description (answer), SDP length:', answerSdp.length);
      await this.pc.setRemoteDescription(new RTCSessionDescription({
        type: 'answer',
        sdp: answerSdp
      }));
      console.log('Remote description set successfully');
      
      // Connection should proceed automatically after setting remote description
      // The data channel should already be set up from createOffer()
      
      // Poll data channel state to detect when it opens
      // Sometimes the onopen event doesn't fire, so we poll as backup
      let pollCount = 0;
      const maxPolls = 20; // Poll for up to 10 seconds (20 * 500ms)
      
      const pollInterval = setInterval(() => {
        pollCount++;
        
        if (this.dataChannel) {
          const state = this.dataChannel.readyState;
          console.log(`Data channel state (poll ${pollCount}):`, state);
          
          if (state === 'open') {
            console.log('✅ Data channel is open (detected via polling)!');
            clearInterval(pollInterval);
            if (this.onDataChannelOpen) {
              this.onDataChannelOpen();
            }
          } else if (state === 'closed') {
            console.log('Data channel is closed');
            clearInterval(pollInterval);
          }
        } else {
          console.warn('⚠️ No data channel found');
        }
        
        if (pollCount >= maxPolls) {
          console.warn('⚠️ Data channel polling timeout - connection may have issues');
          clearInterval(pollInterval);
        }
      }, 500);
    } catch (error) {
      console.error('Error setting remote description:', error);
      throw new Error('Invalid SDP answer: ' + error.message);
    }
  }

  /**
   * Handle incoming offer (when receiving from mobile)
   */
  async handleOffer(offerSdp) {
    if (!this.pc) {
      this.createPeerConnection();
    }

    this.isCaller = false;

    // Set remote description
    await this.pc.setRemoteDescription(new RTCSessionDescription({
      type: 'offer',
      sdp: offerSdp
    }));

    // Setup data channel handler (for when it's created by remote)
    this.pc.ondatachannel = (event) => {
      this.dataChannel = event.channel;
      this.setupDataChannel();
    };

    // Create answer
    const answer = await this.pc.createAnswer();
    await this.pc.setLocalDescription(answer);

    // Wait for ICE gathering (with timeout handling)
    try {
      await this.waitForIceGathering();
    } catch (error) {
      console.warn('ICE gathering timeout or failed, proceeding with available candidates:', error.message);
      // Continue anyway - we have some candidates and can proceed
    }

    // Return the SDP with all gathered candidates
    return {
      type: 'answer',
      sdp: this.pc.localDescription.sdp
    };
  }

  /**
   * Setup data channel event handlers
   */
  setupDataChannel() {
    if (!this.dataChannel) return;

    console.log('Setting up data channel, initial state:', this.dataChannel.readyState);

    this.dataChannel.onopen = () => {
      console.log('✅ Data channel opened (onopen event)');
      if (this.onDataChannelOpen) {
        this.onDataChannelOpen();
      }
    };

    this.dataChannel.onmessage = (event) => {
      console.log('📨 Data channel message received', event.data instanceof ArrayBuffer ? 'binary' : 'text');
      if (this.onDataChannelMessage) {
        // Pass the data as-is (can be string or ArrayBuffer)
        this.onDataChannelMessage(event.data);
      }
      
      // If we receive a message, connection is definitely established
      // This is a backup check in case onopen didn't fire
      if (this.dataChannel.readyState === 'open') {
        console.log('✅ Connection confirmed by receiving message');
      }
    };

    this.dataChannel.onerror = (error) => {
      console.error('❌ Data channel error:', error);
      if (this.onDataChannelError) {
        this.onDataChannelError(error);
      }
    };

    this.dataChannel.onclose = () => {
      console.log('Data channel closed');
      if (this.onDataChannelClose) {
        this.onDataChannelClose();
      }
    };
    
    // Check if already open (might happen if set up after connection established)
    if (this.dataChannel.readyState === 'open') {
      console.log('✅ Data channel is already open!');
      // Use setTimeout to avoid calling callback synchronously
      setTimeout(() => {
        if (this.onDataChannelOpen) {
          this.onDataChannelOpen();
        }
      }, 0);
    } else {
      console.log('Data channel state:', this.dataChannel.readyState, '- waiting for open...');
    }
  }

  /**
   * Wait for ICE gathering to complete
   * Uses a longer timeout and better error handling
   */
  waitForIceGathering() {
    return new Promise((resolve, reject) => {
      // Check if already complete
      if (this.pc.iceGatheringState === 'complete') {
        resolve();
        return;
      }

      // If already failed, reject immediately
      if (this.pc.iceGatheringState === 'failed') {
        reject(new Error('ICE gathering failed'));
        return;
      }

      let timeout;
      let checkInterval;
      let resolved = false;
      const originalIceCandidate = this.pc.onicecandidate;
      const originalGatheringStateChange = this.pc.onicegatheringstatechange;

      const cleanup = () => {
        if (timeout) clearTimeout(timeout);
        if (checkInterval) clearInterval(checkInterval);
        // Restore original handlers
        this.pc.onicecandidate = originalIceCandidate;
        this.pc.onicegatheringstatechange = originalGatheringStateChange;
      };

      // Set a longer timeout (30 seconds) for better network conditions
      timeout = setTimeout(() => {
        if (!resolved) {
          resolved = true;
          cleanup();
          // Don't reject - let the caller decide if we should proceed
          // Some networks may take longer, but we can still work with partial candidates
          resolve();
        }
      }, 30000); // 30 second timeout

      // Handle ICE candidate events - if we get a null candidate, gathering is complete
      const onIceCandidate = (event) => {
        // Call original handler if it exists
        if (originalIceCandidate) {
          originalIceCandidate(event);
        }

        if (event.candidate === null && !resolved) {
          // null candidate means gathering is complete
          resolved = true;
          cleanup();
          resolve();
        }
      };

      // Handle state changes
      const onIceGatheringStateChange = () => {
        if (resolved) return;

        const state = this.pc.iceGatheringState;
        console.log('ICE Gathering State:', state);

        // Call original handler if it exists
        if (originalGatheringStateChange) {
          originalGatheringStateChange();
        }

        if (state === 'complete') {
          resolved = true;
          cleanup();
          resolve();
        } else if (state === 'failed') {
          resolved = true;
          cleanup();
          reject(new Error('ICE gathering failed'));
        }
      };

      // Set up event listeners
      this.pc.onicegatheringstatechange = onIceGatheringStateChange;
      this.pc.onicecandidate = onIceCandidate;

      // Also check periodically in case events don't fire
      checkInterval = setInterval(() => {
        if (resolved) {
          clearInterval(checkInterval);
          return;
        }

        if (this.pc.iceGatheringState === 'complete') {
          resolved = true;
          cleanup();
          resolve();
        } else if (this.pc.iceGatheringState === 'failed') {
          resolved = true;
          cleanup();
          reject(new Error('ICE gathering failed'));
        }
      }, 500); // Check every 500ms
    });
  }

  /**
   * Send message through data channel
   */
  sendMessage(message) {
    if (!this.dataChannel || this.dataChannel.readyState !== 'open') {
      throw new Error('Data channel not open');
    }

    if (typeof message === 'object') {
      message = JSON.stringify(message);
    }

    this.dataChannel.send(message);
  }

  /**
   * Send binary data through data channel
   */
  sendBinary(data) {
    if (!this.dataChannel || this.dataChannel.readyState !== 'open') {
      throw new Error('Data channel not open');
    }

    this.dataChannel.send(data);
  }

  /**
   * Close connection and cleanup
   */
  async close() {
    if (this.dataChannel) {
      this.dataChannel.close();
      this.dataChannel = null;
    }

    if (this.pc) {
      this.pc.close();
      this.pc = null;
    }

    this.isCaller = false;
  }

  /**
   * Check if data channel is open
   */
  isConnected() {
    return this.dataChannel && this.dataChannel.readyState === 'open';
  }
}

// Make WebRTCManager available globally
window.WebRTCManager = WebRTCManager;

