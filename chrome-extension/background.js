importScripts("db.js");

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === "FETCH_API") {
    fetch("https://jsonplaceholder.typicode.com/users")
      .then(res => res.json())
      .then(async data => {
        await saveData(data);
        sendResponse({ success: true });
      })
      .catch(err => {
        sendResponse({ success: false, error: err.message });
      });

    return true;
  }
});
