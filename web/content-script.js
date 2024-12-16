const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";
const MESSAGE_SOURCE = "horizon";
const VALID_METHODS = [
  "getAddresses",
  "signPsbt",
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

  dispense: (msg) => {
    const errors = [];
    if (!msg.params?.address || typeof msg.params.address !== "string") {
      errors.push(
        "Missing or invalid 'address' parameter for 'dispense'. Expected a string.",
      );
    }
    return errors;
  },
  fairmint: (msg) => {
    const errors = [];
    if (
      !msg.params?.fairminterTxHash ||
      typeof msg.params.fairminterTxHash !== "string"
    ) {
      errors.push(
        "Missing or invalid 'fairminterTxHash' parameter for 'fairmint'. Expected a string.",
      );
    }
    return errors;
  },

  openOrder: (msg) => {
    const errors = [];
    if (!msg.params?.give_asset || typeof msg.params.give_asset !== "string") {
      errors.push(
        "Missing or invalid 'giveAsset' parameter for 'openOrder'. Expected a string.",
      );
    }
    if (
      !msg.params?.give_quantity ||
      typeof msg.params.give_quantity !== "number"
    ) {
      errors.push(
        "Missing or invalid 'giveQuantity' parameter for 'openOrder'. Expected a number.",
      );
    }
    if (!msg.params?.get_asset || typeof msg.params.get_asset !== "string") {
      errors.push(
        "Missing or invalid 'getAsset' parameter for 'openOrder'. Expected a string.",
      );
    }
    if (
      !msg.params?.get_quantity ||
      typeof msg.params.get_quantity !== "number"
    ) {
      errors.push(
        "Missing or invalid 'getQuantity' parameter for 'openOrder'. Expected a number.",
      );
    }
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

function addProviderToPage() {
  const inpage = document.createElement("script");
  inpage.src = chrome.runtime.getURL("horizon-provider.js");
  inpage.id = "horizon-wallet-provider";
  document.body.appendChild(inpage);
}

document.onreadystatechange = () => {
  if (document.readyState === "complete") {
    addProviderToPage();
  }
};
