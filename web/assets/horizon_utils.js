(function(f) {
  if (typeof exports === "object" && typeof module !== "undefined") {
    module.exports = f(); 
  } else if (typeof define === "function" && define.amd) {
    define([], f); 
  } else {
    var g;
    if (typeof window !== "undefined") {
      g = window; 
    } else if (typeof global !== "undefined") {
      g = global; 
    } else if (typeof self !== "undefined") {
      g = self; 
    } else {
      g = this; 
    }
    g.horizon_utils = f(); 
  }
})(function() {
  const WITNESS_SCALE_FACTOR = 4;
  const MAX_PUB_KEYS_PER_MULTISIG = 20;

  function countSigOps(tx) {
    let nSigOps = 0;

    nSigOps += getLegacySigOpCount(tx) * WITNESS_SCALE_FACTOR;

    if (tx.isCoinbase()) {
      return nSigOps;
    }

    tx.ins.forEach((input) => {
      let witness = input.witness;
      nSigOps += countWitnessSigOps(witness);
    });

    return nSigOps;
  }

  function getLegacySigOpCount(tx) {
    let nSigOps = 0;

    tx.ins.forEach((input) => {
      let scriptSig = bitcoin.script.decompile(input.script);
      nSigOps += countLegacySigOps(scriptSig);
    });

    tx.outs.forEach((output) => {
      let scriptPubKey = bitcoin.script.decompile(output.script);
      nSigOps += countLegacySigOps(scriptPubKey);
    });

    return nSigOps;
  }

  function countLegacySigOps(script) {
    let n = 0;
    script.forEach((opcode) => {
      if (
        opcode === bitcoin.opcodes.OP_CHECKSIG ||
        opcode === bitcoin.opcodes.OP_CHECKSIGVERIFY
      ) {
        n++;
      } else if (
        opcode === bitcoin.opcodes.OP_CHECKMULTISIG ||
        opcode === bitcoin.opcodes.OP_CHECKMULTISIGVERIFY
      ) {
        n += MAX_PUB_KEYS_PER_MULTISIG;
      }
    });
    return n;
  }

  function countWitnessSigOps(witness) {
    if (!witness || witness.length === 0) {
      return 0;
    }
    return 1;
  }

  return {
    countSigOps: countSigOps,
  };
});
