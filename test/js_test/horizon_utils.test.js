// run with `npx vitest js_test`

import { describe, it, expect } from "vitest";

import bitcoin from "../../web/assets/bitcoinjs.js";
import horizon_utils from "../../web/assets/horizon_utils.js";
import fixtures from "./fixtures/sigop_fixtures.json";

if (typeof global !== "undefined") {
  global.bitcoin = bitcoin;
} else if (typeof window !== "undefined") {
  window.bitcoin = bitcoin;
}

describe("horizon_utils.countSigOps", () => {
  fixtures.transactions.forEach((fixture) => {
    it(`should count sigops for a ${fixture.description}`, () => {
      const tx = bitcoin.Transaction.fromHex(fixture.rawTx);

      const sigOpsCount = horizon_utils.countSigOps(tx);

      expect(sigOpsCount).toBe(fixture.expectedSigOps);
    });
  });
});
