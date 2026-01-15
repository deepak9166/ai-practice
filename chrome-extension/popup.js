document.getElementById("fetch").addEventListener("click", () => {
  chrome.runtime.sendMessage(
    { type: "FETCH_API" },
    (response) => {
      if (response.success) {
        loadData();
      }
    }
  );
});

async function loadData() {
  const db = await indexedDB.open("MyExtensionDB");

  db.onsuccess = () => {
    const database = db.result;
    const tx = database.transaction("users", "readonly");
    const store = tx.objectStore("users");
    const req = store.getAll();

    req.onsuccess = () => {
      const list = document.getElementById("list");
      list.innerHTML = "";

      req.result.forEach(user => {
        const li = document.createElement("li");
        li.textContent = user.name;
        list.appendChild(li);
      });
    };
  };
}
