const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";
const MESSAGE_SOURCE = "horizon";
const VALID_METHODS = [
  "getAddresses",
  "signPsbt",
  "signMessage",
  "signMessageBLS",
  "getBLSPoP",
  "exportEncryptedBlsPrivateKey",
  "getBalance",
  "sendTransfer",
  "fairmint",
  "dispense",
  "openOrder",
];

let backgroundPort = null;

function connect() {
  backgroundPort = chrome.runtime.connect({ name: CONTENT_SCRIPT_PORT });
  backgroundPort.onDisconnect.addListener(connect);
}

connect();

function sendMessageToBackground(message) {
  if (backgroundPort) {
    backgroundPort.postMessage(message);
  } else {
    console.error("Background port is not connected.");
  }
}

chrome.runtime.onMessage.addListener((message) => {
  window.postMessage(message, window.location.origin);
});

function forwardDomEventToBackground({ payload, method }) {
  sendMessageToBackground({
    source: MESSAGE_SOURCE,
    payload,
    method,
  });
}

const methodValidators = {
  signPsbt: (msg) => {
    const errors = [];

    // Validate 'hex'
    if (!msg.params?.hex || typeof msg.params.hex !== "string") {
      errors.push(
        "Missing or invalid 'hex' parameter for 'signPsbt'. Expected a string.",
      );
    }

    // Validate 'signInputs'
    const signInputs = msg.params?.signInputs;
    if (
      !signInputs ||
      typeof signInputs !== "object" ||
      Array.isArray(signInputs)
    ) {
      errors.push(
        "Missing or invalid 'signInputs' parameter for 'signPsbt'. Expected an object mapping addresses to input indices.",
      );
    } else {
      // Iterate over 'signInputs' to validate each value
      for (const [address, indices] of Object.entries(signInputs)) {
        if (typeof address !== "string" || !Array.isArray(indices)) {
          errors.push(
            `Invalid entry in 'signInputs'. Address '${address}' must map to an array of integers.`,
          );
          continue;
        }

        // Check that each index in the array is an integer
        const invalidIndices = indices.filter(
          (index) => !Number.isInteger(index),
        );
        if (invalidIndices.length > 0) {
          errors.push(
            `Invalid indices in 'signInputs' for address '${address}'. All values must be integers.`,
          );
        }
      }
    }

    const sighashTypes = msg.params?.sighashTypes;
    if (sighashTypes !== undefined) {
      if (!Array.isArray(sighashTypes)) {
        errors.push(
          "Invalid 'sighashTypes' parameter for 'signPsbt'. Expected an array of integers.",
        );
      } else {
        const invalidSighashTypes = sighashTypes.filter(
          (type) => !Number.isInteger(type),
        );
        if (invalidSighashTypes.length > 0) {
          errors.push(
            `Invalid 'sighashTypes' values: [${invalidSighashTypes.join(
              ", ",
            )}]. All values must be integers.`,
          );
        }
      }
    }

    return errors;
  },

  signMessage: (msg) => {
    const errors = [];

    if (!msg.params?.message || typeof msg.params.message !== "string") {
      errors.push(
        "Missing or invalid 'message' parameter for 'signMessage'. Expected a string.",
      );
    }
    if (!msg.params?.address || typeof msg.params.address !== "string") {
      errors.push(
        "Missing or invalid 'address' parameter for 'SignMessage. Expected a string.",
      );
    }

    return errors;
  },

  signMessageBLS: (msg) => {
    const errors = [];
    const hasMessage =
      msg.params?.message && typeof msg.params.message === "string";
    const hasMessageHex =
      msg.params?.messageHex && typeof msg.params.messageHex === "string";
    if (!hasMessage && !hasMessageHex) {
      errors.push(
        "Missing or invalid 'message' or 'messageHex' parameter for 'signMessageBLS'. Expected a string.",
      );
    }
    if (hasMessageHex && !/^[0-9a-fA-F]*$/.test(msg.params.messageHex)) {
      errors.push(
        "Invalid 'messageHex' parameter for 'signMessageBLS'. Expected a hex string.",
      );
    }
    if (msg.params?.dst !== undefined && typeof msg.params.dst !== "string") {
      errors.push(
        "Invalid 'dst' parameter for 'signMessageBLS'. Expected a string.",
      );
    }
    if (msg.params?.address !== undefined && typeof msg.params.address !== "string") {
      errors.push(
        "Invalid 'address' parameter for 'signMessageBLS'. Expected a string.",
      );
    }
    return errors;
  },

  getBLSPoP: (msg) => {
    const errors = [];
    if (!msg.params?.address || typeof msg.params.address !== "string") {
      errors.push(
        "Missing or invalid 'address' parameter for 'getBLSPoP'. Expected a string.",
      );
    }
    return errors;
  },

  exportEncryptedBlsPrivateKey: (msg) => {
    const errors = [];
    if (msg.params?.address !== undefined && typeof msg.params.address !== "string") {
      errors.push(
        "Invalid 'address' parameter for 'exportEncryptedBlsPrivateKey'. Expected a string.",
      );
    }
    return errors;
  },

  getBalance: (msg) => {
    const errors = [];
    if (msg.params?.address !== undefined && typeof msg.params.address !== "string") {
      errors.push(
        "Invalid 'address' parameter for 'getBalance'. Expected a string.",
      );
    }
    return errors;
  },

  sendTransfer: (msg) => {
    const errors = [];
    if (!msg.params?.destination || typeof msg.params.destination !== "string") {
      errors.push(
        "Missing or invalid 'destination' parameter for 'sendTransfer'. Expected a string.",
      );
    }
    if (!Number.isInteger(msg.params?.amount) || msg.params.amount <= 0) {
      errors.push(
        "Missing or invalid 'amount' parameter for 'sendTransfer'. Expected a positive integer (satoshis).",
      );
    }
    return errors;
  },

  dispense: (msg) => {
    const errors = ["This is no longer supported.  Please use horizon tool."];
    return errors;
  },
  fairmint: (msg) => {
    const errors = ["This is no longer supported.  Please use horizon tool."];
    return errors;
  },

  openOrder: (msg) => {
    const errors = ["This is no longer supported.  Please use horizon tool."];
    return errors;
  },
};

