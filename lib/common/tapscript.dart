// Tapscript helpers for signing the reveal of a Counterparty taproot envelope.
//
// Counterparty Core v11.5.0 (protocol change `require_reveal_source_signature`)
// attributes an inscription reveal to the address that funded its commit only
// when the reveal is a tapscript spend of a P2TR output whose leaf is a
// canonical envelope `OP_FALSE OP_IF <pushes only> OP_ENDIF <32-byte key>
// OP_CHECKSIG` closed by a key of that address. The node no longer signs the
// reveal: the wallet does, with the source key. Anything else is accepted by
// Bitcoin (fees paid) but silently ignored by Counterparty, so the wallet
// checks the leaf it is asked to sign before spending anything on it.
//
// Everything here is pure Dart (no JS interop) so it can be unit tested on the
// VM. The rule mirrors `counterparty-rs/src/reveal.rs`.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';

/// BIP342 tapscript leaf version.
const int tapscriptLeafVersion = 0xc0;

const int _opFalse = 0x00;
const int _opPushData1 = 0x4c;
const int _opPushData2 = 0x4d;
const int _opPushData4 = 0x4e;
const int _op1Negate = 0x4f;
const int _op1 = 0x51;
const int _op16 = 0x60;
const int _opIf = 0x63;
const int _opEndIf = 0x68;
const int _opReturn = 0x6a;
const int _opCheckSig = 0xac;

/// `CNTRPRTY`, the prefix of every Counterparty message. The reveal of a
/// taproot envelope carries an `OP_RETURN CNTRPRTY` output.
final Uint8List counterpartyPrefix =
    Uint8List.fromList(ascii.encode("CNTRPRTY"));

final ECDomainParameters _secp256k1 = ECCurve_secp256k1();

class TapscriptException implements Exception {
  final String message;
  const TapscriptException(this.message);

  @override
  String toString() => "TapscriptException: $message";
}

/// One decoded script element: a data push (`push` set, `opcode` null) or an
/// opcode (`opcode` set). `OP_0`/`OP_FALSE` decodes as an empty push, like
/// rust-bitcoin's `Instruction::PushBytes`.
class ScriptInstruction {
  final int? opcode;
  final Uint8List? push;
  const ScriptInstruction.op(this.opcode) : push = null;
  const ScriptInstruction.data(this.push) : opcode = null;

  bool get isPush => push != null;

  /// `OP_1NEGATE`, `OP_1`..`OP_16`: opcodes that only push a number.
  bool get isPushNum =>
      opcode != null &&
      (opcode == _op1Negate || (opcode! >= _op1 && opcode! <= _op16));
}

/// Decodes a script into instructions, or returns null when a push runs past
/// the end of the script.
List<ScriptInstruction>? parseScript(Uint8List script) {
  final out = <ScriptInstruction>[];
  var i = 0;
  while (i < script.length) {
    final b = script[i];
    i += 1;
    int? len;
    if (b == _opFalse) {
      len = 0;
    } else if (b < _opPushData1) {
      len = b;
    } else if (b == _opPushData1) {
      if (i + 1 > script.length) return null;
      len = script[i];
      i += 1;
    } else if (b == _opPushData2) {
      if (i + 2 > script.length) return null;
      len = script[i] | (script[i + 1] << 8);
      i += 2;
    } else if (b == _opPushData4) {
      if (i + 4 > script.length) return null;
      len = script[i] |
          (script[i + 1] << 8) |
          (script[i + 2] << 16) |
          (script[i + 3] << 24);
      i += 4;
    }
    if (len == null) {
      out.add(ScriptInstruction.op(b));
      continue;
    }
    if (i + len > script.length) return null;
    out.add(ScriptInstruction.data(
        Uint8List.fromList(script.sublist(i, i + len))));
    i += len;
  }
  return out;
}

/// The x-only key of a canonical envelope leaf
/// `OP_FALSE OP_IF <push-only body> OP_ENDIF <32-byte key> OP_CHECKSIG`, or
/// null when the leaf has any other shape. Same rule as `envelope_leaf_key`
/// in `counterparty-rs/src/reveal.rs`: no other opcode may appear anywhere,
/// nothing may follow `OP_CHECKSIG`, and the key must be a valid x-only key.
Uint8List? envelopeLeafKey(Uint8List script) {
  final ins = parseScript(script);
  if (ins == null || ins.length < 5) return null;
  var i = 0;
  if (!(ins[i].isPush && ins[i].push!.isEmpty)) return null;
  i += 1;
  if (ins[i].opcode != _opIf) return null;
  i += 1;
  while (true) {
    if (i >= ins.length) return null;
    final cur = ins[i];
    i += 1;
    if (cur.isPush || cur.isPushNum) continue;
    if (cur.opcode == _opEndIf) break;
    return null;
  }
  return _keyAndCheckSig(ins, i);
}

