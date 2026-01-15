// Keeps service worker alive during signaling
chrome.runtime.onInstalled.addListener(() => {
  console.log("P2P Extension Installed");
});
