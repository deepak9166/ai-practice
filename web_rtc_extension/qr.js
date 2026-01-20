/**
 * QR Code Module
 * Handles QR code generation and SDP encoding/decoding
 */

class QRManager {
  /**
   * Compress string using CompressionStream API (modern browsers)
   * Falls back to simple encoding if compression not available
   */
  static async compressString(str) {
    // Try using CompressionStream API (Chrome 80+, Edge 80+)
    if (typeof CompressionStream !== 'undefined') {
      try {
        const stream = new CompressionStream('deflate');
        const writer = stream.writable.getWriter();
        const reader = stream.readable.getReader();
        
        const encoder = new TextEncoder();
        const data = encoder.encode(str);
        
        writer.write(data);
        writer.close();
        
        const chunks = [];
        let done = false;
        
        while (!done) {
          const { value, done: readerDone } = await reader.read();
          done = readerDone;
          if (value) {
            chunks.push(value);
          }
        }
        
        const compressed = new Uint8Array(chunks.reduce((acc, chunk) => acc + chunk.length, 0));
        let offset = 0;
        for (const chunk of chunks) {
          compressed.set(chunk, offset);
          offset += chunk.length;
        }
        
        // Convert to base64 - use a more reliable method for large arrays
        let binaryString = '';
        const chunkSize = 8192;
        for (let i = 0; i < compressed.length; i += chunkSize) {
          const chunk = compressed.slice(i, i + chunkSize);
          binaryString += String.fromCharCode.apply(null, chunk);
        }
        return btoa(binaryString);
      } catch (error) {
        console.warn('Compression failed, using uncompressed:', error);
      }
    }
    
    // Fallback: return uncompressed base64
    return btoa(unescape(encodeURIComponent(str)));
  }

  /**
   * Decompress string using DecompressionStream API
   */
  static async decompressString(compressedBase64) {
    // Try using DecompressionStream API
    if (typeof DecompressionStream !== 'undefined') {
      try {
        const stream = new DecompressionStream('deflate');
        const writer = stream.writable.getWriter();
        const reader = stream.readable.getReader();
        
        const binaryString = atob(compressedBase64);
        const data = new Uint8Array(binaryString.length);
        for (let i = 0; i < binaryString.length; i++) {
          data[i] = binaryString.charCodeAt(i);
        }
        
        writer.write(data);
        writer.close();
        
        const chunks = [];
        let done = false;
        
        while (!done) {
          const { value, done: readerDone } = await reader.read();
          done = readerDone;
          if (value) {
            chunks.push(value);
          }
        }
        
        const decompressed = new Uint8Array(chunks.reduce((acc, chunk) => acc + chunk.length, 0));
        let offset = 0;
        for (const chunk of chunks) {
          decompressed.set(chunk, offset);
          offset += chunk.length;
        }
        
        const decoder = new TextDecoder();
        return decoder.decode(decompressed);
      } catch (error) {
        console.warn('Decompression failed, trying uncompressed:', error);
      }
    }
    
    // Fallback: try as uncompressed base64
    try {
      return decodeURIComponent(escape(atob(compressedBase64)));
    } catch (error) {
      throw new Error('Failed to decompress data: ' + error.message);
    }
  }

  /**
   * Filter SDP to reduce size by keeping only essential candidates
   */
  static filterSDP(sdp) {
    const lines = sdp.split('\r\n');
    const filtered = [];
    let inMedia = false;
    let candidateCount = 0;
    const maxCandidatesPerMedia = 3; // Keep only first 3 candidates per media section
    
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i];
      
      // Keep all non-candidate lines
      if (!line.startsWith('a=candidate:')) {
        filtered.push(line);
        if (line.startsWith('m=')) {
          inMedia = true;
          candidateCount = 0;
        } else if (line === '') {
          inMedia = false;
        }
        continue;
      }
      
