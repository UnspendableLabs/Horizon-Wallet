const { bls12_381 } = require("@noble/curves/bls12-381.js");
const { bytesToHex, hexToBytes } = require("@noble/hashes/utils.js");
const { hkdf } = require("@noble/hashes/hkdf.js");
const { sha256 } = require("@noble/hashes/sha2.js");

const BLS_ORDER = BigInt(
  "0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001",
);

function deriveMasterSK(seed) {
  let salt = new TextEncoder().encode("BLS-SIG-KEYGEN-SALT-");
  const ikm = new Uint8Array(seed.length + 1);
  ikm.set(seed);
  ikm[seed.length] = 0;
  const L = 48;

  while (true) {
    salt = sha256(salt);
    const okm = hkdf(sha256, ikm, salt, new Uint8Array([0, L]), L);
    let sk = BigInt(0);
    for (let i = 0; i < okm.length; i++) {
      sk = (sk << BigInt(8)) + BigInt(okm[i]);
    }
    sk = sk % BLS_ORDER;
    if (sk !== BigInt(0)) {
      const skBytes = new Uint8Array(32);
      for (let i = 31; i >= 0; i--) {
        skBytes[i] = Number(sk & BigInt(0xff));
        sk >>= BigInt(8);
      }
      return skBytes;
    }
  }
}

function sign(messageHex, privateKey, dst) {
  const msgBytes = hexToBytes(messageHex);
  if (dst != null) {
    return bytesToHex(bls12_381.sign(msgBytes, privateKey, { DST: dst }));
  }
  return bytesToHex(bls12_381.sign(msgBytes, privateKey));
}

function getPublicKey(privateKey) {
  return bytesToHex(bls12_381.getPublicKey(privateKey));
}

module.exports = { sign, getPublicKey, deriveMasterSK };
