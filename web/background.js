const CONTENT_SCRIPT_PORT = "content-script";

export function getTabIdFromPort(port) {
  return port?.sender?.tab?.id;
}

function rpcMessageHandler(message, port) {
  // TODO: listen for origin tab close
  //

  const id = getTabIdFromPort(port);

  switch (message.method) {
    case "ping":
      chrome.tabs.sendMessage(getTabIdFromPort(port), {
        msg: "pong",
        id: message.id,
      });
      break;
    case "getAddresses":
      chrome.tabs.sendMessage(getTabIdFromPort(port), {
          addresses: [{ address: "0xdeadbeef", type: "p2wpkh" }],
          id: message.id,
      });
      break;
    default:
      console.log("unknown method", message.method);
  }
}

chrome.runtime.onConnect.addListener((port) => {
  if (port.name !== CONTENT_SCRIPT_PORT) return;

  port.onMessage.addListener((message, port) => {
    console.log(
      "message received in background script at port: " + port,
      message,
    );

    // if (getTabIdFromPort(port)) {
    //   console.error(
    //     "message reached background script :ithout a corresponding tab",
    //   );
    //   return;
    // }

    // Chromium/Firefox discrepancy
    const originUrl = port.sender?.origin ?? port.sender?.url;

    if (!originUrl) {
      console.error("message reached background script without a valid origin");
      return;
    }

    return rpcMessageHandler(message, port);
  });
});
