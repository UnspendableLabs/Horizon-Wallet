const CONTENT_SCRIPT_PORT = "horizon-wallet-content-script";
const MESSAGE_SOURCE = "horizon";
const VALID_METHODS = ["getAddresses", "signPsbt", "fairmint", "dispense"];

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

const validators = {
  signPsbt: (msg, errors) => {
    if (!msg.params?.hex || typeof msg.params.hex !== "string") {
      errors.push(
        "Missing or invalid 'hex' parameter for 'signPsbt'. Expected a string.",
      );
    }
  },
  dispense: (msg, errors) => {
    if (!msg.params?.address || typeof msg.params.address !== "string") {
      errors.push(
        "Missing or invalid 'address' parameter for 'dispense'. Expected a string.",
      );
    }
  },
  fairmint: (msg, errors) => {
    if (
      !msg.params?.fairminterTxHash ||
      typeof msg.params.fairminterTxHash !== "string"
    ) {
      errors.push(
        "Missing or invalid 'fairminterTxHash' parameter for 'fairmint'. Expected a string.",
      );
    }
  },
};

const methodValidators = {
  signPsbt: (msg) => {
    const errors = [];
    if (!msg.params?.hex || typeof msg.params.hex !== "string") {
      errors.push(
        "Missing or invalid 'hex' parameter for 'signPsbt'. Expected a string.",
      );
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
