const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";

function listenForPopupClose(args) {
  chrome.windows.onRemoved.addListener((winId) => {
    if (winId !== args.id || args.tabId == null) return;
    chrome.tabs.sendMessage(args.tabId, args.response);
  });
}

function popup(options) {
  return new Promise((resolve) => {
    chrome.windows.getCurrent((currentWindow) => {
      const popupWidth = 400;
      const popupHeight = 600;

      const dualScreenLeft = currentWindow.left ?? 0;
      const dualScreenTop = currentWindow.top ?? 0;

      const width = currentWindow.width ?? 0;
      const height = currentWindow.height ?? 0;

      const left = Math.floor(width / 2 - popupWidth / 2 + dualScreenLeft);
      const top = Math.floor(height / 2 - popupHeight / 2 + dualScreenTop);

      chrome.windows.create(
        {
          url: options.url,
          width: popupWidth,
          height: popupHeight,
          top: top,
          left: left,
          focused: true,
          type: "popup",
        },
        (window) => resolve(window),
      );
    });
  });
}

function getTabIdFromPort(port) {
  return port.sender?.tab?.id;
}

function getOriginFromPort(port) {
  return port.sender?.origin || port.sender?.url;
}

async function rpcGetAddresses(requestId, port) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);

  const window = await popup({
    url: `/index.html#?action=getAddresses:ext,${tabId},${requestId}`,
  });

  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `getAddresses` request",
    },
  });
}

async function rpcSignPsbt(requestId, port, hex, signInputs, sighashTypes) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const encodedSignInputs = btoa(JSON.stringify(signInputs));
  let action;

  // sighashTypes could be undefined
  if (sighashTypes === undefined) {
    action = `signPsbt:ext,${tabId},${requestId},${hex},${encodedSignInputs}`;
  } else {
    const encodedSighashTypes = btoa(JSON.stringify(sighashTypes));
    action = `signPsbt:ext,${tabId},${requestId},${hex},${encodedSignInputs},${encodedSighashTypes}`;
  }

  console.log({ action })


  const window = await popup({
    url: `/index.html#?action=${action}`,
  });

  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `signPsbt` request",
    },
  });
}

async function rpcSignMessage(requestId, port, message, address) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const window = await popup({
    url: `/index.html#?action=signMessage:ext,${tabId},${requestId},${message},${address}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `signMessage` request",
    },
  });
}

async function rpcDispense(address) {
  await popup({ url: `/index.html#?action=dispense:ext,${address}` });
}

async function rpcOpenOrder(giveAsset, giveQuantity, getAsset, getQuantity) {
  await popup({
    url: `/index.html#?action=openOrder:ext,${giveAsset},${giveQuantity},${getAsset},${getQuantity}`,
  });
}

async function rpcFairmint(fairminterTxHash) {
  await popup({
    url: `/index.html#?action=fairmint:ext,${fairminterTxHash}`,
  });
}

async function rpcMessageHandler(message, port) {
  const method = message["method"];
  const tabId = getTabIdFromPort(port);

  if (tabId == null) return;

  switch (method) {
    case "getAddresses":
      await rpcGetAddresses(message["id"], port);
      break;
    case "signPsbt":
      await rpcSignPsbt(
        message["id"],
        port,
        message["params"]["hex"],
        message["params"]["signInputs"],
        message["params"]["sighashTypes"],
      );
      break;
    case "signMessage":
      await rpcSignMessage(
        message["id"],
        port,
        message["params"]["message"],
        message["params"]["address"],
      );
      break;
    case "fairmint":
      await rpcFairmint(message["params"]["fairminterTxHash"]);
      break;
    case "dispense":
      await rpcDispense(message["params"]["address"]);
      break;
    case "openOrder":
      await rpcOpenOrder(
        message["params"]["give_asset"],
        message["params"]["give_quantity"],
        message["params"]["get_asset"],
        message["params"]["get_quantity"],
      );
      break;
    default:
      console.log(`Unknown method: ${message["method"]}`);
  }
}

chrome.runtime.onConnect.addListener((port) => {
  if (port.name !== CONTENT_SCRIPT_PORT) return;

  port.onMessage.addListener((event) => {
    if (!port.sender?.tab?.id) {
      console.warn("Received message from content script with no tab ID");
      return;
    }
    const originUrl = port.sender?.origin || port.sender?.url;

    if (!originUrl) {
      console.warn("No origin");
      return;
    }

    rpcMessageHandler(event, port);
  });
});
