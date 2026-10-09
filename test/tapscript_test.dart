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

  final parserVectors = json.decode(
      File("test/fixtures/counterparty_parser_vectors.json")
          .readAsStringSync()) as Map<String, dynamic>;

  /// The P2TR output committing the single leaf `script` under
  /// `internalKey`, and the leaf's control block.
  ({Uint8List spent, Uint8List cb}) tapLeafCommitment(
      Uint8List script, Uint8List internalKey) {
    final q = taprootOutputKey(internalKey, tapLeafHash(script))!;
    return (
      spent: Uint8List.fromList([0x51, 0x20, ...q.xOnly]),
      cb: Uint8List.fromList([0xc0 | (q.isOdd ? 1 : 0), ...internalKey]),
    );
  }

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
      expect(
          envelopeLeafKey(h("0063" "4f51605f" "68" "20$key" "ac")), isNotNull);
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
      expect(
          envelopeLeafKey(h("0063" "0101" "68" "20${"00" * 32}" "ac")), isNull);
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

  group("arc4", () {
    test("matches the RC4 test vectors", () {
      expect(hex.encode(arc4(ascii.encode("Key"), ascii.encode("Plaintext"))),
          "bbf316e8d940af0ad3");
      expect(hex.encode(arc4(ascii.encode("Wiki"), ascii.encode("pedia"))),
          "1021bf0420");
      expect(arc4(const [], ascii.encode("CNTRPRTY")), isEmpty);
    });
  });

  group("classifyCounterpartyOutput", () {
    // Reveal transactions parsed by counterparty_rs itself
    // (generate_counterparty_parser_vectors.py): the wallet's reading of the
    // outputs must give the parser's reveal flag, destinations and data.
    final txid = h(parserVectors["first_input_txid"] as String);
    final envelopeMessage =
        counterpartyMessageFromEnvelope(h(parserVectors["generic_envelope"]))!;

    for (final v
        in (parserVectors["outputs"] as List).cast<Map<String, dynamic>>()) {
      test("reads the outputs of ${v["name"]} like the parser", () {
        final outputs =
            (v["output_scripts"] as List).cast<String>().map(h).toList();
        final classified =
            outputs.map((o) => classifyCounterpartyOutput(o, txid)).toList();

        // the parser's loop over the outputs (parse_transaction)
        var isReveal = false;
        var destinations = 0;
        var parseError = false;
        var afterChange = false;
        final data = BytesBuilder();
        for (final o in classified) {
          if (afterChange) continue;
          if (o.kind == CounterpartyOutputKind.other) {
            parseError = true;
            break;
          }
          if (o.kind == CounterpartyOutputKind.destination) {
            if (data.isEmpty) {
              destinations += 1;
            } else {
              afterChange = true;
            }
            continue;
          }
          if (o.isRevealMarker) {
            isReveal = true;
            data.add(envelopeMessage);
          } else {
            data.add(o.data!);
          }
        }

        expect(!parseError && isReveal, v["is_reveal"]);
        if (v["is_reveal"] as bool) {
          expect(destinations, v["destination_count"]);
          expect(hex.encode(data.toBytes()), v["data"]);
        }

        // a reveal is signed only when the parser reads the envelope's
        // message and nothing else
        final exact =
            v["is_reveal"] == true && v["data"] == hex.encode(envelopeMessage);
        if (exact) {
          expect(checkCounterpartyRevealOutputs(outputs, txid),
              v["destination_count"]);
        } else {
          expect(() => checkCounterpartyRevealOutputs(outputs, txid),
              throwsA(isA<TapscriptException>()));
        }
      });
    }

    test("refuses outputs a reveal has no reason to carry", () {
      final key = byName("p2wpkh_source_key")["reveal_pubkey"] as String;
      // a bare 1-of-1 multisig destination, a pay-to-pubkey, a witness v2
      for (final odd in [
        "51" "2102$key" "51ae",
        "2102$key" "ac",
        "5220${"11" * 32}",
      ]) {
        expect(classifyCounterpartyOutput(h(odd), txid).kind,
            CounterpartyOutputKind.other,
            reason: odd);
        expect(
            () => checkCounterpartyRevealOutputs(
                [opReturnCntrprty, h(odd)], txid),
            throwsA(isA<TapscriptException>()));
      }
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
      for (final name in [
        "p2tr_internal_key_ordinal",
        "p2tr_output_key_fallback"
      ]) {
        final c = byName(name);
        final spk = c["source_script_pubkey"] as String;
        expect(hex.encode(bip86OutputKey(h(c["source_x_only"]))!),
            spk.substring(4));
      }
    });
  });

  group("counterpartyMessageFromEnvelope", () {
    // Envelopes built by the composer's generate_envelope_script and
    // generate_ordinal_envelope_script around real sweep and issuance
    // messages; `message` is what the consensus parser rebuilds.
    final messages = json.decode(
        File("test/fixtures/counterparty_reveal_messages.json")
            .readAsStringSync()) as Map<String, dynamic>;
    final vectors = (messages["vectors"] as List).cast<Map<String, dynamic>>();

    for (final v in vectors) {
      test("rebuilds the ${v["name"]} message", () {
        final script = h(v["envelope_script"]);
        expect(hex.encode(envelopeLeafKey(script)!), messages["envelope_key"]);
        final message = counterpartyMessageFromEnvelope(script)!;
        expect(hex.encode(message), v["message"]);
        expect(message[0], v["message_type_id"]);
      });
    }

    test("returns null outside a canonical envelope", () {
      final key = messages["envelope_key"] as String;
      expect(counterpartyMessageFromEnvelope(h("20$key" "ac")), isNull);
      expect(
          counterpartyMessageFromEnvelope(
              h("0063" "0101" "75" "68" "20$key" "ac")),
          isNull);
    });

    test("rejects a malformed ordinals envelope", () {
      final key = messages["envelope_key"] as String;
      // "ord" 0x07 "xcp" 0x01 mime, then no metadata at all
      expect(
          () => counterpartyMessageFromEnvelope(h("0063"
              "036f7264"
              "0107"
              "03786370"
              "0101"
              "0a746578742f706c61696e"
              "00"
              "0568656c6c6f"
              "68"
              "20$key"
              "ac")),
          throwsA(isA<TapscriptException>()));
      // metadata that is not CBOR
      expect(
          () => counterpartyMessageFromEnvelope(h("0063"
              "036f7264"
              "0107"
              "03786370"
              "0101"
              "0a746578742f706c61696e"
              "0105"
              "03ffffff"
              "68"
              "20$key"
              "ac")),
          throwsA(isA<TapscriptException>()));
      // a metadata map without the xcp key
      expect(
          () => counterpartyMessageFromEnvelope(h("0063"
              "036f7264"
              "0107"
              "03786370"
              "0101"
              "0a746578742f706c61696e"
              "0105"
              "04a1616101"
              "68"
              "20$key"
              "ac")),
          throwsA(isA<TapscriptException>()));
    });
  });

  group("counterpartyMessageFromEnvelope against the parser", () {
    // envelopes whose message counterparty_rs rebuilt itself, through the
    // serde_cbor round trip for the ordinals form (tags, floats, map order,
    // indefinite lengths, type id truncation...); null when it rejects them
    for (final v
        in (parserVectors["envelopes"] as List).cast<Map<String, dynamic>>()) {
      test(v["name"] as String, () {
        final script = h(v["envelope_script"]);
        final expected = v["message"] as String?;
        if (expected == null) {
          expect(() => counterpartyMessageFromEnvelope(script),
              throwsA(isA<TapscriptException>()));
        } else {
          expect(
              hex.encode(counterpartyMessageFromEnvelope(script)!), expected);
        }
      });
    }
  });

  group("planTapLeafSigning", () {
    final commitTxid = h(byName("p2wpkh_source_key")["commit_txid"] as String);
    final arc4Marker = Uint8List.fromList(
        [0x6a, 16, ...arc4(commitTxid, ascii.encode("CNTRPRTYCNTRPRTY"))]);
    final p2wpkh = h(byName("p2wpkh_source_key")["source_script_pubkey"]);

    TapLeafSigningPlan? planFor(
      Map<String, dynamic> c, {
      List<TapLeafScriptEntry>? leaves,
      Uint8List? spent,
      bool spentKnown = true,
      List<Uint8List>? outputs,
      int inputCount = 1,
      int? sighash,
      bool? taproot,
    }) =>
        planTapLeafSigning(
          xOnly: h(c["source_x_only"]),
          signerIsTaprootAddress: taproot ?? c["source_type"] == "p2tr",
          leaves: leaves ?? leavesOf(c),
          spentScriptPubKey:
              spentKnown ? spent ?? h(c["reveal_lock_scripts"][0]) : null,
          outputScripts: outputs ?? [opReturnCntrprty],
          firstInputTxid: h(c["commit_txid"]),
          inputCount: inputCount,
          inputSighashType: sighash,
        );

    TapLeafSigningPlan plan(Map<String, dynamic> c,
            {List<Uint8List>? outputs, int inputCount = 1, int? sighash}) =>
        planFor(c, outputs: outputs, inputCount: inputCount, sighash: sighash)!;

    Matcher refusal(String reason) => throwsA(isA<TapscriptException>()
        .having((e) => e.message, "message", contains(reason)));

    test("leaves unknown leaf shapes to the PSBT library outside a reveal", () {
      final c = byName("p2wpkh_source_key");
      final key = c["reveal_pubkey"] as String;
      // <key> OP_CHECKSIGVERIFY <key> OP_CHECKSIG: not a shape this module
      // knows, and not a Counterparty reveal
      final unknown = TapLeafScriptEntry(
          leafVersion: 0xc0,
          script: h("20$key" "ad" "20$key" "ac"),
          controlBlock: h(c["reveal_control_block"]));
      expect(planFor(c, leaves: [unknown], outputs: [p2wpkh]), isNull);
      // the same leaf on a Counterparty reveal is refused, whatever form
      // the marker takes
      for (final marker in [opReturnCntrprty, arc4Marker]) {
        expect(() => planFor(c, leaves: [unknown], outputs: [marker]),
            refusal("network would ignore"));
      }
    });

    test("signs a bare <key> OP_CHECKSIG leaf without the reveal shape", () {
      final c = byName("p2wpkh_source_key");
      final key = c["reveal_pubkey"] as String;
      final bare = h("20$key" "ac");
      final commit = tapLeafCommitment(bare, h(c["source_x_only"]));
      final p = planFor(c,
          leaves: [
            TapLeafScriptEntry(
                leafVersion: 0xc0, script: bare, controlBlock: commit.cb)
          ],
          spent: commit.spent,
          outputs: [p2wpkh],
          inputCount: 2,
          sighash: 0x81)!;
      expect(p.isCounterpartyReveal, isFalse);
      expect(p.markerOutputIndex, isNull);
      expect(p.leafHash, tapLeafHash(bare));
    });

    test("signs with the raw key when the envelope holds the source key", () {
      for (final name in [
        "p2wpkh_source_key",
        "p2tr_internal_key_ordinal",
        "p2wpkh_two_leaf_tree"
      ]) {
        final c = byName(name);
        final p = plan(c);
        expect(p.signerKey, RevealSignerKey.raw, reason: name);
        expect(p.isCounterpartyReveal, isTrue);
        expect(p.leafIndex, 0);
        expect(p.markerOutputIndex, 0);
        expect(p.leafHash, tapLeafHash(h(c["envelope_script"])));
      }
    });

    test("signs with the tweaked key when the envelope holds the output key",
        () {
      final p = plan(byName("p2tr_output_key_fallback"));
      expect(p.signerKey, RevealSignerKey.tweaked);
    });

    test("refuses the BIP86 key of an address that is not taproot", () {
      // Counterparty takes only the key of a P2WPKH or P2PKH source: an
      // envelope closed by its BIP86 output key would be ignored
      final c = byName("p2tr_output_key_fallback");
      expect(() => planFor(c, taproot: false), refusal("network would ignore"));
    });

    test("recognizes the reveal marker in every form the parser does", () {
      final c = byName("p2wpkh_source_key");
      expect(plan(c, outputs: [arc4Marker, p2wpkh]).markerOutputIndex, 0);
      expect(plan(c, outputs: [p2wpkh, opReturnCntrprty]).markerOutputIndex, 1);
    });

    test("holds a canonical envelope to the reveal shape without the marker",
        () {
      // the parser attributes the message whatever the wallet thinks of the
      // outputs: an envelope closed by our key is always a reveal
      final c = byName("p2wpkh_source_key");
      expect(() => plan(c, outputs: [p2wpkh]), refusal("CNTRPRTY output"));
      expect(() => plan(c, outputs: [arc4Marker], inputCount: 2),
          refusal("exactly one input"));
      expect(() => plan(c, outputs: [arc4Marker], sighash: 0x81),
          refusal("SIGHASH"));
    });

    test("refuses Counterparty data besides the envelope", () {
      final c = byName("p2wpkh_source_key");
      final extra = Uint8List.fromList(
          [0x6a, 12, ...arc4(commitTxid, ascii.encode("CNTRPRTYtail"))]);
      expect(() => plan(c, outputs: [opReturnCntrprty, extra]),
          refusal("besides the envelope"));
      expect(() => plan(c, outputs: [opReturnCntrprty, arc4Marker]),
          refusal("single CNTRPRTY output"));
    });

    test("accepts SIGHASH_DEFAULT and SIGHASH_ALL only on a reveal", () {
      final c = byName("p2wpkh_source_key");
      expect(plan(c, sighash: 0x00).signerKey, RevealSignerKey.raw);
      expect(plan(c, sighash: 0x01).signerKey, RevealSignerKey.raw);
      for (final bad in [0x02, 0x03, 0x81, 0x82, 0x83]) {
        expect(() => plan(c, sighash: bad), refusal("SIGHASH"),
            reason: "sighash $bad");
      }
    });

    test("refuses a reveal with more than one input", () {
      final c = byName("p2wpkh_source_key");
      expect(() => plan(c, inputCount: 2), refusal("exactly one input"));
    });

    test("refuses an envelope closed by someone else's key", () {
      final c = byName("p2wpkh_source_key");
      final foreign = negatives["foreign_key"] as Map<String, dynamic>;
      expect(
          () => planFor(c,
              leaves: [
                TapLeafScriptEntry(
                    leafVersion: 0xc0,
                    script: h(foreign["envelope_script"]),
                    controlBlock: h(foreign["reveal_control_block"]))
              ],
              spent: h(foreign["reveal_lock_scripts"][0])),
          refusal("network would ignore"));
    });

    test("refuses a non-canonical envelope on a reveal", () {
      final c = byName("p2wpkh_source_key");
      final nop = negatives["non_canonical_op_nop"] as Map<String, dynamic>;
      expect(
          () => planFor(c,
              leaves: [
                TapLeafScriptEntry(
                    leafVersion: 0xc0,
                    script: h(nop["envelope_script"]),
                    controlBlock: h(nop["reveal_control_block"]))
              ],
              spent: h(nop["reveal_lock_scripts"][0])),
          refusal("network would ignore"));
    });

    test("refuses a leaf the control block does not commit to the output", () {
      final c = byName("p2wpkh_source_key");
      final other = byName("p2wpkh_two_leaf_tree");
      expect(() => planFor(c, spent: h(other["reveal_lock_scripts"][0])),
          refusal("does not commit"));
      expect(() => planFor(c, spentKnown: false), refusal("witnessUtxo"));
    });

    test("refuses a reveal under a non-tapscript leaf version", () {
      final c = byName("p2wpkh_source_key");
      final cb = Uint8List.fromList(h(c["reveal_control_block"]))..[0] = 0xc2;
      expect(
          () => planFor(c, leaves: [
                TapLeafScriptEntry(
                    leafVersion: 0xc2,
                    script: h(c["envelope_script"]),
                    controlBlock: cb)
              ]),
          throwsA(isA<TapscriptException>()));
      // a PSBT entry whose leaf version is not its control block's
      expect(
          () => planFor(c, leaves: [
                TapLeafScriptEntry(
                    leafVersion: 0xc2,
                    script: h(c["envelope_script"]),
                    controlBlock: h(c["reveal_control_block"]))
              ]),
          refusal("leaf version"));
    });

    test("picks the leaf closed by our key among several", () {
      final c = byName("p2wpkh_source_key");
      final foreign = negatives["foreign_key"] as Map<String, dynamic>;
      final p = planFor(c, leaves: [
        TapLeafScriptEntry(
            leafVersion: 0xc0,
            script: h(foreign["envelope_script"]),
            controlBlock: h(foreign["reveal_control_block"])),
        ...leavesOf(c),
      ])!;
      expect(p.leafIndex, 1);
      expect(p.leafHash, tapLeafHash(h(c["envelope_script"])));
    });
  });
}
