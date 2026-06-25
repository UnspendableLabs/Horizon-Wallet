// The content script (which has chrome.runtime access) injects data onto this
// injected <script> element's dataset; the page world cannot read chrome.runtime
// itself. Captured once here because `document.currentScript` is only valid
// during the script's initial synchronous execution.
const _injectedScript = document.currentScript;
const WALLET_VERSION =
  (_injectedScript &&
    _injectedScript.dataset &&
    _injectedScript.dataset.walletVersion) ||
  "0.0.0";

// Methods advertised to provider discovery (WBIP004 `window.btc_providers`)
// and returned by `getInfo`. These are the sats-connect method names this
// provider understands; they are translated onto the wallet's house RPC below.
const SATS_CONNECT_METHODS = [
  "getAccounts",
  "getAddresses",
  "wallet_connect",
  "wallet_getAccount",
  "wallet_disconnect",
  "wallet_getNetwork",
  "getNetwork",
  "getInfo",
  "signMessage",
  "signPsbt",
  "sendTransfer",
  "getBalance",
];

function registerProvider() {
  if (!window.btc_providers) window.btc_providers = [];

  window.btc_providers.push({
    id: "HorizonWalletProvider",
    name: "Horizon Wallet",
    icon: "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxMjgiIGhlaWdodD0iMTI4IiB2aWV3Qm94PSIwIDAgMTI4IDEyOCIgZmlsbD0ibm9uZSI+CjxyZWN0IHdpZHRoPSIxMjgiIGhlaWdodD0iMTI4IiByeD0iMjYuODM4NyIgZmlsbD0iIzEyMTAwRiIvPgo8ZyB0cmFuc2Zvcm09InRyYW5zbGF0ZSgyOCAyNikgc2NhbGUoMC42NikiPgo8cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTU4LjQ4NzYgNzMuMjNDNjMuODI2MiA3Mi4xMDMxIDcwLjg2OTcgNzAuNjE2NCA3OC4wNzIyIDY2LjkxNzhWMTE2SDEwOUwxMDkgMEg3OC4wNzIyQzc4LjA3MjIgMjAuNzU5OSA3NC4yOTk1IDMwLjMxNjEgNjguNDIxOSAzNi4wMTM0QzY0LjUyMDIgMzkuNzk1NSA2MC4yMDE2IDQxLjAwNzQgNTEuMzA3NyA0Mi44OTQ3QzUxLjAzODYgNDIuOTUxOCA1MC43NjQ2IDQzLjAwOTYgNTAuNDg2IDQzLjA2ODRDNDUuMTYzMSA0NC4xOTE3IDM4LjE0MjIgNDUuNjczNSAzMC45NjExIDQ5LjM1MTRWMEgwLjAzMzM2NUwwLjAzMzM2MzcgMTExLjc3QzAuMDEwNDM0OCAxMTMuMTU3IDAgMTE0LjU2NyAwIDExNkgwLjAzMzM2MzdIMzAuOTI3OEgzMC45NjExVjExMi4wOThDMzEuMTI1MSAxMDIuOTU0IDMxLjg5MTggOTcuMDc3OSAzMy4yMjc4IDkyLjY0MTRDMzQuNTY4OSA4OC4xODc1IDM2LjY5MTQgODQuNDk4MyA0MC44MjIgODAuMDM2OUM0NC42NSA3Ni40NDc2IDQ4Ljk2MjEgNzUuMjUwNiA1Ny42Nzg3IDczLjQwMTFDNTcuOTQzNyA3My4zNDQ4IDU4LjIxMzQgNzMuMjg3OSA1OC40ODc2IDczLjIzWiIgZmlsbD0idXJsKCNob3Jpem9uSCkiLz4KPC9nPgo8ZGVmcz4KPGxpbmVhckdyYWRpZW50IGlkPSJob3Jpem9uSCIgeDE9IjIwIiB5MT0iMTQiIHgyPSIxMDQiIHkyPSIxMjAiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agc3RvcC1jb2xvcj0iI0RGRDlCRiIvPgo8c3RvcCBvZmZzZXQ9IjAuMTI1IiBzdG9wLWNvbG9yPSIjRUVEMDlBIi8+CjxzdG9wIG9mZnNldD0iMC4yNTUiIHN0b3AtY29sb3I9IiNFRUIzOTUiLz4KPHN0b3Agb2Zmc2V0PSIwLjQwNSIgc3RvcC1jb2xvcj0iI0U5QTdBRiIvPgo8c3RvcCBvZmZzZXQ9IjAuNjA1IiBzdG9wLWNvbG9yPSIjOUI4NkQ3Ii8+CjxzdG9wIG9mZnNldD0iMC44MTUiIHN0b3AtY29sb3I9IiM1MDlGQzAiLz4KPHN0b3Agb2Zmc2V0PSIxIiBzdG9wLWNvbG9yPSIjN0RDMkJDIi8+CjwvbGluZWFyR3JhZGllbnQ+CjwvZGVmcz4KPC9zdmc+Cg==",
    methods: SATS_CONNECT_METHODS,
  });
}

