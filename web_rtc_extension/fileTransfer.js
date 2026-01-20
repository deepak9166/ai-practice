/**
 * File Transfer Module
 * Handles file sending and receiving with chunking
 */

class FileTransferManager {
  constructor(webrtcManager, chatManager) {
    this.webrtcManager = webrtcManager;
    this.chatManager = chatManager;
    this.receivedFiles = new Map(); // Store received file chunks
    this.sendingFile = null;
    this.receivingFile = null;
    
    // Callbacks
    this.onFileProgress = null;
    this.onFileReceived = null;
  }

  /**
   * Send file through data channel
   */
  async sendFile(file) {
    if (!this.webrtcManager.isConnected()) {
      throw new Error('Data channel not connected');
    }

    this.sendingFile = {
      file: file,
      totalSize: file.size,
      sentSize: 0
    };

    try {
      // Send file metadata first
      const metadata = {
        type: 'file_meta',
        name: file.name,
        size: file.size,
        mime: file.type || 'application/octet-stream'
      };

      this.webrtcManager.sendMessage(JSON.stringify(metadata));

      // Read file and send in chunks
      const chunkSize = 16 * 1024; // 16KB chunks
      const reader = new FileReader();
      let offset = 0;

      return new Promise((resolve, reject) => {
        reader.onerror = () => reject(new Error('File read error'));

        reader.onload = (e) => {
          const chunk = new Uint8Array(e.target.result);
          
          try {
            // Send chunk as binary
            this.webrtcManager.sendBinary(chunk);
            
            this.sendingFile.sentSize += chunk.length;
            
            // Update progress
            if (this.onFileProgress) {
              const progress = (this.sendingFile.sentSize / this.sendingFile.totalSize) * 100;
              this.onFileProgress(progress, this.sendingFile.sentSize, this.sendingFile.totalSize);
            }

            offset += chunk.length;

            if (offset < file.size) {
              // Read next chunk
              const blob = file.slice(offset, offset + chunkSize);
              reader.readAsArrayBuffer(blob);
            } else {
              // Send completion signal
              const completion = {
                type: 'file_complete',
                name: file.name
              };
              this.webrtcManager.sendMessage(JSON.stringify(completion));
              
              this.sendingFile = null;
              resolve();
            }
          } catch (error) {
            this.sendingFile = null;
            reject(error);
          }
        };

        // Start reading first chunk
        const blob = file.slice(0, chunkSize);
        reader.readAsArrayBuffer(blob);
      });
    } catch (error) {
      this.sendingFile = null;
      throw error;
    }
  }

  /**
   * Handle incoming file data
   */
  handleFileData(data) {
    // Check if it's a JSON message
    if (typeof data === 'string') {
      try {
        const message = JSON.parse(data);
        
        if (message.type === 'file_meta') {
          // Start receiving a new file
          this.receivingFile = {
            name: message.name,
            size: message.size,
            mime: message.mime,
            chunks: [],
            receivedSize: 0
          };
          
          if (this.onFileReceived) {
            this.onFileReceived('start', this.receivingFile);
          }
          return;
        }
        
        if (message.type === 'file_complete') {
          // File transfer complete, reassemble
          if (this.receivingFile) {
            this.reassembleFile();
          }
          return;
        }
      } catch (error) {
        // Not JSON, might be part of file data
      }
    }

    // Handle binary data (file chunks)
    if (this.receivingFile) {
      if (data instanceof ArrayBuffer) {
        const chunk = new Uint8Array(data);
        this.receivingFile.chunks.push(chunk);
        this.receivingFile.receivedSize += chunk.length;

        // Update progress
        if (this.onFileProgress) {
          const progress = (this.receivingFile.receivedSize / this.receivingFile.size) * 100;
          this.onFileProgress(progress, this.receivingFile.receivedSize, this.receivingFile.size);
        }
      } else if (data instanceof Blob) {
        // Convert Blob to ArrayBuffer
        data.arrayBuffer().then(buffer => {
          const chunk = new Uint8Array(buffer);
          this.receivingFile.chunks.push(chunk);
          this.receivingFile.receivedSize += chunk.length;

          if (this.onFileProgress) {
            const progress = (this.receivingFile.receivedSize / this.receivingFile.size) * 100;
            this.onFileProgress(progress, this.receivingFile.receivedSize, this.receivingFile.size);
          }
        });
      }
    }
  }

  /**
   * Reassemble received file chunks
   */
  reassembleFile() {
    if (!this.receivingFile) return;

    try {
      // Combine all chunks
      const totalSize = this.receivingFile.chunks.reduce((sum, chunk) => sum + chunk.length, 0);
      const fileData = new Uint8Array(totalSize);
      let offset = 0;

      for (const chunk of this.receivingFile.chunks) {
        fileData.set(chunk, offset);
        offset += chunk.length;
      }

      // Create blob and trigger download
      const blob = new Blob([fileData], { type: this.receivingFile.mime });
      const url = URL.createObjectURL(blob);
      
      if (this.onFileReceived) {
        this.onFileReceived('complete', {
          name: this.receivingFile.name,
          size: this.receivingFile.size,
          mime: this.receivingFile.mime,
          blob: blob,
          url: url
        });
      }

      // Cleanup
      this.receivingFile = null;
    } catch (error) {
      console.error('Error reassembling file:', error);
      if (this.onFileReceived) {
        this.onFileReceived('error', { error: error.message });
      }
      this.receivingFile = null;
    }
  }

  /**
   * Reset file transfer state
   */
  reset() {
    this.sendingFile = null;
    this.receivingFile = null;
    this.receivedFiles.clear();
  }
}

// Make FileTransferManager available globally
window.FileTransferManager = FileTransferManager;

