import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/tapscript.dart';

Uint8List h(String s) => Uint8List.fromList(hex.decode(s));

// OP_RETURN <"CNTRPRTY">
final opReturnCntrprty = h("6a08434e545250525459");

void main() {
  // Generated with bitcoinutils (the library the Counterparty Core composer
  // uses) and checked against the consensus rule in
  // counterparty-rs/src/reveal.rs: see the fixture file.
  final fixtures = json.decode(
          File("test/fixtures/taproot_reveal_fixtures.json").readAsStringSync())
      as Map<String, dynamic>;
  final cases = (fixtures["cases"] as List).cast<Map<String, dynamic>>();
  final negatives = fixtures["negatives"] as Map<String, dynamic>;

  Map<String, dynamic> byName(String name) =>
      cases.firstWhere((c) => c["name"] == name);

  List<TapLeafScriptEntry> leavesOf(Map<String, dynamic> c) => [
        TapLeafScriptEntry(
          leafVersion: 0xc0,
          script: h(c["envelope_script"]),
          controlBlock: h(c["reveal_control_block"]),
        )
      ];

  group("parseScript", () {
    test("decodes pushes of every size and opcodes", () {
      final script = h("00" // OP_FALSE
          "63" // OP_IF
          "0102" // push 1 byte
          "4c0103" // PUSHDATA1
          "4d010004" // PUSHDATA2
          "4e0100000005" // PUSHDATA4
          "51" // OP_1
          "68" // OP_ENDIF
          "ac"); // OP_CHECKSIG
      final ins = parseScript(script)!;
      expect(ins.length, 9);
      expect(ins[0].isPush && ins[0].push!.isEmpty, isTrue);
      expect(ins[1].opcode, 0x63);
      expect(ins[2].push, [2]);
      expect(ins[3].push, [3]);
      expect(ins[4].push, [4]);
      expect(ins[5].push, [5]);
      expect(ins[6].isPushNum, isTrue);
      expect(ins[7].opcode, 0x68);
      expect(ins[8].opcode, 0xac);
    });

    test("returns null on a truncated push", () {
      expect(parseScript(h("05aabb")), isNull);
      expect(parseScript(h("4d")), isNull);
      expect(parseScript(h("4c05aa")), isNull);
    });
  });

  group("envelopeLeafKey", () {
    for (final c in cases) {
      test("extracts the key of the ${c["name"]} envelope", () {
        expect(hex.encode(envelopeLeafKey(h(c["envelope_script"]))!),
            c["reveal_pubkey"]);
      });
    }

    final key = byName("p2wpkh_source_key")["reveal_pubkey"] as String;

    test("accepts OP_1NEGATE and OP_1..OP_16 inside the body", () {
      expect(envelopeLeafKey(h("0063" "4f51605f" "68" "20$key" "ac")),
          isNotNull);
    });

    test("rejects every non-canonical shape", () {
      // any other opcode inside the body (from the fixture: OP_NOP)
      final nop = negatives["non_canonical_op_nop"] as Map<String, dynamic>;
      expect(envelopeLeafKey(h(nop["envelope_script"])), isNull);
      // missing OP_FALSE
      expect(envelopeLeafKey(h("63" "0101" "68" "20$key" "ac")), isNull);
      // missing OP_IF
      expect(envelopeLeafKey(h("00" "0101" "68" "20$key" "ac")), isNull);
      // missing OP_ENDIF
      expect(envelopeLeafKey(h("0063" "0101" "20$key" "ac")), isNull);
      // 33-byte key
      expect(envelopeLeafKey(h("0063" "0101" "68" "2102$key" "ac")), isNull);
      // OP_CHECKSIGVERIFY instead of OP_CHECKSIG
      expect(envelopeLeafKey(h("0063" "0101" "68" "20$key" "ad")), isNull);
      // trailing OP_DROP after OP_CHECKSIG
      expect(envelopeLeafKey(h("0063" "0101" "68" "20$key" "ac75")), isNull);
      // OP_SUCCESS (OP_CAT 0x7e) inside the body
      expect(envelopeLeafKey(h("0063" "0101" "7e" "68" "20$key" "ac")), isNull);
      // key that is not on the curve (x = 0)
      expect(envelopeLeafKey(h("0063" "0101" "68" "20${"00" * 32}" "ac")),
          isNull);
      // bare <key> OP_CHECKSIG is not an envelope
      expect(envelopeLeafKey(h("20$key" "ac")), isNull);
    });
  });

  group("leafSignerKey", () {
    final key = byName("p2wpkh_source_key")["reveal_pubkey"] as String;
    test("accepts a bare <key> OP_CHECKSIG leaf and the envelope", () {
      expect(hex.encode(leafSignerKey(h("20$key" "ac"))!), key);
      expect(
          hex.encode(leafSignerKey(
              h(byName("p2wpkh_source_key")["envelope_script"]))!),
          key);
    });
    test("rejects anything else", () {
      expect(leafSignerKey(h("20$key" "ac75")), isNull);
      expect(leafSignerKey(h("0101" "20$key" "ac")), isNull);
      final nop = negatives["non_canonical_op_nop"] as Map<String, dynamic>;
      expect(leafSignerKey(h(nop["envelope_script"])), isNull);
    });
  });

  group("isCounterpartyRevealOutput", () {
    test("matches OP_RETURN CNTRPRTY only", () {
      expect(isCounterpartyRevealOutput(opReturnCntrprty), isTrue);
      expect(isCounterpartyRevealOutput(h("6a0c434e5452505254590102ab04")),
          isTrue);
      expect(isCounterpartyRevealOutput(h("6a")), isFalse);
      expect(isCounterpartyRevealOutput(h("6a0461626364")), isFalse);
      expect(isCounterpartyRevealOutput(h("6a07434e5452505254")), isFalse);
      expect(
          isCounterpartyRevealOutput(
              h(byName("p2wpkh_source_key")["reveal_lock_scripts"][0])),
          isFalse);
    });
  });

  group("control block and commitment", () {
    for (final c in cases) {
      test("${c["name"]}: the control block commits the envelope to commit:0",
          () {
        final cb = TapControlBlock.parse(h(c["reveal_control_block"]))!;
        expect(cb.leafVersion, 0xc0);
        expect(hex.encode(cb.internalKey), c["reveal_pubkey"]);
        expect(cb.path.length, c["name"] == "p2wpkh_two_leaf_tree" ? 1 : 0);
        expect(
            tapLeafCommitsToOutput(
                controlBlock: h(c["reveal_control_block"]),
                script: h(c["envelope_script"]),
                scriptPubKey: h(c["reveal_lock_scripts"][0])),
            isTrue);
      });
    }

    test("rejects a wrong parity, script, output or block length", () {
      final c = byName("p2wpkh_source_key");
      final cb = h(c["reveal_control_block"]);
      final env = h(c["envelope_script"]);
      final spk = h(c["reveal_lock_scripts"][0]);

      final flipped = Uint8List.fromList(cb)..[0] ^= 0x01;
      expect(
          tapLeafCommitsToOutput(
              controlBlock: flipped, script: env, scriptPubKey: spk),
          isFalse);

      final otherEnv = h(byName("p2wpkh_two_leaf_tree")["envelope_script"]);
      expect(
          tapLeafCommitsToOutput(
              controlBlock: cb, script: otherEnv, scriptPubKey: spk),
          isFalse);

      final otherSpk =
          h(byName("p2wpkh_two_leaf_tree")["reveal_lock_scripts"][0]);
      expect(
          tapLeafCommitsToOutput(
              controlBlock: cb, script: env, scriptPubKey: otherSpk),
          isFalse);

      expect(
          tapLeafCommitsToOutput(
              controlBlock: Uint8List.fromList(cb.sublist(0, 32)),
              script: env,
              scriptPubKey: spk),
          isFalse);

      // not a P2TR output
      expect(
          tapLeafCommitsToOutput(
              controlBlock: cb,
              script: env,
              scriptPubKey: h(c["source_script_pubkey"])),
          isFalse);

      // a foreign internal key that does commit to ITS own output is fine
      // for Bitcoin; the key check is done separately by the signing plan.
      final foreign = negatives["foreign_key"] as Map<String, dynamic>;
      expect(
          tapLeafCommitsToOutput(
              controlBlock: h(foreign["reveal_control_block"]),
              script: h(foreign["envelope_script"]),
              scriptPubKey: h(foreign["reveal_lock_scripts"][0])),
          isTrue);
    });

    test("BIP86 output key of the source matches its P2TR scriptPubKey", () {
      for (final name in ["p2tr_internal_key_ordinal", "p2tr_output_key_fallback"]) {
        final c = byName(name);
        final spk = c["source_script_pubkey"] as String;
        expect(hex.encode(bip86OutputKey(h(c["source_x_only"]))!),
            spk.substring(4));
      }
    });
  });

  group("planTapLeafSigning", () {
    TapLeafSigningPlan plan(Map<String, dynamic> c,
        {List<Uint8List>? outputs, int inputCount = 1, int? sighash}) {
      return planTapLeafSigning(
        xOnly: h(c["source_x_only"]),
        leaves: leavesOf(c),
        spentScriptPubKey: h(c["reveal_lock_scripts"][0]),
        outputScripts: outputs ?? [opReturnCntrprty],
        inputCount: inputCount,
        inputSighashType: sighash,
      )!;
    }

    test("leaves unknown leaf shapes to the PSBT library outside a reveal",
        () {
      final c = byName("p2wpkh_source_key");
      final key = c["reveal_pubkey"] as String;
      // <key> OP_CHECKSIGVERIFY <key> OP_CHECKSIG: not a shape this module
      // knows, and not a Counterparty reveal
      final unknown = TapLeafScriptEntry(
          leafVersion: 0xc0,
          script: h("20$key" "ad" "20$key" "ac"),
          controlBlock: h(c["reveal_control_block"]));
      expect(
          planTapLeafSigning(
            xOnly: h(c["source_x_only"]),
            leaves: [unknown],
            spentScriptPubKey: h(c["reveal_lock_scripts"][0]),
            outputScripts: [],
            inputCount: 1,
            inputSighashType: null,
          ),
          isNull);
      // the same leaf on a Counterparty reveal is refused
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: [unknown],
                spentScriptPubKey: h(c["reveal_lock_scripts"][0]),
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
    });

    test("signs with the raw key when the envelope holds the source key", () {
      for (final name in [
        "p2wpkh_source_key",
        "p2tr_internal_key_ordinal",
        "p2wpkh_two_leaf_tree"
      ]) {
        final p = plan(byName(name));
        expect(p.signerKey, RevealSignerKey.raw, reason: name);
        expect(p.isCounterpartyReveal, isTrue);
        expect(p.leafIndex, 0);
      }
    });

    test("signs with the tweaked key when the envelope holds the output key",
        () {
      final p = plan(byName("p2tr_output_key_fallback"));
      expect(p.signerKey, RevealSignerKey.tweaked);
    });

    test("accepts SIGHASH_DEFAULT and SIGHASH_ALL only on a reveal", () {
      final c = byName("p2wpkh_source_key");
      expect(plan(c, sighash: 0x00).signerKey, RevealSignerKey.raw);
      expect(plan(c, sighash: 0x01).signerKey, RevealSignerKey.raw);
      for (final bad in [0x02, 0x03, 0x81, 0x82, 0x83]) {
        expect(() => plan(c, sighash: bad), throwsA(isA<TapscriptException>()),
            reason: "sighash $bad");
      }
      // not a reveal: no restriction
      expect(plan(c, outputs: [], sighash: 0x81).isCounterpartyReveal, isFalse);
    });

    test("refuses a reveal with more than one input", () {
      final c = byName("p2wpkh_source_key");
      expect(() => plan(c, inputCount: 2), throwsA(isA<TapscriptException>()));
      expect(plan(c, outputs: [], inputCount: 2).isCounterpartyReveal, isFalse);
    });

    test("refuses an envelope closed by someone else's key", () {
      final c = byName("p2wpkh_source_key");
      final foreign = negatives["foreign_key"] as Map<String, dynamic>;
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: [
                  TapLeafScriptEntry(
                      leafVersion: 0xc0,
                      script: h(foreign["envelope_script"]),
                      controlBlock: h(foreign["reveal_control_block"]))
                ],
                spentScriptPubKey: h(foreign["reveal_lock_scripts"][0]),
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
    });

    test("refuses a non-canonical envelope on a reveal", () {
      final c = byName("p2wpkh_source_key");
      final nop = negatives["non_canonical_op_nop"] as Map<String, dynamic>;
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: [
                  TapLeafScriptEntry(
                      leafVersion: 0xc0,
                      script: h(nop["envelope_script"]),
                      controlBlock: h(nop["reveal_control_block"]))
                ],
                spentScriptPubKey: h(nop["reveal_lock_scripts"][0]),
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
    });

    test("refuses a leaf the control block does not commit to the output", () {
      final c = byName("p2wpkh_source_key");
      final other = byName("p2wpkh_two_leaf_tree");
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: leavesOf(c),
                spentScriptPubKey: h(other["reveal_lock_scripts"][0]),
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: leavesOf(c),
                spentScriptPubKey: null,
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
    });

    test("refuses a reveal under a non-tapscript leaf version", () {
      final c = byName("p2wpkh_source_key");
      final cb = Uint8List.fromList(h(c["reveal_control_block"]))..[0] = 0xc2;
      expect(
          () => planTapLeafSigning(
                xOnly: h(c["source_x_only"]),
                leaves: [
                  TapLeafScriptEntry(
                      leafVersion: 0xc2,
                      script: h(c["envelope_script"]),
                      controlBlock: cb)
                ],
                spentScriptPubKey: h(c["reveal_lock_scripts"][0]),
                outputScripts: [opReturnCntrprty],
                inputCount: 1,
                inputSighashType: null,
              ),
          throwsA(isA<TapscriptException>()));
    });

    test("picks the leaf closed by our key among several", () {
      final c = byName("p2wpkh_source_key");
      final foreign = negatives["foreign_key"] as Map<String, dynamic>;
      final p = planTapLeafSigning(
        xOnly: h(c["source_x_only"]),
        leaves: [
          TapLeafScriptEntry(
              leafVersion: 0xc0,
              script: h(foreign["envelope_script"]),
              controlBlock: h(foreign["reveal_control_block"])),
          ...leavesOf(c),
        ],
        spentScriptPubKey: h(c["reveal_lock_scripts"][0]),
        outputScripts: [opReturnCntrprty],
        inputCount: 1,
        inputSighashType: null,
      );
      expect(p!.leafIndex, 1);
    });
  });
}