registerProvider();

// ---------------------------------------------------------------------------
// Low-level transport to the Horizon Wallet extension (the "house" RPC).
//
// Behaviour is intentionally identical to the historical provider.request:
//   - resolves { result: <response> } on success
//   - rejects  <response> (the raw message, an error envelope) on failure
// House-API consumers (e.g. Horizon Market's WalletHorizon) depend on this
// exact shape, so it must not change.
// ---------------------------------------------------------------------------
function houseTransport(method, params) {
  const id = crypto.randomUUID();
  const rpcRequest = { jsonrpc: "2.0", id, method, params };
  document.dispatchEvent(
    new CustomEvent("horizon-provider-request", { detail: rpcRequest }),
  );
  return new Promise((resolve, reject) => {
    function handleMessage(event) {
      const response = event.data;
      if (!response || response.id != id) return;
      window.removeEventListener("message", handleMessage);
      if ("error" in response) return reject(response);
      return resolve({ result: response });
    }
    window.addEventListener("message", handleMessage);
  });
}

// ---------------------------------------------------------------------------
// sats-connect compatibility layer.
//
// sats-connect providers (per WBIP / @sats-connect/core) are driven through
// `provider.request(method, params)` and must return a JSON-RPC 2.0 envelope
// ({ jsonrpc:"2.0", id, result } | { jsonrpc:"2.0", id, error }), *resolving*
// errors rather than throwing. The wallet's house RPC instead speaks
// getAddresses (no params), signPsbt ({hex}), signMessage ({message,address})
// and rejects on error. This layer translates between the two entirely in the
// page world — the extension's content-script / background / Dart code is
// untouched.
//
// Dispatch is by params so the house API keeps working byte-for-byte:
//   - getAddresses with `purposes` -> sats-connect ; without -> house
//   - signPsbt    with `psbt`      -> sats-connect ; with `hex` -> house
//   - signMessage: success is always a JSON-RPC envelope (still readable as
//     res.result.signature by house callers); on error it rejects (house)
//     unless the caller passed `protocol` (a sats-connect-only field).
// ---------------------------------------------------------------------------
const RPC_ERROR = {
  INVALID_PARAMS: -32602,
  INTERNAL: -32603,
  METHOD_NOT_FOUND: -32601,
  USER_REJECTION: -32000,
  METHOD_NOT_SUPPORTED: -32001,
  ACCESS_DENIED: -32002,
};

// house Network enum name -> sats-connect BitcoinNetworkType
const BITCOIN_NETWORK = {
  mainnet: "Mainnet",
  testnet4: "Testnet4",
  testnet: "Testnet",
  signet: "Signet",
  regtest: "Regtest",
};

// Connection state (the account the user approved for this origin). Seeded at
// load from chrome.storage — injected by the content script via the script's
// dataset — so a previously-connected dApp can read its account/network
// silently (no popup) across page reloads. Updated on every approved
// getAddresses / wallet_connect.
let connectedAccount = null; // { addresses: [...all purposes], network: <name> }
let cachedNetwork = null; // house Network enum name; drives getNetwork
try {
  const seed =
    _injectedScript &&
    _injectedScript.dataset &&
    _injectedScript.dataset.horizonConnection;
  if (seed) {
    const parsed = JSON.parse(seed);
    if (parsed && Array.isArray(parsed.addresses)) {
      connectedAccount = parsed;
      cachedNetwork = parsed.network || null;
    }
  }
} catch (e) {
  // ignore a malformed seed
}

// Persist (conn) or clear (null) the approved connection for this origin. The
// content script owns chrome.storage; the page world just notifies it.
function persistConnection(conn) {
  connectedAccount = conn;
  cachedNetwork = conn && conn.network ? conn.network : null;
  document.dispatchEvent(
    new CustomEvent("horizon-provider-persist", { detail: conn }),
  );
}

function ok(id, result) {
  return { jsonrpc: "2.0", id, result };
}
function rpcErr(id, code, message, data) {
  const error = { code, message };
  if (data !== undefined) error.data = data;
  return { jsonrpc: "2.0", id, error };
}

