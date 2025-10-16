const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";

function safeBtoaJson(value) {
  // Convert Dates to ISO strings; drop undefined
  const replacer = (_, v) => (v instanceof Date ? v.toISOString() : v);
  const json = JSON.stringify(value, replacer);
  // Encode UTF-8 safely before btoa
  return btoa(unescape(encodeURIComponent(json)));
}

function encodeTransactionInfo(transactionInfo) {
  if (!transactionInfo) return undefined;
  try {
    return safeBtoaJson(transactionInfo);
  } catch (e) {
    console.warn("Failed to encode transactionInfo:", e);
    return undefined;
  }
}

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

async function getTabMetadata(tabId) {
  try {
    const tab = await chrome.tabs.get(tabId);

    let faviconUrl = tab.favIconUrl || "";

    if (!faviconUrl && tab.url) {
      try {
        const url = new URL(tab.url);
        const faviconPaths = [
          "/favicon.svg",
          "/favicon.png",
          "/favicon.ico",
          "/apple-touch-icon.png",
        ];

        faviconUrl = `${url.protocol}//${url.hostname}${faviconPaths[0]}`;
      } catch (e) {
        console.warn("Could not construct favicon URL:", e);
      }
    }

    if (!faviconUrl && tab.url) {
      console.log("No favicon found for:", tab.url);
    }

    return {
      title: tab.title || "",
      favicon: faviconUrl,
    };
  } catch (error) {
    console.warn("Failed to get tab metadata:", error);
    return {
      title: "",
      favicon: "",
    };
  }
}

async function rpcGetAddresses(requestId, port) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const window = await popup({
    url: `/index.html#?action=getAddresses,${tabId},${requestId},${encodeURIComponent(origin)},${encodeURIComponent(metadata.title)},${encodeURIComponent(metadata.favicon)}`,
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

async function rpcSignPsbt(
  requestId,
  port,
  hex,
  signInputs,
  sighashTypes,
  transactionInfo,
) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  // Encode required/optional payloads
  const encodedSignInputs = safeBtoaJson(signInputs);
  const encodedSighashTypes =
    sighashTypes === undefined ? undefined : safeBtoaJson(sighashTypes);
  const encodedTxInfo = encodeTransactionInfo(transactionInfo);

  // Build param list in a backward-compatible order:
  // signPsbt,tabId,requestId,origin,title,favicon,hex,signInputs[,sighashTypes][,transactionInfo]
  const params = [
    "signPsbt",
    tabId,
    requestId,
    encodeURIComponent(origin ?? ""),
    encodeURIComponent(metadata.title ?? ""),
    encodeURIComponent(metadata.favicon ?? ""),
    hex, // already hex-safe for URLs
    encodedSignInputs,
  ];

  if (encodedSighashTypes !== undefined) params.push(encodedSighashTypes);
  if (encodedTxInfo !== undefined) params.push(encodedTxInfo);

  const action = params.join(",");

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
  const metadata = await getTabMetadata(tabId);
  const window = await popup({
    url: `/index.html#?action=signMessage,${tabId},${requestId},${encodeURIComponent(origin)},${encodeURIComponent(metadata.title)},${encodeURIComponent(metadata.favicon)},${message},${address}`,
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
        message["params"]["transactionInfo"],
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
