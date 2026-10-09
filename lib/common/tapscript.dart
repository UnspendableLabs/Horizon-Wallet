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
// Signing such a leaf publishes its message from the source address, so the
// wallet also reads the transaction the way the parser does (the reveal
// marker and the data outputs, `counterparty-rs/src/indexer/bitcoin_client.rs`)
// to show exactly the message the network will parse.
//
// Everything here is pure Dart (no JS interop) so it can be unit tested on the
// VM. The rule mirrors `counterparty-rs/src/reveal.rs`.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:horizon/common/cbor.dart';
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
const int _opDup = 0x76;
const int _opEqual = 0x87;
const int _opEqualVerify = 0x88;
const int _opHash160 = 0xa9;
const int _opCheckSig = 0xac;
const int _opCheckMultiSig = 0xae;

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
    out.add(
        ScriptInstruction.data(Uint8List.fromList(script.sublist(i, i + len))));
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

/// `OP_0 <32-byte script hash>`.
bool isP2wshScript(Uint8List script) =>
    script.length == 34 && script[0] == 0x00 && script[1] == 0x20;

/// `OP_HASH160 <20-byte script hash> OP_EQUAL`.
bool isP2shScript(Uint8List script) =>
    script.length == 23 &&
    script[0] == _opHash160 &&
    script[1] == 0x14 &&
    script[22] == _opEqual;

/// `OP_DUP OP_HASH160 <20-byte key hash> OP_EQUALVERIFY OP_CHECKSIG`.
bool isP2pkhScript(Uint8List script) =>
    script.length == 25 &&
    script[0] == _opDup &&
    script[1] == _opHash160 &&
    script[2] == 0x14 &&
    script[23] == _opEqualVerify &&
    script[24] == _opCheckSig;