/// The key a `<key> OP_CHECKSIG` leaf is signed with, with or without the
/// canonical envelope prefix (what `counterparty-client` accepts for signing).
/// Null when the leaf is neither.
Uint8List? leafSignerKey(Uint8List script) {
  final canonical = envelopeLeafKey(script);
  if (canonical != null) return canonical;
  final ins = parseScript(script);
  if (ins == null) return null;
  return _keyAndCheckSig(ins, 0);
}

Uint8List? _keyAndCheckSig(List<ScriptInstruction> ins, int i) {
  if (ins.length != i + 2) return null;
  final key = ins[i];
  if (!key.isPush || key.push!.length != 32) return null;
  if (ins[i + 1].opcode != _opCheckSig) return null;
  if (liftX(key.push!) == null) return null;
  return key.push;
}

/// `OP_1 <32-byte output key>`.
bool isP2trScript(Uint8List script) =>
    script.length == 34 && script[0] == 0x51 && script[1] == 0x20;

/// `OP_0 <20-byte key hash>`.
bool isP2wpkhScript(Uint8List script) =>
    script.length == 22 && script[0] == 0x00 && script[1] == 0x14;

/// Whether `script` is an `OP_RETURN` output whose data starts with
/// `CNTRPRTY`, i.e. the marker output of a Counterparty taproot reveal.
bool isCounterpartyRevealOutput(Uint8List script) {
  if (script.isEmpty || script[0] != _opReturn) return false;
  final ins = parseScript(Uint8List.fromList(script.sublist(1)));
  if (ins == null || ins.isEmpty || !ins[0].isPush) return false;
  final data = ins[0].push!;
  if (data.length < counterpartyPrefix.length) return false;
  for (var i = 0; i < counterpartyPrefix.length; i++) {
    if (data[i] != counterpartyPrefix[i]) return false;
  }
  return true;
}

/// BIP340/341 tagged hash: `sha256(sha256(tag) || sha256(tag) || data)`.
Uint8List taggedHash(String tag, List<int> data) {
  final tagHash = sha256.convert(utf8.encode(tag)).bytes;
  return Uint8List.fromList(
      sha256.convert([...tagHash, ...tagHash, ...data]).bytes);
}

Uint8List _compactSize(int n) {
  if (n < 0xfd) return Uint8List.fromList([n]);
  if (n <= 0xffff) return Uint8List.fromList([0xfd, n & 0xff, n >> 8]);
  return Uint8List.fromList(
      [0xfe, n & 0xff, (n >> 8) & 0xff, (n >> 16) & 0xff, (n >> 24) & 0xff]);
}

/// `TapLeaf` hash of a script under `leafVersion`.
Uint8List tapLeafHash(Uint8List script, {int leafVersion = tapscriptLeafVersion}) {
  return taggedHash(
      "TapLeaf", [leafVersion, ..._compactSize(script.length), ...script]);
}

int _compareBytes(Uint8List a, Uint8List b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    if (a[i] != b[i]) return a[i] - b[i];
  }
  return a.length - b.length;
}

/// `TapBranch` hash of two child hashes, in lexicographic order.
Uint8List tapBranchHash(Uint8List a, Uint8List b) {
  final first = _compareBytes(a, b) <= 0 ? a : b;
  final second = identical(first, a) ? b : a;
  return taggedHash("TapBranch", [...first, ...second]);
}

/// Merkle root of a tree from one leaf hash and its control block path.
Uint8List tapMerkleRoot(Uint8List leafHash, List<Uint8List> path) {
  var node = leafHash;
  for (final sibling in path) {
    node = tapBranchHash(node, sibling);
  }
  return node;
}

/// A decoded BIP341 control block:
/// `<leaf version | parity> <internal key> <merkle path>`.
class TapControlBlock {
  final int leafVersion;
  final bool outputKeyIsOdd;
  final Uint8List internalKey;
  final List<Uint8List> path;

  const TapControlBlock({
    required this.leafVersion,
    required this.outputKeyIsOdd,
    required this.internalKey,
    required this.path,
  });