      // For candidate lines, keep only first few per media section
      if (inMedia && candidateCount < maxCandidatesPerMedia) {
        // Prioritize host candidates (type 0) and srflx candidates (type 1)
        const candidateType = this.getCandidateType(line);
        if (candidateType === 0 || candidateType === 1 || candidateCount === 0) {
          filtered.push(line);
          candidateCount++;
        }
      }
    }
    
    return filtered.join('\r\n');
  }

  /**
   * Get candidate type from candidate line
   * Returns: 0=host, 1=srflx, 2=prflx, 3=relay
   */
  static getCandidateType(candidateLine) {
    const match = candidateLine.match(/typ (\w+)/);
    if (!match) return -1;
    
    const type = match[1].toLowerCase();
    if (type === 'host') return 0;
    if (type === 'srflx') return 1;
    if (type === 'prflx') return 2;
    if (type === 'relay') return 3;
    return -1;
  }

  /**
   * Encode SDP offer/answer as compressed Base64 JSON
   */
  static async encodeSDP(type, sdp, meta = {}) {
    // Filter SDP to reduce size
    const filteredSdp = this.filterSDP(sdp);
    
    const payload = {
      type: type,
      sdp: filteredSdp,
      meta: {
        source: 'chrome_extension',
        version: '1.0.0',
        ...meta
      }
    };

    const jsonString = JSON.stringify(payload);
    console.log('Original JSON data:', jsonString);
    console.log('Original JSON size:', jsonString.length);
    
    // Compress the JSON string
    const compressed = await this.compressString(jsonString);
    console.log('Compressed data:', compressed);
    console.log('Compressed size:', compressed.length);
    console.log('Compression ratio:', (compressed.length / jsonString.length * 100).toFixed(1) + '%');
    
    // Check if compression actually happened (compressed should be smaller)
    // If compression failed or didn't help, use uncompressed
    const uncompressedBase64 = btoa(unescape(encodeURIComponent(jsonString)));
    if (compressed.length >= uncompressedBase64.length) {
      console.warn('Compression did not reduce size, using uncompressed');
      return uncompressedBase64;
    }
    
    // Add compression marker
    return 'z' + compressed; // 'z' prefix indicates compressed data
  }

  /**
   * Decode Base64 JSON to SDP object (handles compressed data)
   */
  static async decodeSDP(base64String) {
    try {
      let jsonString;
      
      // Check if data is compressed (starts with 'z')
      if (base64String.startsWith('z')) {
        const compressedData = base64String.substring(1);
        jsonString = await this.decompressString(compressedData);
      } else {
        // Try uncompressed first
        try {
          jsonString = decodeURIComponent(escape(atob(base64String)));
        } catch (e) {
          // If that fails, try as compressed
          jsonString = await this.decompressString(base64String);
        }
      }
      
      const payload = JSON.parse(jsonString);
      
      if (!payload.type || !payload.sdp) {
        throw new Error('Invalid SDP payload: missing type or sdp');
      }

      return payload;
    } catch (error) {
      throw new Error('Failed to decode SDP: ' + error.message);
    }
  }

  /**
   * Generate QR code and render to element
   */
  static async generateQR(data, elementId, options = {}) {
    const element = document.getElementById(elementId);
    if (!element) {
      throw new Error(`Element with id "${elementId}" not found`);
    }

    // Clear previous QR code
    element.innerHTML = '';

    const defaultOptions = {
      width: 256,
      height: 256,
      colorDark: '#000000',
      colorLight: '#ffffff',
      errorCorrectionLevel: 'M' // 'L', 'M', 'Q', or 'H'
    };

    const qrOptions = { ...defaultOptions, ...options };

    return new Promise((resolve, reject) => {
      try {
        // Check if QRCode library is loaded
        if (typeof QRCode === 'undefined') {
          reject(new Error('QRCode library not loaded'));
          return;
        }

        // Try using QRCode.toCanvas API (browser API)
        if (QRCode.toCanvas) {
          // Create canvas element
          const canvas = document.createElement('canvas');
          element.appendChild(canvas);
          
          QRCode.toCanvas(canvas, data, {
            width: qrOptions.width,
            colorDark: qrOptions.colorDark,
            colorLight: qrOptions.colorLight,
            errorCorrectionLevel: qrOptions.errorCorrectionLevel
          }, (error) => {
            if (error) {
              reject(error);
            } else {
              resolve();
            }
          });
        } else {
          // Fallback: try using QRCode.create and manual rendering
          try {
            const qrData = QRCode.create(data, {
              errorCorrectionLevel: qrOptions.errorCorrectionLevel
            });
            
            // Create canvas and render manually
            const canvas = document.createElement('canvas');
            const ctx = canvas.getContext('2d');
            const size = qrData.modules.size;
            const moduleCount = size;
            const tileW = qrOptions.width / moduleCount;
            const tileH = qrOptions.width / moduleCount;
            
            canvas.width = qrOptions.width;
            canvas.height = qrOptions.width;
            
            // Fill background
            ctx.fillStyle = qrOptions.colorLight;
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            
            // Draw modules
            ctx.fillStyle = qrOptions.colorDark;
            for (let row = 0; row < moduleCount; row++) {
              for (let col = 0; col < moduleCount; col++) {
                if (qrData.modules.get(row, col)) {
                  ctx.fillRect(col * tileW, row * tileH, tileW, tileH);
                }
              }
            }
            
            element.appendChild(canvas);
            resolve();
          } catch (createError) {
            reject(new Error('Failed to create QR code: ' + createError.message));
          }
        }
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * Generate QR code from SDP offer
   */
  static async generateOfferQR(offerSdp, elementId) {
    const base64 = await this.encodeSDP('offer', offerSdp);
    await this.generateQR(base64, elementId);
    return base64;
  }

  /**
   * Generate QR code from SDP answer
   */
  static async generateAnswerQR(answerSdp, elementId) {
    const base64 = await this.encodeSDP('answer', answerSdp);
    await this.generateQR(base64, elementId);
    return base64;
  }
}

// Make QRManager available globally
window.QRManager = QRManager;