// Normalise a house rejection (which may carry `.error` as a string from a
// user-rejection, or an object from a validation failure) or a raw JS throw
// into a sats-connect error envelope.
function toError(id, e) {
  // Default to INTERNAL: a raw JS throw or a failure with no structured error
  // is a wallet/transport problem, not a user cancellation. The house side
  // sends a plain-string `.error` only for explicit user rejections, so that
  // (and only that) maps to USER_REJECTION below.
  let code = RPC_ERROR.INTERNAL;
  let message = "Horizon Wallet request failed";
  let data;
  if (e && typeof e === "object" && e.error != null) {
    const he = e.error;
    if (typeof he === "string") {
      code = RPC_ERROR.USER_REJECTION;
      message = he;
    } else if (typeof he === "object") {
      if (typeof he.code === "number") code = he.code;
      if (he.message) message = he.message;
      data = he.data;
    }
  } else if (e && e.message) {
    message = e.message;
  }
  return rpcErr(id, code, message, data);
}

function base64ToHex(b64) {
  const bin = atob(b64);
  let out = "";
  for (let i = 0; i < bin.length; i++) {
    out += bin.charCodeAt(i).toString(16).padStart(2, "0");
  }
  return out;
}
function hexToBase64(hexStr) {
  let bin = "";
  for (let i = 0; i < hexStr.length; i += 2) {
    bin += String.fromCharCode(parseInt(hexStr.substr(i, 2), 16));
  }
  return btoa(bin);
}

// Horizon derives addresses by script type; sats-connect groups them by
// purpose. Map taproot -> ordinals, everything else -> payment (the Xverse
// convention), then keep only the purposes the dApp asked for.
function purposeForType(type) {
  return type === "p2tr" ? "ordinals" : "payment";
}
function mapAddresses(houseAddresses) {
  return (houseAddresses || []).map((a) => ({
    address: a.address,
    publicKey: a.publicKey,
    addressType: a.type,
    purpose: purposeForType(a.type),
    walletType: "software",
  }));
}
// Keep only the purposes the dApp asked for (null/empty -> all).
function filterPurposes(mapped, purposes) {
  const wanted =
    Array.isArray(purposes) && purposes.length ? new Set(purposes) : null;
  return wanted ? mapped.filter((a) => wanted.has(a.purpose)) : mapped;
}
function networkObject(name) {
  const bitcoin = BITCOIN_NETWORK[name] || "Mainnet";
  const isMain = bitcoin === "Mainnet";
  return {
    bitcoin: { name: bitcoin },
    stacks: { name: isMain ? "mainnet" : "testnet" },
    spark: { name: isMain ? "mainnet" : "regtest" },
  };
}

// Drives the house getAddresses popup (user approves), reshapes + persists the
// full account, and returns the purpose-filtered view the caller asked for.
async function fetchAccounts(purposes) {
  const { result } = await houseTransport("getAddresses", undefined);
  const all = mapAddresses(result.addresses);
  persistConnection({ addresses: all, network: result.network });
  return {
    addresses: filterPurposes(all, purposes),
    network: result.network,
  };
}