  /// Null unless the block is `33 + 32m` bytes long with `m <= 128`.
  static TapControlBlock? parse(Uint8List bytes) {
    if (bytes.length < 33 || (bytes.length - 33) % 32 != 0) return null;
    final m = (bytes.length - 33) ~/ 32;
    if (m > 128) return null;
    final path = <Uint8List>[
      for (var i = 0; i < m; i++)
        Uint8List.fromList(bytes.sublist(33 + i * 32, 65 + i * 32)),
    ];
    return TapControlBlock(
      leafVersion: bytes[0] & 0xfe,
      outputKeyIsOdd: (bytes[0] & 0x01) == 1,
      internalKey: Uint8List.fromList(bytes.sublist(1, 33)),
      path: path,
    );
  }
}

/// The secp256k1 point with x coordinate `x` and even y, or null when `x` is
/// not on the curve.
ECPoint? liftX(Uint8List x) {
  if (x.length != 32) return null;
  try {
    final p = _secp256k1.curve.decodePoint([0x02, ...x]);
    return p;
  } catch (_) {
    return null;
  }
}

BigInt _bytesToBigInt(List<int> bytes) {
  var v = BigInt.zero;
  for (final b in bytes) {
    v = (v << 8) | BigInt.from(b);
  }
  return v;
}

/// The taproot output key of `internalKey` tweaked with `merkleRoot` (BIP341;
/// BIP86 when `merkleRoot` is null), with the parity of its y coordinate.
/// Null when the internal key is not on the curve or the tweak is invalid.
({Uint8List xOnly, bool isOdd})? taprootOutputKey(Uint8List internalKey,
    [Uint8List? merkleRoot]) {
  final p = liftX(internalKey);
  if (p == null) return null;
  final t = _bytesToBigInt(
      taggedHash("TapTweak", [...internalKey, ...?merkleRoot]));
  if (t >= _secp256k1.n) return null;
  final q = (p + (_secp256k1.G * t))!;
  if (q.isInfinity) return null;
  final encoded = q.getEncoded(false); // 04 || x || y
  return (
    xOnly: Uint8List.fromList(encoded.sublist(1, 33)),
    isOdd: encoded.last.isOdd,
  );
}

/// The BIP86 output key (no script tree) of an x-only internal key.
Uint8List? bip86OutputKey(Uint8List internalKey) =>
    taprootOutputKey(internalKey)?.xOnly;

/// Whether `controlBlock` commits `script` to the P2TR output `scriptPubKey`:
/// the leaf hashed under the block's version, combined with the block's
/// merkle path and tweaked into the block's internal key, must give the
/// output key with the parity the block declares. This is what Bitcoin
/// checks when the reveal is spent, so a mismatch means the signature the
/// wallet is asked for can never be valid.
bool tapLeafCommitsToOutput({
  required Uint8List controlBlock,
  required Uint8List script,
  required Uint8List scriptPubKey,
}) {
  if (!isP2trScript(scriptPubKey)) return false;
  final cb = TapControlBlock.parse(controlBlock);
  if (cb == null) return false;
  final leaf = tapLeafHash(script, leafVersion: cb.leafVersion);
  final root = tapMerkleRoot(leaf, cb.path);
  final q = taprootOutputKey(cb.internalKey, root);
  if (q == null) return false;
  if (q.isOdd != cb.outputKeyIsOdd) return false;
  return _compareBytes(q.xOnly, Uint8List.fromList(scriptPubKey.sublist(2))) ==
      0;
}

/// Which of the wallet's keys a leaf must be signed with.
enum RevealSignerKey {
  /// The raw (untweaked) key of the source address: a P2WPKH key or the BIP86
  /// internal key of a P2TR address.
  raw,

  /// The BIP86-tweaked key: the P2TR output key itself, used when the envelope
  /// was closed with the source's output key (compose without
  /// `multisig_pubkey` on a P2TR source).
  tweaked,
}

/// Whether the leaf's `OP_CHECKSIG` key is `xOnly` itself or its BIP86 output
/// key. Null when neither, i.e. the wallet cannot sign this leaf.
RevealSignerKey? revealSignerKeyFor({
  required Uint8List leafKey,
  required Uint8List xOnly,
}) {
  if (_compareBytes(leafKey, xOnly) == 0) return RevealSignerKey.raw;
  final tweaked = bip86OutputKey(xOnly);
  if (tweaked != null && _compareBytes(leafKey, tweaked) == 0) {
    return RevealSignerKey.tweaked;
  }
  return null;
}

/// The checked plan for signing one tapscript input.
class TapLeafSigningPlan {
  final int leafIndex;
  final Uint8List script;
  final Uint8List controlBlock;
  final Uint8List leafKey;
  final RevealSignerKey signerKey;

  /// Whether the transaction is a Counterparty reveal (it carries an
  /// `OP_RETURN CNTRPRTY` output), in which case the stricter consensus shape
  /// was enforced.
  final bool isCounterpartyReveal;