/// Whether `address` is a taproot (segwit v1, bech32m) address.
bool isTaprootAddress(String address) {
  final a = address.toLowerCase();
  return a.startsWith('bc1p') || a.startsWith('tb1p') || a.startsWith('bcrt1p');
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

bool _startsWith(List<int> bytes, List<int> prefix, [int at = 0]) {
  if (bytes.length < at + prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (bytes[at + i] != prefix[i]) return false;
  }
  return true;
}

/// RC4 (ARC4): Counterparty obfuscates the data of an output with the txid of
/// the transaction's first input. Nothing comes out of an empty key, as in
/// the parser's `arc4_decrypt`.
Uint8List arc4(List<int> key, List<int> data) {
  if (key.isEmpty) return Uint8List(0);
  final s = List<int>.generate(256, (i) => i);
  var j = 0;
  for (var i = 0; i < 256; i++) {
    j = (j + s[i] + key[i % key.length]) & 0xff;
    final t = s[i];
    s[i] = s[j];
    s[j] = t;
  }
  final out = Uint8List(data.length);
  var i = 0;
  j = 0;
  for (var k = 0; k < data.length; k++) {
    i = (i + 1) & 0xff;
    j = (j + s[i]) & 0xff;
    final t = s[i];
    s[i] = s[j];
    s[j] = t;
    out[k] = data[k] ^ s[(s[i] + s[j]) & 0xff];
  }
  return out;
}

/// How the Counterparty parser reads a transaction output.
enum CounterpartyOutputKind {
  /// An address output: a destination before the data, change after it.
  destination,

  /// An output the parser reads Counterparty data from.
  data,

  /// An output the parser rejects (the whole transaction is then ignored),
  /// or one a reveal has no reason to carry and the wallet does not accept
  /// in one: bare multisig and pay-to-pubkey destinations, unknown witness
  /// versions, non-standard scripts.
  other,
}

class CounterpartyOutput {
  final CounterpartyOutputKind kind;

  /// The data the parser reads, when [kind] is
  /// [CounterpartyOutputKind.data].
  final Uint8List? data;

  const CounterpartyOutput._(this.kind, [this.data]);

  static const destination =
      CounterpartyOutput._(CounterpartyOutputKind.destination);
  static const other = CounterpartyOutput._(CounterpartyOutputKind.other);

  /// The marker of a reveal: data equal to `CNTRPRTY`, which the parser
  /// replaces with the message carried by the envelope of input 0.
  bool get isRevealMarker =>
      kind == CounterpartyOutputKind.data &&
      _bytesEqual(data!, counterpartyPrefix);
}

/// How the Counterparty parser reads the output `script` of a transaction
/// whose first input spends the transaction `firstInputTxid` (display byte
/// order, the ARC4 key). Mirrors `parse_vout` in
/// `counterparty-rs/src/indexer/bitcoin_client.rs`: the `OP_RETURN` data in
/// clear (`CNTRPRTY` only) or ARC4-obfuscated, and the data hidden in the
/// keys of an `OP_CHECKSIG` or `OP_CHECKMULTISIG` output.
CounterpartyOutput classifyCounterpartyOutput(
    Uint8List script, Uint8List firstInputTxid) {
  if (script.isNotEmpty && script[0] == _opReturn) {
    final ins = parseScript(script);
    if (ins == null || ins.length != 2 || !ins[1].isPush) {
      return CounterpartyOutput.other;
    }
    final pb = ins[1].push!;
    if (_bytesEqual(pb, counterpartyPrefix)) {
      return CounterpartyOutput._(
          CounterpartyOutputKind.data, Uint8List.fromList(counterpartyPrefix));
    }
    final clear = arc4(firstInputTxid, pb);
    if (_startsWith(clear, counterpartyPrefix)) {
      return CounterpartyOutput._(CounterpartyOutputKind.data,
          Uint8List.sublistView(clear, counterpartyPrefix.length));
    }
    return CounterpartyOutput.other;
  }

  final ins = parseScript(script);
  if (ins == null || ins.isEmpty) return CounterpartyOutput.other;

  if (ins.last.opcode == _opCheckSig) {
    if (ins.length < 3) return CounterpartyOutput.other;
    final third = ins[2];
    final pb = third.isPush
        ? third.push!
        : Uint8List.fromList([third.opcode == _op1 ? 1 : third.opcode!]);
    final data = _keyChunkData(arc4(firstInputTxid, pb));
    if (data != null) {
      return CounterpartyOutput._(CounterpartyOutputKind.data, data);
    }
    return isP2pkhScript(script)
        ? CounterpartyOutput.destination
        : CounterpartyOutput.other;
  }

  if (ins.last.opcode == _opCheckMultiSig) {
    final keys = _multisigDataKeys(ins);
    if (keys == null) return CounterpartyOutput.other;
    final obfuscated = BytesBuilder();
    // no data in the last key; skip the sign byte and the nonce byte
    for (final key in keys.take(keys.length - 1)) {
      if (key.length < 2) return CounterpartyOutput.other;
      obfuscated.add(Uint8List.sublistView(key, 1, key.length - 1));
    }
    final data = _keyChunkData(arc4(firstInputTxid, obfuscated.toBytes()));
    if (data != null) {
      return CounterpartyOutput._(CounterpartyOutputKind.data, data);
    }
    return CounterpartyOutput.other;
  }

  if (isP2shScript(script) ||
      isP2wpkhScript(script) ||
      isP2wshScript(script) ||
      isP2trScript(script)) {
    return CounterpartyOutput.destination;
  }
  return CounterpartyOutput.other;
}

/// The data of a deobfuscated key chunk `<length> CNTRPRTY <data>`, or null
/// when the chunk carries no Counterparty data.
Uint8List? _keyChunkData(Uint8List clear) {
  final n = counterpartyPrefix.length;
  if (clear.length <= n || !_startsWith(clear, counterpartyPrefix, 1)) {
    return null;
  }
  final length = clear[0] < clear.length - 1 ? clear[0] : clear.length - 1;
  if (length < n) return Uint8List(0);
  return Uint8List.sublistView(clear, 1 + n, 1 + length);
}

/// The keys of an `OP_CHECKMULTISIG` output that may carry Counterparty data,
/// for the script shapes the parser accepts, or null for any other shape.
List<Uint8List>? _multisigDataKeys(List<ScriptInstruction> ins) {
  bool push(int i) => ins[i].isPush;
  bool m(int i, Set<int> ops) =>
      ins[i].opcode != null && ops.contains(ins[i].opcode);
  const op1 = 0x51, op2 = 0x52, op3 = 0x53;
  if (ins.length == 5) {
    if ((push(0) && push(1) && push(2) && push(3)) ||
        (m(0, {op1, op2, op3}) && push(1) && push(2) && m(3, {op2}))) {
      return [ins[1].push!, ins[2].push!];
    }
  }
  if (ins.length == 6) {
    if ((push(0) && push(1) && push(2) && push(3) && push(4)) ||
        (m(0, {op1, op2, op3}) &&
            push(1) &&
            push(2) &&
            push(3) &&
            m(4, {op3}))) {
      return [ins[1].push!, ins[2].push!, ins[3].push!];
    }
  }
  return null;
}

/// Whether some output of the transaction is the `CNTRPRTY` marker of a
/// reveal, in whichever form the parser recognizes it.
bool hasCounterpartyRevealMarker(
        List<Uint8List> outputScripts, Uint8List firstInputTxid) =>
    outputScripts.any(
        (s) => classifyCounterpartyOutput(s, firstInputTxid).isRevealMarker);

/// Checks that the outputs of a Counterparty reveal make the parser read the
/// envelope's message and nothing else, and returns the index of the
/// `CNTRPRTY` marker output.
///
/// The parser concatenates the data of every data output (the marker
/// standing for the envelope), so any other data output would change the
/// message: a reveal must have exactly one marker and, besides it, only
/// address outputs. Every address output before the marker is a Counterparty
/// destination.
int checkCounterpartyRevealOutputs(
    List<Uint8List> outputScripts, Uint8List firstInputTxid) {
  int? marker;
  for (var i = 0; i < outputScripts.length; i++) {
    final output = classifyCounterpartyOutput(outputScripts[i], firstInputTxid);
    switch (output.kind) {
      case CounterpartyOutputKind.destination:
        continue;
      case CounterpartyOutputKind.other:
        throw TapscriptException(
            "output $i of the reveal is not an address output nor its CNTRPRTY marker");
      case CounterpartyOutputKind.data:
        if (!output.isRevealMarker) {
          throw TapscriptException(
              "output $i carries Counterparty data besides the envelope: the network would not parse the message the wallet shows");
        }
        if (marker != null) {
          throw const TapscriptException(
              "a Counterparty reveal must have a single CNTRPRTY output");
        }
        marker = i;
    }
  }
  if (marker == null) {
    throw const TapscriptException(
        "a Counterparty envelope must be revealed with a CNTRPRTY output");
  }
  return marker;
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
Uint8List tapLeafHash(Uint8List script,
    {int leafVersion = tapscriptLeafVersion}) {
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
  final t =
      _bytesToBigInt(taggedHash("TapTweak", [...internalKey, ...?merkleRoot]));
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
  final int leafVersion;

  /// The `TapLeaf` hash of the leaf: the only leaf the wallet signs.
  final Uint8List leafHash;
  final Uint8List leafKey;
  final RevealSignerKey signerKey;

  /// Whether the leaf is a canonical Counterparty envelope, so that the
  /// signature publishes its message: the strict shape of a reveal was
  /// enforced and the message must be shown before signing.
  final bool isCounterpartyReveal;

  /// The index of the reveal's `CNTRPRTY` output; every output before it is
  /// a Counterparty destination. Null when not a reveal.
  final int? markerOutputIndex;

  const TapLeafSigningPlan({
    required this.leafIndex,
    required this.script,
    required this.controlBlock,
    required this.leafVersion,
    required this.leafHash,
    required this.leafKey,
    required this.signerKey,
    required this.isCounterpartyReveal,
    required this.markerOutputIndex,
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
/// The plan names a single leaf, closed by `<xOnly> OP_CHECKSIG` or
/// `<bip86(xOnly)> OP_CHECKSIG` (with or without the envelope prefix), whose
/// control block commits it to the P2TR output being spent; the wallet signs
/// that leaf and no other.
///
/// The parser attributes a reveal to its source when input 0 spends a
/// canonical envelope closed by a key of that source, whatever else the
/// transaction holds. So whenever the planned leaf is a canonical envelope,
/// the transaction is held to the shape `require_reveal_source_signature`
/// demands, and its outputs to carrying the envelope's message and nothing
/// else (see [checkCounterpartyRevealOutputs]): exactly one input, tapscript
/// leaf version `0xc0`, a `SIGHASH_DEFAULT`/`SIGHASH_ALL` signature, and an
/// envelope closed by the raw key of `xOnly`, or by its BIP86 output key when
/// `signerIsTaprootAddress` (the only keys Counterparty accepts for the
/// address). A transaction carrying the reveal marker must have such a leaf.
/// `firstInputTxid` is the txid of the transaction input 0 spends, in display
/// byte order: the parser deobfuscates the outputs with it.
///
/// Returns null when no leaf has a shape this module knows: other tapscript
/// protocols (Kontor) keep the previous behaviour, where the PSBT library
/// signs whichever leaf contains the raw key.
TapLeafSigningPlan? planTapLeafSigning({
  required Uint8List xOnly,
  required bool signerIsTaprootAddress,
  required List<TapLeafScriptEntry> leaves,
  required Uint8List? spentScriptPubKey,
  required List<Uint8List> outputScripts,
  required Uint8List firstInputTxid,
  required int inputCount,
  required int? inputSighashType,
}) {
  if (leaves.isEmpty) {
    throw const TapscriptException("input has no tapLeafScript");
  }
  final marked = hasCounterpartyRevealMarker(outputScripts, firstInputTxid);

  int? chosen;
  Uint8List? chosenKey;
  RevealSignerKey? chosenSigner;
  var isEnvelope = false;
  for (var i = 0; i < leaves.length; i++) {
    final envelopeKey = envelopeLeafKey(leaves[i].script);
    final key =
        envelopeKey ?? (marked ? null : leafSignerKey(leaves[i].script));
    if (key == null) continue;
    final signer = revealSignerKeyFor(leafKey: key, xOnly: xOnly);
    if (signer == null) continue;
    // for anything but a taproot address, Counterparty takes the address key
    // only: an envelope closed by its BIP86 key would be ignored
    if (envelopeKey != null &&
        signer == RevealSignerKey.tweaked &&
        !signerIsTaprootAddress) {
      continue;
    }
    chosen = i;
    chosenKey = key;
    chosenSigner = signer;
    isEnvelope = envelopeKey != null;
    break;
  }
  if (chosen == null) {
    if (!marked) return null;
    throw const TapscriptException(
        "the envelope is not a canonical `OP_FALSE OP_IF ... OP_ENDIF <key> OP_CHECKSIG` leaf closed by this address' key; the network would ignore the reveal");
  }
  final leaf = leaves[chosen];

  final cb = TapControlBlock.parse(leaf.controlBlock);
  if (cb == null) {
    throw const TapscriptException("invalid taproot control block");
  }
  if (cb.leafVersion != leaf.leafVersion) {
    throw const TapscriptException(
        "the leaf version of the tapLeafScript entry differs from its control block");
  }
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

  int? markerOutputIndex;
  if (isEnvelope) {
    if (leaf.leafVersion != tapscriptLeafVersion) {
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
    markerOutputIndex =
        checkCounterpartyRevealOutputs(outputScripts, firstInputTxid);
  }

  return TapLeafSigningPlan(
    leafIndex: chosen,
    script: leaf.script,
    controlBlock: leaf.controlBlock,
    leafVersion: leaf.leafVersion,
    leafHash: tapLeafHash(leaf.script, leafVersion: leaf.leafVersion),
    leafKey: chosenKey!,
    signerKey: chosenSigner!,
    isCounterpartyReveal: isEnvelope,
    markerOutputIndex: markerOutputIndex,
  );
}

/// The Counterparty message carried by a canonical envelope, rebuilt the way
/// the consensus parser does (`extract_data_from_witness` in
/// `counterparty-rs/src/indexer/bitcoin_client.rs`):
///
/// * generic envelope: the concatenation of every push between `OP_IF` and
///   `OP_ENDIF`;
/// * ordinals envelope, `"ord" 0x07 "xcp" 0x01 mime [0x05 metadata]* OP_0
///   content*`: the metadata is a CBOR array `[type_id, fields...]` (or a map
///   whose `"xcp"` key holds that array), re-encoded with serde_cbor's rules
///   (see cbor.dart) as `(type_id as u8) || cbor(fields + [mime] + [content])`.
///
/// Returns null when the script is not a canonical envelope and throws a
/// [TapscriptException] when the parser would reject the envelope. The result
/// is the data the parser substitutes for the reveal's `CNTRPRTY` output.
Uint8List? counterpartyMessageFromEnvelope(Uint8List script) {
  if (envelopeLeafKey(script) == null) return null;
  final ins = parseScript(script)!;
  // between OP_IF and OP_ENDIF <key> OP_CHECKSIG
  final body = ins.sublist(2, ins.length - 3);

  final isOrd = body.length >= 2 &&
      body[0].isPush &&
      _bytesEqual(body[0].push!, ascii.encode("ord")) &&
      body[1].isPush &&
      _bytesEqual(body[1].push!, const [7]);

  if (!isOrd) {
    final out = BytesBuilder();
    for (final i in body) {
      if (i.isPush) out.add(i.push!);
    }
    return out.toBytes();
  }

  // the parser reads the mime type at the fifth element of the body and the
  // sections after it, so a shorter body has no metadata
  if (body.length < 5) {
    throw const TapscriptException("ordinals envelope without metadata");
  }
  final mime = body[4].isPush ? _utf8OrEmpty(body[4].push!) : "";
  final metadata = BytesBuilder();
  final content = BytesBuilder();
  var section = 0; // 0 none, 1 metadata, 2 content
  for (var i = 5; i < body.length; i++) {
    final cur = body[i];
    if (!cur.isPush) continue; // OP_1..OP_16 carry no data
    final p = cur.push!;
    if (p.length == 1 && p[0] == 5) {
      section = 1;
      continue;
    }
    if (p.isEmpty || (p.length == 1 && p[0] == 0)) {
      section = 2;
      continue;
    }
    if (section == 1) metadata.add(p);
    if (section == 2) content.add(p);
  }
  if (metadata.isEmpty) {
    throw const TapscriptException("ordinals envelope without metadata");
  }

  Object? decoded;
  try {
    decoded = cborDecode(metadata.toBytes());
  } on CborException catch (e) {
    throw TapscriptException(
        "ordinals metadata is not valid CBOR: ${e.message}");
  }
  List<Object?> fields;
  if (decoded is List) {
    fields = List.of(decoded);
  } else if (decoded is CborMap) {
    final xcp = decoded["xcp"];
    if (xcp is! List || xcp.isEmpty) {
      throw const TapscriptException(
          "ordinals metadata map has no `xcp` message array");
    }
    fields = List.of(xcp);
  } else {
    throw const TapscriptException("ordinals metadata is not a CBOR array");
  }
  if (fields.isEmpty) {
    throw const TapscriptException("ordinals metadata array is empty");
  }
  final typeId = fields.removeAt(0);
  if (typeId is! int && typeId is! BigInt) {
    throw const TapscriptException("ordinals metadata has no message type id");
  }
  fields.add(mime);
  if (content.isNotEmpty) fields.add(content.toBytes());
  // `id as u8`: the low byte of the integer, two's complement
  final typeByte = ((typeId is BigInt ? typeId : BigInt.from(typeId as int)) &
          BigInt.from(0xff))
      .toInt();
  try {
    return Uint8List.fromList([typeByte, ...cborEncode(fields)]);
  } on CborException catch (e) {
    throw TapscriptException(
        "cannot re-encode the ordinals metadata: ${e.message}");
  }
}

/// The text of a UTF-8 byte string, or "" when it is not valid UTF-8 (the
/// parser's mime type).
String _utf8OrEmpty(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return "";
  }
}
