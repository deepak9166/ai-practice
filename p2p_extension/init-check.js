// Initialize check scripts - moved from inline to external file for CSP compliance
(function() {
  // Verify PeerJS loaded immediately after script tag
  if (typeof Peer === 'undefined') {
    console.error('❌ PeerJS library failed to load from CDN');
    console.error('This might be due to network issues or CDN being blocked');
  } else {
    console.log('✅ PeerJS library loaded successfully');
    console.log('Peer constructor available:', typeof Peer);
  }
  
  // Verify QRCode loaded
  if (typeof QRCode === 'undefined') {
    console.error('❌ QRCode library failed to load');
  } else {
    console.log('✅ QRCode library loaded successfully');
  }
})();
