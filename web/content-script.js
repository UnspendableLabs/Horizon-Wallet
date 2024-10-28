const CONTENT_SCRIPT_PORT = "content-script";
const MESSAGE_SOURCE = "horizon-marketplace";

let backgroundPort = null;

function connect() {
  backgroundPort = chrome.runtime.connect({ name: CONTENT_SCRIPT_PORT });
  backgroundPort.onDisconnect.addListener(connect);
}

connect();

function sendMessageToBackground(message) {
  backgroundPort.postMessage(message);
}

chrome.runtime.onMessage.addListener((message) => {
  // TODO: refine this guard
  if (message.source === MESSAGE_SOURCE) {
    sendMessageToBackground(message);
  }
});

function forwardDomEventToBackground({ payload, method }) {
  sendMessageToBackground({
    source: MESSAGE_SOURCE,
    payload,
    method,
  });
}

document.addEventListener("request", (event) => {
  sendMessageToBackground({ source: MESSAGE_SOURCE, ...event.detail });
});

function addProviderToPage() {
  const inpage = document.createElement("script");
  inpage.src = chrome.runtime.getURL("inpage.js");
  inpage.id = "horizon-wallet-provider";
  document.body.appendChild(inpage);
}

requestAnimationFrame(addProviderToPage);
