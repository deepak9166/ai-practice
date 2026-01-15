document.getElementById("connect").onclick = async () => {
  const my = myIdInput.value;
  peerId = peerIdInput.value;

  connectSignaling(my);
  createPeer(true);

  const offer = await pc.createOffer();
  await pc.setLocalDescription(offer);
  sendSignal(peerId, "offer", offer);
};

document.getElementById("send").onclick = () =>
  sendMessage(msgInput.value);

document.getElementById("call").onclick = () => startCall();
document.getElementById("screen").onclick = () => startScreenShare();

document.getElementById("file").onchange = e =>
  sendFile(e.target.files[0]);

const myIdInput = document.getElementById("myId");
const peerIdInput = document.getElementById("peerId");
const msgInput = document.getElementById("msg");
