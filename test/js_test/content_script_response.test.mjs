import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import { runInNewContext } from "node:vm";

const source = readFileSync(
  new URL("../../web/content-script.js", import.meta.url),
  "utf8",
);

function loadBridge(postMessage) {
  let listener;
  runInNewContext(source, {
    chrome: {
      runtime: {
        connect: () => ({ onDisconnect: { addListener() {} } }),
        onMessage: { addListener: (fn) => { listener = fn; } },
      },
    },
    window: { location: { origin: "https://dapp.example" }, postMessage },
    document: { addEventListener() {} },
  });
  return listener;
}

for (const message of [
  { id: "addresses", network: "mainnet", addresses: [] },
  { id: "sign", hex: "signed-psbt-fixture" },
  { id: "transfer", txid: "transaction-id-fixture" },
  { id: "error", error: { code: -32603, message: "Request failed" } },
]) {
  test(`acknowledges ${message.id} after forwarding the unchanged reply`, () => {
    const calls = [];
    const listener = loadBridge((data, origin) => {
      calls.push(["forward", data, origin]);
    });
    const result = listener(message, {}, (response) => {
      // JSON round-trip matches Chrome serialization across the VM boundary.
      calls.push(["ack", JSON.parse(JSON.stringify(response))]);
    });

    assert.equal(result, undefined); // A synchronous response, no open channel.
    assert.deepEqual(calls, [
      ["forward", message, "https://dapp.example"],
      ["ack", { received: true }],
    ]);
  });
}

test("does not acknowledge a reply that could not be forwarded", () => {
  const failure = new Error("postMessage failed");
  const listener = loadBridge(() => { throw failure; });
  let acknowledged = false;
  assert.throws(
    () => listener({ id: "request" }, {}, () => { acknowledged = true; }),
    (error) => error === failure,
  );
  assert.equal(acknowledged, false);
});
