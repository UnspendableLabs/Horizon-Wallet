const { bls12_381 } = require("@noble/curves/bls12-381.js");
const { hexToBytes } = require("@noble/hashes/utils.js");
const { hkdf, extract, expand } = require("@noble/hashes/hkdf.js");
const { sha256 } = require("@noble/hashes/sha2.js");

const BLS_ORDER = BigInt(
  "0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001",
);

function hkdfModR(ikm) {
  let salt = new TextEncoder().encode("BLS-SIG-KEYGEN-SALT-");
  const ikmPadded = new Uint8Array(ikm.length + 1);
  ikmPadded.set(ikm);
  ikmPadded[ikm.length] = 0;
  const L = 48;

  while (true) {
    salt = sha256(salt);
    const okm = hkdf(sha256, ikmPadded, salt, new Uint8Array([0, L]), L);
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

function deriveMasterSK(seed) {
  return hkdfModR(seed);
}

function parentSKToLamportPK(parentSK, index) {
  const salt = new Uint8Array(4);
  new DataView(salt.buffer).setUint32(0, index, false);

  const ikm = parentSK;

  const prk0 = extract(sha256, ikm, salt);
  const okm0 = expand(sha256, prk0, new Uint8Array(0), 8160);

  const notIKM = new Uint8Array(ikm.length);
  for (let i = 0; i < ikm.length; i++) notIKM[i] = ~ikm[i] & 0xff;

  const prk1 = extract(sha256, notIKM, salt);
  const okm1 = expand(sha256, prk1, new Uint8Array(0), 8160);

  const lamportPK = new Uint8Array(255 * 32 * 2);
  let offset = 0;
  for (let i = 0; i < 255; i++) {
    lamportPK.set(sha256(okm0.subarray(i * 32, (i + 1) * 32)), offset);
    offset += 32;
  }
  for (let i = 0; i < 255; i++) {
    lamportPK.set(sha256(okm1.subarray(i * 32, (i + 1) * 32)), offset);
    offset += 32;
  }

  return sha256(lamportPK);
}

function deriveChildSK(parentSK, index) {
  const compressedLamportPK = parentSKToLamportPK(parentSK, index);
  return hkdfModR(compressedLamportPK);
}

function deriveBlsKey(seed, coinType, account) {
  let sk = deriveMasterSK(seed);
  for (const idx of [12381, coinType, account, 0]) {
    sk = deriveChildSK(sk, idx);
  }
  return sk;
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
  sign, getPublicKey, deriveMasterSK, deriveBlsKey,
  signBlsBinding, schnorrBindingHash,
};