async function handleSatsConnect(method, params) {
  const id = crypto.randomUUID();
  const p = params || {};
  try {
    switch (method) {
      case "getAccounts": {
        // Legacy connect: a flat address array.
        const { addresses } = await fetchAccounts(p.purposes);
        return ok(id, addresses);
      }
      case "getAddresses": {
        const { addresses, network } = await fetchAccounts(p.purposes);
        return ok(id, { addresses, network: networkObject(network) });
      }
      case "wallet_connect": {
        // Connect is an explicit user action: prompt and (re)establish account.
        const { addresses, network } = await fetchAccounts(p.addresses);
        return ok(id, {
          id: crypto.randomUUID(),
          addresses,
          walletType: "software",
          network: networkObject(network),
        });
      }
      case "wallet_getAccount": {
        // Return the already-connected account silently (no popup). Only prompt
        // if this origin has never connected.
        let conn = connectedAccount;
        if (!conn) {
          await fetchAccounts(undefined);
          conn = connectedAccount;
        }
        return ok(id, {
          id: crypto.randomUUID(),
          addresses: filterPurposes(conn.addresses, p.addresses),
          walletType: "software",
          network: networkObject(conn.network),
        });
      }
      case "wallet_disconnect":
        persistConnection(null);
        return ok(id, null);
      case "getInfo":
        return ok(id, {
          version: WALLET_VERSION,
          platform: "web",
          methods: SATS_CONNECT_METHODS,
          supports: [],
        });
      case "wallet_getNetwork":
      case "getNetwork": {
        if (!cachedNetwork) {
          return rpcErr(
            id,
            RPC_ERROR.ACCESS_DENIED,
            "Network unknown — call wallet_connect / getAddresses first",
          );
        }
        return ok(id, networkObject(cachedNetwork));
      }
      case "signPsbt": {
        if (p.broadcast) {
          return rpcErr(
            id,
            RPC_ERROR.METHOD_NOT_SUPPORTED,
            "Horizon Wallet does not broadcast from signPsbt; set broadcast:false",
          );
        }
        if (typeof p.psbt !== "string") {
          return rpcErr(
            id,
            RPC_ERROR.INVALID_PARAMS,
            "Missing 'psbt' (base64) parameter for signPsbt",
          );
        }
        const houseParams = {
          hex: base64ToHex(p.psbt),
          signInputs: p.signInputs || {},
          // The house side treats this as a whitelist of permitted sighash
          // types (bitcoinjs `signInput` allowedSighashTypes). Allow both
          // SIGHASH_DEFAULT (0x00, taproot) and SIGHASH_ALL (0x01, the default
          // for segwit-v0/legacy inputs) so mixed-input PSBTs sign; without
          // 0x01 any non-taproot input throws "Sighash type is not allowed".
          sighashTypes: [
            ...new Set([
              0x00,
              0x01,
              ...(p.allowedSignHash != null ? [p.allowedSignHash] : []),
            ]),
          ],
        };
        const { result } = await houseTransport("signPsbt", houseParams);
        return ok(id, { psbt: hexToBase64(result.hex) });
      }
      case "sendTransfer": {
        const recipients = Array.isArray(p.recipients) ? p.recipients : [];
        if (recipients.length !== 1) {
          return rpcErr(
            id,
            RPC_ERROR.INVALID_PARAMS,
            "Horizon Wallet supports exactly one recipient per sendTransfer",
          );
        }
        const r = recipients[0] || {};
        const amount =
          typeof r.amount === "number" ? r.amount : parseInt(r.amount, 10);
        if (!r.address || !Number.isFinite(amount) || amount <= 0) {
          return rpcErr(
            id,
            RPC_ERROR.INVALID_PARAMS,
            "sendTransfer recipient requires an address and a positive amount (sats)",
          );
        }
        const { result } = await houseTransport("sendTransfer", {
          destination: r.address,
          amount: Math.trunc(amount),
        });
        return ok(id, { txid: result.txid });
      }
      case "getBalance": {
        const { result } = await houseTransport("getBalance", {});
        return ok(id, {
          confirmed: String(result.confirmed),
          unconfirmed: String(result.unconfirmed),
          total: String(result.total),
        });
      }
      default:
        return rpcErr(id, RPC_ERROR.METHOD_NOT_FOUND, `Unknown method: ${method}`);
    }
  } catch (e) {
    return toError(id, e);
  }
}

// signMessage's house and sats-connect params overlap ({message,address}), so —
// unlike every other method — it can't be disambiguated by shape. We therefore
// give it a single JSON-RPC-correct behaviour for both worlds: success AND error
// are always *resolved* as a JSON-RPC envelope, never rejected. House callers
// still read res.result.signature on success and now read res.error on failure
// (the Horizon Wallet house adapters were updated to match). Resolving is
// required for sats-connect: its core lets a provider rejection propagate as a
// thrown exception instead of a { status: 'error' } result.
async function handleSignMessage(params) {
  const id = crypto.randomUUID();
  const p = params || {};
  if (p.protocol && String(p.protocol).toUpperCase() === "BIP322") {
    return rpcErr(
      id,
      RPC_ERROR.METHOD_NOT_SUPPORTED,
      "Horizon Wallet signs messages with ECDSA (BIP-137); BIP322 is not supported",
    );
  }
  try {
    const { result } = await houseTransport("signMessage", {
      message: p.message,
      address: p.address,
    });
    return ok(id, {
      signature: result.signature,
      messageHash: result.messageHash,
      address: result.address || p.address,
      protocol: "ECDSA",
    });
  } catch (e) {
    return toError(id, e);
  }
}

function isSatsConnectCall(method, params) {
  switch (method) {
    case "getAccounts":
    case "wallet_connect":
    case "wallet_getAccount":
    case "wallet_disconnect":
    case "wallet_getNetwork":
    case "getNetwork":
    case "getInfo":
    case "sendTransfer":
    case "getBalance":
      return true;
    case "getAddresses":
      return !!(params && params.purposes);
    case "signPsbt":
      return !!(params && typeof params.psbt === "string");
    default:
      return false;
  }
}

const provider = {
  request: (method, params) => {
    if (method === "signMessage") return handleSignMessage(params);
    if (isSatsConnectCall(method, params)) {
      return handleSatsConnect(method, params);
    }
    return houseTransport(method, params);
  },
};

try {
  Object.defineProperty(window, "HorizonWalletProvider", {
    get: () => provider,
    set: () => { },
  });
} catch (e) {
  console.warn("unable to register HorizonWalletProvider on window object");
}