  const TapLeafSigningPlan({
    required this.leafIndex,
    required this.script,
    required this.controlBlock,
    required this.leafKey,
    required this.signerKey,
    required this.isCounterpartyReveal,
  });
}

/// One `tapLeafScript` entry of a PSBT input.
class TapLeafScriptEntry {
  final int leafVersion;
  final Uint8List script;
  final Uint8List controlBlock;
  const TapLeafScriptEntry({
    required this.leafVersion,
    required this.script,
    required this.controlBlock,
  });
}

/// Sighash flags Counterparty accepts on a reveal: `SIGHASH_DEFAULT` and
/// `SIGHASH_ALL`.
const Set<int> counterpartyRevealSighashTypes = {0x00, 0x01};

/// Decides how to sign a tapscript input with the wallet key `xOnly`, or
/// throws a [TapscriptException] explaining why it must not be signed.
///
/// A leaf closed by `<xOnly> OP_CHECKSIG` or `<bip86(xOnly)> OP_CHECKSIG`
/// (with or without the envelope prefix) is signed only if its control block
/// commits it to the P2TR output being spent; otherwise the signature could
/// never be valid.
///
/// When any output is `OP_RETURN CNTRPRTY` the transaction is a Counterparty
/// reveal, and the shape `require_reveal_source_signature` demands is also
/// enforced: exactly one input, tapscript leaf version `0xc0`, a canonical
/// envelope, and a `SIGHASH_DEFAULT`/`SIGHASH_ALL` signature. A reveal that
/// fails any of these is valid for Bitcoin but ignored by Counterparty: the
/// fees would be paid and the message lost.
///
/// Returns null when the transaction is not a Counterparty reveal and no leaf
/// has a shape this module knows: other tapscript protocols (Kontor) keep the
/// previous behaviour, where the PSBT library signs whichever leaf contains
/// the raw key.
TapLeafSigningPlan? planTapLeafSigning({
  required Uint8List xOnly,
  required List<TapLeafScriptEntry> leaves,
  required Uint8List? spentScriptPubKey,
  required List<Uint8List> outputScripts,
  required int inputCount,
  required int? inputSighashType,
}) {
  if (leaves.isEmpty) {
    throw const TapscriptException("input has no tapLeafScript");
  }
  final isReveal = outputScripts.any(isCounterpartyRevealOutput);

  int? chosen;
  Uint8List? chosenKey;
  RevealSignerKey? chosenSigner;
  for (var i = 0; i < leaves.length; i++) {
    final key = isReveal
        ? envelopeLeafKey(leaves[i].script)
        : leafSignerKey(leaves[i].script);
    if (key == null) continue;
    final signer = revealSignerKeyFor(leafKey: key, xOnly: xOnly);
    if (signer == null) continue;
    chosen = i;
    chosenKey = key;
    chosenSigner = signer;
    break;
  }
  if (chosen == null) {
    if (!isReveal) return null;
    throw const TapscriptException(
        "the envelope is not a canonical `OP_FALSE OP_IF ... OP_ENDIF <key> OP_CHECKSIG` leaf closed by this wallet's key; the network would ignore the reveal");
  }
  final leaf = leaves[chosen];

  if (spentScriptPubKey == null) {
    throw const TapscriptException(
        "tapscript input without witnessUtxo: cannot check the commitment");
  }
  if (!tapLeafCommitsToOutput(
      controlBlock: leaf.controlBlock,
      script: leaf.script,
      scriptPubKey: spentScriptPubKey)) {
    throw const TapscriptException(
        "the control block does not commit the leaf to the spent output");
  }

  if (isReveal) {
    final cb = TapControlBlock.parse(leaf.controlBlock)!;
    if (cb.leafVersion != tapscriptLeafVersion ||
        leaf.leafVersion != tapscriptLeafVersion) {
      throw const TapscriptException(
          "a Counterparty reveal must use tapscript leaf version 0xc0");
    }
    if (inputCount != 1) {
      throw TapscriptException(
          "a Counterparty reveal must have exactly one input, got $inputCount");
    }
    if (inputSighashType != null &&
        !counterpartyRevealSighashTypes.contains(inputSighashType)) {
      throw TapscriptException(
          "a Counterparty reveal must be signed with SIGHASH_DEFAULT or SIGHASH_ALL, not 0x${inputSighashType.toRadixString(16)}");
    }
  }

  return TapLeafSigningPlan(
    leafIndex: chosen,
    script: leaf.script,
    controlBlock: leaf.controlBlock,
    leafKey: chosenKey!,
    signerKey: chosenSigner!,
    isCounterpartyReveal: isReveal,
  );
}
