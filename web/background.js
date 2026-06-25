const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";

function safeBtoaJson(value) {
  // Convert Dates to ISO strings; drop undefined
  const replacer = (_, v) => (v instanceof Date ? v.toISOString() : v);
  const json = JSON.stringify(value, replacer);
  // Encode UTF-8 safely before btoa
  return btoa(unescape(encodeURIComponent(json)));
}

// URL-safe base64 of an arbitrary UTF-8 string. Uses the "b64:" prefix so the
// Dart parser can unambiguously distinguish encoded payloads from legacy
// percent-encoded values. The output never contains characters that would be
// re-interpreted by URL parsers ("+", "/", "&", "%") so it survives any
// re-encoding done by Chrome/GoRouter on the popup URL.
function encodeFreeText(s) {
  const str = s == null ? "" : String(s);
  const stdB64 = btoa(unescape(encodeURIComponent(str)));
  const urlSafe = stdB64
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/, "");
  return "b64:" + urlSafe;
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
  // Nothing to watch if the popup failed to open.
  if (args.id == null) return;
  const handler = (winId) => {
    if (winId !== args.id) return;
    // Our popup closed: detach this listener before doing anything else.
    // Without removal every RPC call would leak a permanent onRemoved listener
    // (they accumulate for the life of the service worker). Only the matching
    // window's close removes it, so unrelated popups keep their own listeners.
    chrome.windows.onRemoved.removeListener(handler);
    if (args.tabId != null) {
      chrome.tabs.sendMessage(args.tabId, args.response);
    }
  };
  chrome.windows.onRemoved.addListener(handler);
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
    url: `/index.html#?action=getAddresses,${tabId},${requestId},${encodeURIComponent(origin)},${encodeFreeText(metadata.title)},${encodeFreeText(metadata.favicon)}`,
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
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
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
    url: `/index.html#?action=signMessage,${tabId},${requestId},${encodeURIComponent(origin)},${encodeFreeText(metadata.title)},${encodeFreeText(metadata.favicon)},${encodeFreeText(message)},${address}`,
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

async function rpcSignMessageBLS(requestId, port, message, dst, messageHex, address) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const params = [
    "signMessageBLS",
    tabId,
    requestId,
    encodeURIComponent(origin),
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
    encodeFreeText(message || ""),
    encodeURIComponent(dst || ""),
    encodeURIComponent(messageHex || ""),
    encodeURIComponent(address || ""),
  ];

  const window = await popup({
    url: `/index.html#?action=${params.join(",")}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `signMessageBLS` request",
    },
  });
}

async function rpcGetBLSPoP(requestId, port, address) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const params = [
    "getBLSPoP",
    tabId,
    requestId,
    encodeURIComponent(origin),
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
    encodeURIComponent(address),
  ];

  const window = await popup({
    url: `/index.html#?action=${params.join(",")}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `getBLSPoP` request",
    },
  });
}

async function rpcExportEncryptedBlsPrivateKey(requestId, port, address) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const params = [
    "exportEncryptedBlsPrivateKey",
    tabId,
    requestId,
    encodeURIComponent(origin),
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
    encodeURIComponent(address || ""),
  ];

  const window = await popup({
    url: `/index.html#?action=${params.join(",")}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `exportEncryptedBlsPrivateKey` request",
    },
  });
}

async function rpcGetBalance(requestId, port, address) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const params = [
    "getBalance",
    tabId,
    requestId,
    encodeURIComponent(origin ?? ""),
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
    encodeFreeText(address || ""),
  ];

  const window = await popup({
    url: `/index.html#?action=${params.join(",")}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `getBalance` request",
    },
  });
}

async function rpcSendTransfer(requestId, port, destination, amount) {
  const origin = getOriginFromPort(port);
  const tabId = getTabIdFromPort(port);
  const metadata = await getTabMetadata(tabId);

  const params = [
    "sendTransfer",
    tabId,
    requestId,
    encodeURIComponent(origin ?? ""),
    encodeFreeText(metadata.title),
    encodeFreeText(metadata.favicon),
    encodeFreeText(destination || ""),
    amount, // integer (satoshis), URL-safe as-is
  ];

  const window = await popup({
    url: `/index.html#?action=${params.join(",")}`,
  });
  listenForPopupClose({
    id: window?.id,
    tabId: tabId,
    response: {
      id: requestId,
      error: "User rejected `sendTransfer` request",
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
    case "signMessageBLS":
      await rpcSignMessageBLS(
        message["id"],
        port,
        message["params"]["message"],
        message["params"]["dst"],
        message["params"]["messageHex"],
        message["params"]["address"],
      );
      break;
    case "getBLSPoP":
      await rpcGetBLSPoP(
        message["id"],
        port,
        message["params"]["address"],
      );
      break;
    case "exportEncryptedBlsPrivateKey":
      await rpcExportEncryptedBlsPrivateKey(
        message["id"],
        port,
        message["params"]?.["address"],
      );
      break;
    case "getBalance":
      await rpcGetBalance(
        message["id"],
        port,
        message["params"]?.["address"],
      );
      break;
    case "sendTransfer":
      await rpcSendTransfer(
        message["id"],
        port,
        message["params"]?.["destination"],
        message["params"]?.["amount"],
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