function validate(msg) {
  const errors = [];

  if (!msg || typeof msg !== "object") {
    errors.push("Message is not an object or is missing.");
    return errors;
  }

  const { method } = msg;

  if (!method || !VALID_METHODS.includes(method)) {
    errors.push(
      `Invalid or missing method. Expected one of: ${VALID_METHODS.join(", ")}`,
    );
    return errors;
  }

  if (methodValidators[method]) {
    errors.push(...methodValidators[method](msg));
  }

  return errors;
}

document.addEventListener("horizon-provider-request", (event) => {
  const errors = validate(event.detail);

  if (errors.length) {
    const response = {
      jsonrpc: "2.0",
      id: event.detail.id,
      error: {
        code: -32600, // json rpc invalid reque`st`
        message: "Invalid request",
        data: errors,
      },
    };
    window.postMessage(response, window.location.origin);
    return;
  }

  sendMessageToBackground({ source: MESSAGE_SOURCE, ...event.detail });
});

// Per-origin map of the last approved connection: { [origin]: { addresses, network } }.
const CONNECTION_STORE_KEY = "horizonConnections";

async function addProviderToPage() {
  const inpage = document.createElement("script");
  inpage.src = chrome.runtime.getURL("horizon-provider.js");
  inpage.id = "horizon-wallet-provider";
  // Surface the extension version to the page-world provider (which has no
  // chrome.runtime access) so `getInfo` can report it.
  try {
    inpage.dataset.walletVersion = chrome.runtime.getManifest().version;
  } catch (e) {
    // best-effort; provider falls back to "0.0.0"
  }
  // Seed the previously-approved connection for this origin so the provider can
  // answer wallet_getAccount / getNetwork silently (no popup) across reloads.
  // Awaited before append so the dataset is set before the script executes.
  try {
    const store = await chrome.storage.local.get(CONNECTION_STORE_KEY);
    const conn = store?.[CONNECTION_STORE_KEY]?.[window.location.origin];
    if (conn) inpage.dataset.horizonConnection = JSON.stringify(conn);
  } catch (e) {
    // best-effort; provider just won't have a cached connection
  }
  document.body.appendChild(inpage);
}

// Persist (or clear) the approved connection on behalf of the page-world
// provider, which cannot reach chrome.storage. Keyed strictly by the page's own
// origin, so a page can only read/write its own entry.
//
// chrome.storage read-modify-write is not atomic, so events fired in quick
// succession (e.g. wallet_connect immediately followed by wallet_disconnect)
// could read the same pre-state and clobber each other. Serialise every write
// through a single promise chain so they apply in order.
let _persistChain = Promise.resolve();
document.addEventListener("horizon-provider-persist", (event) => {
  const detail = event.detail;
  _persistChain = _persistChain.then(async () => {
    try {
      const origin = window.location.origin;
      const store = await chrome.storage.local.get(CONNECTION_STORE_KEY);
      const map = store?.[CONNECTION_STORE_KEY] || {};
      if (detail) {
        map[origin] = detail;
      } else {
        delete map[origin];
      }
      await chrome.storage.local.set({ [CONNECTION_STORE_KEY]: map });
    } catch (e) {
      // best-effort; silent retrieval just won't persist across reloads
    }
  });
});

document.onreadystatechange = () => {
  if (document.readyState === "complete") {
    addProviderToPage();
  }
};
