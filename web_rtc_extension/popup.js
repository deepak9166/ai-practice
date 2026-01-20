/**
 * Main Popup Script
 * Coordinates all modules and handles UI interactions
 */

class ExtensionApp {
  constructor() {
    this.webrtc = new WebRTCManager();
    this.chat = new ChatManager('chatMessages');
    this.fileTransfer = new FileTransferManager(this.webrtc, this.chat);
    
    this.currentOffer = null;
    this.currentCompressedCode = null; // Store the compressed code
    this.isConnected = false;
    
    this.setupEventListeners();
    this.setupWebRTCCallbacks();
    this.setupFileTransferCallbacks();
  }

  setupEventListeners() {
    // Create offer button
    document.getElementById('createOfferBtn').addEventListener('click', () => {
      this.createOffer();
    });

    // Enter answer button
    document.getElementById('enterAnswerBtn').addEventListener('click', () => {
      this.showAnswerInput();
    });

    // Submit answer button
    document.getElementById('submitAnswerBtn').addEventListener('click', () => {
      this.submitAnswer();
    });

    // Regenerate QR button
    document.getElementById('regenerateBtn').addEventListener('click', () => {
      this.createOffer();
    });

    // Copy code button
    document.getElementById('copyCodeBtn').addEventListener('click', () => {
      this.copyCompressedCode();
    });

    // Send message button
    document.getElementById('sendMessageBtn').addEventListener('click', () => {
      this.sendChatMessage();
    });

    // Enter key in message input
    document.getElementById('messageInput').addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        this.sendChatMessage();
      }
    });

    // File input change
    document.getElementById('fileInput').addEventListener('change', (e) => {
      const file = e.target.files[0];
      if (file) {
        document.getElementById('sendFileBtn').disabled = false;
      }
    });

    // Send file button
    document.getElementById('sendFileBtn').addEventListener('click', () => {
      this.sendFile();
    });
  }

  setupWebRTCCallbacks() {
    this.webrtc.onConnectionStateChange = (state) => {
      this.updateConnectionStatus(state);
    };

    this.webrtc.onDataChannelOpen = () => {
      this.onConnected();
    };

    this.webrtc.onDataChannelMessage = (data) => {
      this.handleIncomingData(data);
    };

    this.webrtc.onDataChannelError = (error) => {
      this.showError('Data channel error: ' + error.message);
    };

    this.webrtc.onDataChannelClose = () => {
      this.onDisconnected();
    };
  }

  setupFileTransferCallbacks() {
    this.fileTransfer.onFileProgress = (progress, sent, total) => {
      this.updateFileProgress(progress, sent, total);
    };

    this.fileTransfer.onFileReceived = (status, data) => {
      if (status === 'complete') {
        this.handleReceivedFile(data);
      } else if (status === 'error') {
        this.showError('File transfer error: ' + data.error);
      }
    };
  }

  async createOffer() {
    try {
      this.showLoading('Creating offer...');
      
      const offer = await this.webrtc.createOffer();
      this.currentOffer = offer;

      // Encode and generate QR (encodeSDP is now async)
      const base64 = await QRManager.encodeSDP('offer', offer.sdp);
      this.currentCompressedCode = base64; // Store the compressed code
      
      await QRManager.generateQR(base64, 'qrCode');

      // Show QR container
      document.getElementById('qrContainer').style.display = 'block';
      document.getElementById('answerContainer').style.display = 'none';
      document.getElementById('initialActions').style.display = 'none';

      // Display the compressed code in the textarea
      document.getElementById('compressedCodeDisplay').value = base64;

      this.updateConnectionStatus('connecting');
      this.hideError();
    } catch (error) {
      console.error('Error creating offer:', error);
      this.showError('Failed to create offer: ' + error.message);
    }
  }

  copyCompressedCode() {
    const codeTextarea = document.getElementById('compressedCodeDisplay');
    const copyBtn = document.getElementById('copyCodeBtn');
    const copyBtnText = document.getElementById('copyCodeBtnText');
    
    if (!this.currentCompressedCode) {
      this.showError('No code available to copy');
      return;
    }

    codeTextarea.select();
    codeTextarea.setSelectionRange(0, 99999); // For mobile devices

    try {
      document.execCommand('copy');
      copyBtnText.textContent = 'Copied!';
      copyBtn.style.backgroundColor = '#4CAF50';
      
      setTimeout(() => {
        copyBtnText.textContent = 'Copy Code';
        copyBtn.style.backgroundColor = '';
      }, 2000);
    } catch (err) {
      // Fallback: use Clipboard API
      navigator.clipboard.writeText(this.currentCompressedCode).then(() => {
        copyBtnText.textContent = 'Copied!';
        copyBtn.style.backgroundColor = '#4CAF50';
        
        setTimeout(() => {
          copyBtnText.textContent = 'Copy Code';
          copyBtn.style.backgroundColor = '';
        }, 2000);
      }).catch((error) => {
        console.error('Failed to copy:', error);
        this.showError('Failed to copy code. Please select and copy manually.');
      });
    }
  }

  showAnswerInput() {
    document.getElementById('qrContainer').style.display = 'none';
    document.getElementById('answerContainer').style.display = 'block';
    document.getElementById('initialActions').style.display = 'none';
  }

  async submitAnswer() {
    try {
      const answerText = document.getElementById('answerInput').value.trim();
      if (!answerText) {
        this.showError('Please enter an SDP answer');
        return;
      }

      this.showLoading('Processing answer...');

      // Try to decode as Base64 JSON first (decodeSDP is now async)
      let answerPayload;
      try {
        answerPayload = await QRManager.decodeSDP(answerText);
      } catch (error) {
        // If not Base64, try parsing as JSON directly
        try {
          answerPayload = JSON.parse(answerText);
        } catch (e) {
          throw new Error('Invalid SDP format. Expected Base64 JSON or JSON object.');
        }
      }

      if (answerPayload.type !== 'answer') {
        throw new Error('Invalid SDP type. Expected "answer".');
      }

      await this.webrtc.setAnswer(answerPayload.sdp);
      this.hideError();
      this.updateConnectionStatus('connecting');
    } catch (error) {
      console.error('Error setting answer:', error);
      this.showError('Failed to process answer: ' + error.message);
    }
  }

  onConnected() {
    this.isConnected = true;
    this.updateConnectionStatus('connected');
    
    // Show chat and file sections
    document.getElementById('chatSection').style.display = 'block';
    document.getElementById('fileSection').style.display = 'block';
    
    // Hide connection UI
    document.getElementById('qrContainer').style.display = 'none';
    document.getElementById('answerContainer').style.display = 'none';
    document.getElementById('initialActions').style.display = 'none';
  }

  onDisconnected() {
    this.isConnected = false;
    this.updateConnectionStatus('disconnected');
    
    // Hide chat and file sections
    document.getElementById('chatSection').style.display = 'none';
    document.getElementById('fileSection').style.display = 'none';
    
    // Show initial actions
    document.getElementById('initialActions').style.display = 'block';
  }

  updateConnectionStatus(state) {
    const indicator = document.getElementById('statusIndicator');
    const statusText = document.getElementById('statusText');
    const dot = indicator.querySelector('.status-dot');

    // Remove all state classes
    dot.classList.remove('connected', 'disconnected', 'connecting');

    switch (state) {
      case 'connected':
      case 'completed':
        dot.classList.add('connected');
        statusText.textContent = 'Connected';
        break;
      case 'connecting':
      case 'checking':
        dot.classList.add('connecting');
        statusText.textContent = 'Connecting...';
        break;
      case 'disconnected':
      case 'closed':
      case 'failed':
        dot.classList.add('disconnected');
        statusText.textContent = state === 'failed' ? 'Connection Failed' : 'Disconnected';
        break;
      default:
        dot.classList.add('disconnected');
        statusText.textContent = 'Disconnected';
    }
  }

  handleIncomingData(data) {
    // Handle binary data (file chunks)
    if (data instanceof ArrayBuffer) {
      this.fileTransfer.handleFileData(data);
      return;
    }

    // Handle string data
    let message;
    try {
      if (typeof data === 'string') {
        message = JSON.parse(data);
      } else {
        message = data;
      }
    } catch (error) {
      // Not JSON, treat as plain text
      message = {
        type: 'chat',
        message: data,
        timestamp: Math.floor(Date.now() / 1000),
        sender: 'peer'
      };
    }

    // Handle different message types
    if (message.type === 'chat') {
      this.chat.displayMessage(message);
    } else if (message.type === 'file_meta' || message.type === 'file_complete') {
      this.fileTransfer.handleFileData(data);
    } else {
      // Unknown message type, display as chat
      this.chat.displayMessage(message);
    }
  }

  sendChatMessage() {
    const input = document.getElementById('messageInput');
    const message = input.value.trim();

    if (!message) return;
    if (!this.webrtc.isConnected()) {
      this.showError('Not connected. Please establish connection first.');
      return;
    }

    try {
      const chatMessage = ChatManager.createMessage(message, 'extension');
      this.webrtc.sendMessage(JSON.stringify(chatMessage));
      this.chat.displayMessage(chatMessage);
      input.value = '';
    } catch (error) {
      this.showError('Failed to send message: ' + error.message);
    }
  }

  async sendFile() {
    const fileInput = document.getElementById('fileInput');
    const file = fileInput.files[0];

    if (!file) {
      this.showError('Please select a file');
      return;
    }

    if (!this.webrtc.isConnected()) {
      this.showError('Not connected. Please establish connection first.');
      return;
    }

    try {
      // Show progress
      document.getElementById('fileProgress').style.display = 'block';
      document.getElementById('sendFileBtn').disabled = true;

      await this.fileTransfer.sendFile(file);

      this.showSuccess(`File "${file.name}" sent successfully`);
      fileInput.value = '';
      document.getElementById('sendFileBtn').disabled = true;
    } catch (error) {
      this.showError('Failed to send file: ' + error.message);
    } finally {
      document.getElementById('sendFileBtn').disabled = false;
    }
  }

  updateFileProgress(progress, sent, total) {
    const progressFill = document.getElementById('progressFill');
    const progressText = document.getElementById('progressText');

    progressFill.style.width = `${progress}%`;
    progressText.textContent = `${Math.round(progress)}% (${this.formatBytes(sent)} / ${this.formatBytes(total)})`;
  }

  handleReceivedFile(fileData) {
    const receivedFiles = document.getElementById('receivedFiles');
    
    const fileItem = document.createElement('div');
    fileItem.className = 'file-item';
    
    const fileName = document.createElement('span');
    fileName.className = 'file-item-name';
    fileName.textContent = `${fileData.name} (${this.formatBytes(fileData.size)})`;
    
    const downloadBtn = document.createElement('button');
    downloadBtn.className = 'btn btn-primary download-btn';
    downloadBtn.textContent = 'Download';
    downloadBtn.addEventListener('click', () => {
      const a = document.createElement('a');
      a.href = fileData.url;
      a.download = fileData.name;
      a.click();
      URL.revokeObjectURL(fileData.url);
    });

    fileItem.appendChild(fileName);
    fileItem.appendChild(downloadBtn);
    receivedFiles.appendChild(fileItem);

    this.showSuccess(`File "${fileData.name}" received`);
  }

  formatBytes(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }

  showError(message) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    errorDiv.className = 'error-message';
    
    setTimeout(() => {
      errorDiv.style.display = 'none';
    }, 5000);
  }

  showSuccess(message) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    errorDiv.className = 'success-message';
    
    setTimeout(() => {
      errorDiv.style.display = 'none';
    }, 3000);
  }

  showLoading(message) {
    const errorDiv = document.getElementById('errorMessage');
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    errorDiv.className = 'success-message';
  }

  hideError() {
    document.getElementById('errorMessage').style.display = 'none';
  }
}

// Initialize app when DOM is ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    new ExtensionApp();
  });
} else {
  new ExtensionApp();
}

