/**
 * Background Service Worker
 * Minimal background script for Chrome Extension
 */

// Listen for extension installation
chrome.runtime.onInstalled.addListener(() => {
  console.log('WebRTC Extension installed');
});

// Handle any background tasks if needed
chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === 'ping') {
    sendResponse({ status: 'ok' });
  }
  return true;
});

