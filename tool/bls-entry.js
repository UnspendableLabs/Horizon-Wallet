const { bls12_381 } = require("@noble/curves/bls12-381.js");
const { hexToBytes } = require("@noble/hashes/utils.js");
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

// min_sig (G1, 48 bytes): used by Kontor & Portal; signatures are aggregated on-chain so smaller = cheaper.
const KONTOR_BLS_DST = "BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_";

function sign(messageHex, privateKey, dst) {
  const msgBytes = hexToBytes(messageHex);
  const effectiveDst = dst || KONTOR_BLS_DST;
  const hashedMsg = bls12_381.shortSignatures.hash(msgBytes, effectiveDst);
  const sigPoint = bls12_381.shortSignatures.sign(hashedMsg, privateKey);
  return bls12_381.shortSignatures.Signature.toHex(sigPoint);
}

function getPublicKey(privateKey) {
  const pubPoint = bls12_381.shortSignatures.getPublicKey(privateKey);
  return pubPoint.toHex();
}
const SCHNORR_BINDING_PREFIX = new TextEncoder().encode("KONTOR_XONLY_TO_BLS_V1");
const BLS_BINDING_PREFIX = new TextEncoder().encode("KONTOR_BLS_TO_XONLY_V1");

function signBlsBinding(blsPrivateKey, xOnlyPubkeyHex) {
  const xOnlyBytes = hexToBytes(xOnlyPubkeyHex);
  const msg = new Uint8Array(BLS_BINDING_PREFIX.length + xOnlyBytes.length);
  msg.set(BLS_BINDING_PREFIX);
  msg.set(xOnlyBytes, BLS_BINDING_PREFIX.length);
  const hashedMsg = bls12_381.shortSignatures.hash(msg, KONTOR_BLS_DST);
  const sigPoint = bls12_381.shortSignatures.sign(hashedMsg, blsPrivateKey);
  return bls12_381.shortSignatures.Signature.toHex(sigPoint);
}

function schnorrBindingHash(blsPubkeyHex) {
  const blsPubkeyBytes = hexToBytes(blsPubkeyHex);
  const preimage = new Uint8Array(SCHNORR_BINDING_PREFIX.length + blsPubkeyBytes.length);
  preimage.set(SCHNORR_BINDING_PREFIX);
  preimage.set(blsPubkeyBytes, SCHNORR_BINDING_PREFIX.length);
  return sha256(preimage);
}

module.exports = {
  sign, getPublicKey, deriveMasterSK,
  signBlsBinding, schnorrBindingHash,
};
