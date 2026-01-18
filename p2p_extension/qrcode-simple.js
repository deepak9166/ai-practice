// Simple QR Code generator for Chrome Extension
// Based on QRCode.js but simplified for extension use
(function() {
  'use strict';

  // QR Code generation functions
  const QRCode = {
    toCanvas: function(canvas, text, options) {
      options = options || {};
      const width = options.width || 250;
      const margin = options.margin || 2;
      const colorDark = options.color?.dark || '#000000';
      const colorLight = options.color?.light || '#FFFFFF';

      // Return a promise
      return new Promise(function(resolve, reject) {
        // Set canvas size
        const size = width;
        canvas.width = size;
        canvas.height = size;
        const ctx = canvas.getContext('2d');
        
        // Fill background
        ctx.fillStyle = colorLight;
        ctx.fillRect(0, 0, size, size);
        
        // Use QR Server API (works in extensions with proper permissions)
        const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${encodeURIComponent(text)}`;
        
        const img = new Image();
        img.crossOrigin = 'anonymous';
        
        img.onload = function() {
          ctx.drawImage(img, 0, 0, size, size);
          resolve();
        };
        
        img.onerror = function(error) {
          // Fallback: Draw text if image fails
          ctx.fillStyle = colorDark;
          ctx.font = '12px Arial';
          ctx.textAlign = 'center';
          ctx.fillText('QR Code', size / 2, size / 2 - 10);
          ctx.fillText('(Load failed)', size / 2, size / 2 + 10);
          reject(error || new Error('Failed to load QR code'));
        };
        
        img.src = qrUrl;
      });
    }
  };

  // Make QRCode available globally
  if (typeof window !== 'undefined') {
    window.QRCode = QRCode;
  }
})();
