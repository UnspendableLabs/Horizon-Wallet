// Signs the reveal fixtures of test/fixtures/taproot_reveal_fixtures.json the
// way the wallet does (lib/data/services/transaction_service/
// transaction_service_web.dart, signPsbt on a tapLeafScript input), with the
// exact bitcoinjs bundle the extension ships, on the PSBT shape the
// Horizon-Market-Client SDK builds (witnessUtxo + tapLeafScript +
// tapInternalKey + tapMerkleRoot), then checks:
// - one tapScriptSig for the envelope leaf and no key-path signature,
// - the finalized witness is <signature> <envelope> <control block>,
// - bitcoinjs' script-path sighash equals the one bitcoinutils computed and
//   both signatures verify against it,
// - the txid equals the one of the reveal bitcoinutils signed.
// Run with: node test/js_test/taproot_reveal_check.mjs
import fs from "node:fs";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
// Usage: node test/js_test/taproot_reveal_check.mjs [out.json]
// The optional JSON output lists each witness so it can be fed to the
// consensus rule (counterparty_rs.utils.reveal_source_signature_error).
const here = new URL(".", import.meta.url).pathname;
const bundlePath = here + "../../web/assets/bundle.js";
const fixturesPath = here + "../fixtures/taproot_reveal_fixtures.json";
const outPath = process.argv[2];
const src = fs.readFileSync(bundlePath, "utf8");
globalThis.self = globalThis; globalThis.window = globalThis;
globalThis.navigator ??= { userAgent: "node" };
globalThis.location ??= { href: "http://localhost/" };
const bundle = new Function("require", src + "\n;return __horizon_js_bundle__;")(require);
const { bitcoinjs, ecpair, tinysecp256k1: ecc, buffer } = bundle;
const B = buffer.Buffer || buffer;
bitcoinjs.initEccLib(ecc);
const ECPair = ecpair.ECPairFactory ? ecpair.ECPairFactory(ecc) : ecpair.default(ecc);
const regtest = { messagePrefix: "\x18Bitcoin Signed Message:\n", bech32: "bcrt", bip32: { public: 0x043587cf, private: 0x04358394 }, pubKeyHash: 0x6f, scriptHash: 0xc4, wif: 0xef };

const fx = JSON.parse(fs.readFileSync(fixturesPath, "utf8"));
const hex = (b) => B.from(b).toString("hex");
function tapLeafHash(script) {
  const len = script.length;
  const cs = len < 0xfd ? B.from([len]) : B.from([0xfd, len & 0xff, len >> 8]);
  return bitcoinjs.crypto.taggedHash("TapLeaf", B.concat([B.from([0xc0]), cs, script]));
}
const N = BigInt("0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141");
function bip86TweakPriv(priv, pub33) {
  // same arithmetic as the Dart taprootTweakPrivKey (merkleRoot empty)
  let d = BigInt("0x" + hex(priv));
  if (pub33[0] === 0x03) d = N - d;
  const t = BigInt("0x" + hex(bitcoinjs.crypto.taggedHash("TapTweak", pub33.subarray(1))));
  const tw = (d + t) % N;
  return B.from(tw.toString(16).padStart(64, "0"), "hex");
}

const results = [];
for (const c of fx.cases) {
  const unsigned = bitcoinjs.Transaction.fromHex(c.reveal_rawtransaction);
  const env = B.from(c.envelope_script, "hex");
  const cb = B.from(c.reveal_control_block, "hex");
  const spk = B.from(c.reveal_lock_scripts[0], "hex");
  const value = c.reveal_inputs_values[0];
  const leafHash = tapLeafHash(env);
  // The SDK sets tapMerkleRoot to the leaf hash (single-leaf commit, what the
  // server builds). For the two-leaf fixture fold the control block path so
  // bitcoinjs' checkIfTapLeafInTree accepts the input.
  let merkleRoot = leafHash;
  for (let i = 33; i < cb.length; i += 32) {
    const sib = cb.subarray(i, i + 32);
    const [a, b2] = B.compare(merkleRoot, sib) <= 0 ? [merkleRoot, sib] : [sib, merkleRoot];
    merkleRoot = bitcoinjs.crypto.taggedHash("TapBranch", B.concat([a, b2]));
  }

  // The SDK's PSBT: witnessUtxo, tapLeafScript, tapInternalKey, tapMerkleRoot.
  const psbt = new bitcoinjs.Psbt({ network: regtest });
  const inp = unsigned.ins[0];
  psbt.setVersion(unsigned.version);
  psbt.setLocktime(unsigned.locktime);
  psbt.addInput({
    hash: inp.hash, index: inp.index, sequence: inp.sequence,
    witnessUtxo: { script: spk, value },
    tapLeafScript: [{ leafVersion: 0xc0, script: env, controlBlock: cb }],
    tapInternalKey: B.from(c.reveal_pubkey, "hex"),
    tapMerkleRoot: merkleRoot,
  });
  for (const o of unsigned.outs) psbt.addOutput({ script: o.script, value: o.value });

  // What the wallet does: ecpair from the source private key, raw key unless
  // the leaf holds the BIP86 output key, then psbt.signInput(0, signer, [0, 1]).
  const priv = B.from(c.source_private_key, "hex");
  const base = ECPair.fromPrivateKey(priv, { network: regtest });
  const xOnly = B.from(base.publicKey).subarray(1);
  const leafKey = env.subarray(env.length - 33, env.length - 1);
  let signer = base;
  let signerKind = "raw";
  if (!leafKey.equals(xOnly)) {
    signer = ECPair.fromPrivateKey(bip86TweakPriv(priv, B.from(base.publicKey)), { network: regtest });
    signerKind = "tweaked";
    if (!leafKey.equals(B.from(signer.publicKey).subarray(1))) throw new Error(`${c.name}: leaf key is neither raw nor tweaked`);
  }
  psbt.signInput(0, signer, [0x00, 0x01]);
  const tapScriptSig = psbt.data.inputs[0].tapScriptSig;
  if (!tapScriptSig || tapScriptSig.length !== 1) throw new Error(`${c.name}: expected one tapScriptSig`);
  if (!B.from(tapScriptSig[0].leafHash).equals(leafHash)) throw new Error(`${c.name}: tapScriptSig for the wrong leaf`);
  if (psbt.data.inputs[0].tapKeySig) throw new Error(`${c.name}: unexpected key-path signature`);

  // Finalize like the SDK does (bitcoinjs' own tapscript finalizer) and
  // extract the witness.
  psbt.finalizeAllInputs();
  const tx = psbt.extractTransaction();
  const witness = tx.ins[0].witness.map(hex);
  if (witness.length !== 3 || witness[1] !== c.envelope_script || witness[2] !== c.reveal_control_block) throw new Error(`${c.name}: witness shape ${witness.map(w => w.length)}`);
  if (witness[0].length !== 128) throw new Error(`${c.name}: expected a 64-byte SIGHASH_DEFAULT signature`);

  // Independent sighash cross-check: bitcoinutils' signature (from Python)
  // must verify against bitcoinjs' script-path sighash, and vice versa.
  const sighash = tx.hashForWitnessV1(0, [spk], [value], 0x00, leafHash);
  if (hex(sighash) !== c.reveal_sighash) throw new Error(`${c.name}: sighash differs from bitcoinutils`);
  if (!ecc.verifySchnorr(sighash, leafKey, B.from(c.reveal_signature, "hex"))) throw new Error(`${c.name}: python signature does not verify against bitcoinjs sighash`);
  if (!ecc.verifySchnorr(sighash, leafKey, B.from(witness[0], "hex"))) throw new Error(`${c.name}: bitcoinjs signature does not verify`);
  if (tx.getId() !== bitcoinjs.Transaction.fromHex(c.signed_reveal_rawtransaction).getId()) throw new Error(`${c.name}: txid differs from the python-signed reveal`);

  results.push({ name: c.name, signer: signerKind, commit_script_pubkey: c.reveal_lock_scripts[0], source_script_pubkey: c.source_script_pubkey, witness, txid: tx.getId(), sighash_type_bytes: witness[0].length / 2 });
  console.log(`${c.name}: signed with ${signerKind} key, witness ok, sighash matches bitcoinutils, txid ${tx.getId()}`);
}
if (outPath) fs.writeFileSync(outPath, JSON.stringify(results, null, 1));
