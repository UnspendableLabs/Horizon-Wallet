import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:horizon/common/tapscript.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart' as dbtc;
import 'package:horizon/domain/entities/counterparty_reveal.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/utxo_attach.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_attach_repository.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/usecases/get_augmented_psbt_data.dart';

class MockTransactionService extends Mock implements TransactionService {}

class MockBitcoindService extends Mock implements BitcoindService {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockEventsRepository extends Mock implements EventsRepository {}

class MockUtxoAttachRepository extends Mock implements UtxoAttachRepository {}

class MockErrorService extends Mock implements ErrorService {}

class MockTransactionRepository extends Mock implements TransactionRepository {}

// OP_RETURN <"CNTRPRTY">
const opReturnCntrprty = "6a08434e545250525459";
const p2wpkhOther = "0014a3df8a5a83d4e2827b59b43f5ce6ce5d2e52093f";

Uint8List h(String s) => Uint8List.fromList(hex.decode(s));

/// The P2TR output committing `leaves` (one or two) under `internalKey`, and
/// the control block of each leaf.
({Uint8List spent, List<Uint8List> controlBlocks}) commitTo(
    List<Uint8List> leaves, Uint8List internalKey) {
  final hashes = leaves.map((l) => tapLeafHash(l)).toList();
  final root =
      hashes.length == 1 ? hashes[0] : tapBranchHash(hashes[0], hashes[1]);
  final q = taprootOutputKey(internalKey, root)!;
  final parity = q.isOdd ? 1 : 0;
  return (
    spent: Uint8List.fromList([0x51, 0x20, ...q.xOnly]),
    controlBlocks: [
      for (var i = 0; i < leaves.length; i++)
        Uint8List.fromList([
          0xc0 | parity,
          ...internalKey,
          if (hashes.length == 2) ...hashes[1 - i],
        ]),
    ],
  );
}

void main() {
  final reveals = json.decode(
          File("test/fixtures/taproot_reveal_fixtures.json").readAsStringSync())
      as Map<String, dynamic>;
  final messages = json.decode(
      File("test/fixtures/counterparty_reveal_messages.json")
          .readAsStringSync()) as Map<String, dynamic>;
  // both fixture files derive the envelope key from the same seed
  final source = (reveals["cases"] as List)
      .cast<Map<String, dynamic>>()
      .firstWhere((c) => c["name"] == "p2wpkh_source_key");
  final vectors = (messages["vectors"] as List).cast<Map<String, dynamic>>();
  Map<String, dynamic> vector(String name) =>
      vectors.firstWhere((v) => v["name"] == name);

  final sourceAddress = source["source_address"] as String;
  final otherAddress = "bcrt1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej";
  final addresses = [
    AddressV2(
      type: AddressV2Type.p2wpkh,
      address: sourceAddress,
      derivation: Bip32Path(value: "m/84'/1'/0'/0/0"),
      publicKey: source["source_public_key"] as String,
    ),
    AddressV2(
      type: AddressV2Type.p2wpkh,
      address: otherAddress,
      derivation: Bip32Path(value: "m/84'/1'/0'/0/1"),
      publicKey:
          "02f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9",
    ),
  ];

  late MockTransactionService transactionService;
  late MockBitcoindService bitcoindService;
  late MockBitcoinRepository bitcoinRepository;
  late MockBalanceRepository balanceRepository;
  late MockEventsRepository eventsRepository;
  late MockUtxoAttachRepository utxoAttachRepository;
  late MockErrorService errorService;
  late MockTransactionRepository transactionRepository;
  late GetAugmentedPsbtDataUseCase useCase;

  setUpAll(() {
    registerFallbackValue(HttpConfig.mainnet());
    registerFallbackValue(UtxoID.fromString("${"00" * 32}:0"));
  });

  dbtc.Vout vout(int n, String hex, {String? address, double value = 0}) =>
      dbtc.Vout(
        value: value,
        n: n,
        scriptPubKey: dbtc.ScriptPubKey(
          asm: address == null ? "OP_RETURN" : "",
          desc: "",
          hex: hex,
          address: address,
          type: address == null ? "nulldata" : "witness_v0_keyhash",
        ),
      );

  dbtc.DecodedTx decoded(List<dbtc.Vout> vouts) => dbtc.DecodedTx(
        txid: "reveal",
        hash: "reveal",
        version: 2,
        size: 100,
        vsize: 100,
        weight: 400,
        locktime: 0,
        vin: [
          dbtc.Vin(
            txid: source["commit_txid"] as String,
            vout: 0,
            scriptSig: const dbtc.ScriptSig(asm: "", hex: ""),
            sequence: 0xffffffff,
          )
        ],
        vout: vouts,
      );

  setUp(() {
    transactionService = MockTransactionService();
    bitcoindService = MockBitcoindService();
    bitcoinRepository = MockBitcoinRepository();
    balanceRepository = MockBalanceRepository();
    eventsRepository = MockEventsRepository();
    utxoAttachRepository = MockUtxoAttachRepository();
    errorService = MockErrorService();
    transactionRepository = MockTransactionRepository();
    useCase = GetAugmentedPsbtDataUseCase(
      transactionService: transactionService,
      bitcoindService: bitcoindService,
      bitcoinRepository: bitcoinRepository,
      balanceRepository: balanceRepository,
      eventsRepository: eventsRepository,
      utxoAttachRepository: utxoAttachRepository,
      errorService: errorService,
      transactionRepository: transactionRepository,
    );

    when(() => transactionService.psbtToUnsignedTransactionHex(any()))
        .thenReturn("00");
    // the commit is not broadcast yet: the explorer does not know it
    when(() => bitcoinRepository.getTransaction(
            txid: any(named: "txid"), httpConfig: any(named: "httpConfig")))
        .thenThrow(Exception("Transaction not found"));
    when(() => balanceRepository.getBalancesForUTXO(
            httpConfig: any(named: "httpConfig"),
            utxo: any(named: "utxo"),
            queryMempool: any(named: "queryMempool")))
        .thenAnswer((_) async => <Balance>[]);
    when(() => eventsRepository.getAllMempoolVerboseEventsForAddresses(
        any(), any(), any())).thenAnswer((_) async => <VerboseEvent>[]);
    when(() => utxoAttachRepository.getByID(any()))
        .thenAnswer((_) async => null as UtxoAttach?);
    when(() => errorService.captureException(any(),
        stackTrace: any(named: "stackTrace"),
        message: any(named: "message"),
        context: any(named: "context"))).thenReturn(null);
  });

  final sourceXOnly = h(source["source_x_only"] as String);
  final commitTxid = source["commit_txid"] as String;
  final prefixHex = hex.encode(counterpartyPrefix);
  Uint8List envelopeOf(String name) =>
      h(vector(name)["envelope_script"] as String);

  Uint8List push(List<int> data) => Uint8List.fromList([
        if (data.length < 0x4c)
          data.length
        else if (data.length < 0x100) ...[
          0x4c,
          data.length
        ] else ...[
          0x4d,
          data.length & 0xff,
          data.length >> 8
        ],
        ...data,
      ]);

  /// `OP_FALSE OP_IF <items> OP_ENDIF <source key> OP_CHECKSIG`, each item
  /// pushed in chunks of 520 bytes at most; an int item is a raw opcode.
  Uint8List envelopeWith(List<Object> items) {
    final b = BytesBuilder()..add([0x00, 0x63]);
    for (final item in items) {
      if (item is int) {
        b.addByte(item);
        continue;
      }
      final data = item as List<int>;
      if (data.isEmpty) b.add(push(data));
      for (var i = 0; i < data.length; i += 520) {
        b.add(push(
            data.sublist(i, i + 520 < data.length ? i + 520 : data.length)));
      }
    }
    return (b
          ..addByte(0x68)
          ..add(push(sourceXOnly))
          ..addByte(0xac))
        .toBytes();
  }

  final arc4Marker = Uint8List.fromList([
    0x6a,
    16,
    ...arc4(h(commitTxid), ascii.encode("CNTRPRTYCNTRPRTY")),
  ]);

  /// A reveal PSBT spending a commit of `leaves` (each closed by the source
  /// key unless said otherwise), with `outputs` as (script hex, address).
  void givenPsbt(
    List<Uint8List> leaves, {
    List<(String, String?)>? outputs,
    Uint8List? internalKey,
  }) {
    final commit = commitTo(leaves, internalKey ?? sourceXOnly);
    final outs = outputs ?? [(opReturnCntrprty, null)];
    when(() => bitcoindService.decoderawtransaction(
            raw: any(named: "raw"), httpConfig: any(named: "httpConfig")))
        .thenAnswer((_) async => decoded([
              for (var i = 0; i < outs.length; i++)
                vout(i, outs[i].$1,
                    address: outs[i].$2,
                    value: outs[i].$2 == null ? 0 : 0.00000546),
            ]));
    when(() => transactionService.describePsbt(any(), any()))
        .thenReturn(PsbtDescription(
      inputs: [
        PsbtInputDescription(
          prevoutTxid: h(commitTxid),
          witnessUtxoScript: commit.spent,
          witnessUtxoValue: source["reveal_inputs_values"][0] as int,
          witnessUtxoAddress: source["commit_address"] as String,
          tapLeafScripts: [
            for (var i = 0; i < leaves.length; i++)
              TapLeafScriptEntry(
                leafVersion: 0xc0,
                script: leaves[i],
                controlBlock: commit.controlBlocks[i],
              ),
          ],
          sighashType: null,
        )
      ],
      outputScripts: [for (final o in outs) h(o.$1)],
    ));
  }

  void givenRevealPsbt(String vectorName, {List<(String, String?)>? outputs}) =>
      givenPsbt([envelopeOf(vectorName)], outputs: outputs);

  void givenUnpacked(CounterpartyMessage message) {
    when(() => transactionRepository.unpackMessage(
        datahex: any(named: "datahex"),
        httpConfig: any(named: "httpConfig"))).thenAnswer((_) async => message);
  }

  const issuance = CounterpartyMessage(
    messageType: "issuance",
    messageTypeId: 22,
    messageData: {"asset": "A95428956661682189", "reset": false},
  );

  Future<AugmentedPsbtData> run({Map<String, List<int>>? signInputs}) async {
    final result = await useCase
        .call(GetAugmentedPsbtDataParams(
          httpConfig: HttpConfig.mainnet(),
          unsignedPsbt: "70736274ff",
          addresses: addresses,
          signInputs: signInputs ??
              {
                sourceAddress: [0]
              },
        ))
        .run();
    return result.fold((l) => throw Exception("use case failed: $l"), (r) => r);
  }

  group("GetAugmentedPsbtDataUseCase on a Counterparty reveal", () {
    test("decodes a sweep with the node and flags it as high impact", () async {
      givenRevealPsbt("sweep_raw");
      givenUnpacked(const CounterpartyMessage(
        messageType: "sweep",
        messageTypeId: 4,
        messageData: {
          "destination": "bcrt1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej",
          "flags": 7,
          "memo": null,
        },
      ));

      final data = await run();
      final reveal = data.counterpartyReveal!;

      // the bytes sent to the node are the message rebuilt from the envelope,
      // behind the CNTRPRTY prefix the node strips
      verify(() => transactionRepository.unpackMessage(
          datahex: "$prefixHex${vector("sweep_raw")["message"]}",
          httpConfig: any(named: "httpConfig"))).called(1);
      expect(data.tapscriptRefusal, isNull);
      expect(reveal.messageHex, vector("sweep_raw")["message"]);
      expect(reveal.message!.messageType, "sweep");
      expect(reveal.sourceAddress, sourceAddress);
      // the leaf the signer will sign, and only that one
      expect(
          reveal.leafHashHex, hex.encode(tapLeafHash(envelopeOf("sweep_raw"))));
      expect(reveal.destinations, isEmpty);
      expect(reveal.risk, RevealRisk.high);
      expect(reveal.requiresAcknowledgement, isTrue);
      expect(reveal.messageTypeLabel, "sweep");
      final entries = Map.fromEntries(reveal.entries);
      expect(entries["destination"],
          "bcrt1qphlpxevt78x4g8t5s9aj0dpr9lfsjt9vlss6ej");
      expect(entries["flags"], "balances, ownership, binary memo (7)");
      expect(entries.containsKey("memo"), isFalse);

      // the reveal input itself is described from the PSBT, as a user debit
      expect(data.augmentedInputs.single.prevOut.value, 1500);
      expect(data.augmentedInputs.single.prevOut.scriptpubkeyType, "v1_p2tr");
      expect(data.augmentedInputs.single.signatureRequired, isTrue);
      expect(data.augmentedInputs.single.confirmed, isFalse);
      expect(data.debits.single.asset, "BTC");
    });

    for (final name in [
      "issuance_raw",
      "issuance_ordinals",
      "issuance_ordinals_map"
    ]) {
      test("decodes an $name issuance as an ordinary message", () async {
        givenRevealPsbt(name);
        givenUnpacked(const CounterpartyMessage(
          messageType: "issuance",
          messageTypeId: 22,
          messageData: {
            "asset_id": 95428956661682189,
            "asset": "A95428956661682189",
            "quantity": 100000000000,
            "quantity_normalized": "1000.00000000",
            "divisible": true,
            "lock": false,
            "reset": false,
            "description": "An asset described in a taproot envelope.",
            "asset_info": {"divisible": true},
          },
        ));

        final data = await run();
        final reveal = data.counterpartyReveal!;

        // whatever the envelope form, the node receives the same message
        verify(() => transactionRepository.unpackMessage(
            datahex: "$prefixHex${vector(name)["message"]}",
            httpConfig: any(named: "httpConfig"))).called(1);
        expect(reveal.risk, RevealRisk.normal);
        expect(reveal.requiresAcknowledgement, isFalse);
        final entries = Map.fromEntries(reveal.entries);
        expect(entries["asset"], "A95428956661682189");
        expect(entries["quantity"], "1000.00000000");
        expect(entries["reset"], "false");
        // raw quantity, asset id and nested asset info are not listed
        expect(entries.containsKey("asset id"), isFalse);
        expect(entries.containsKey("asset info"), isFalse);
        expect(reveal.entries.where((e) => e.key == "quantity").length, 1);
      });
    }

    test(
        "flags an issuance with a destination before the data output (ownership transfer)",
        () async {
      // an address output placed BEFORE the CNTRPRTY output is a
      // Counterparty destination; the parser makes it the asset's issuer
      givenRevealPsbt("issuance_raw", outputs: [
        (p2wpkhOther, otherAddress),
        (opReturnCntrprty, null),
      ]);
      givenUnpacked(issuance);

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.destinations, [otherAddress]);
      expect(reveal.risk, RevealRisk.high);
      expect(reveal.riskReason, contains("owner"));
    });

    test("an address output after the data output is change, not a destination",
        () async {
      givenRevealPsbt("issuance_raw", outputs: [
        (opReturnCntrprty, null),
        (p2wpkhOther, otherAddress),
      ]);
      givenUnpacked(issuance);

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.destinations, isEmpty);
      expect(reveal.risk, RevealRisk.normal);
    });

    test("recognizes a reveal whose CNTRPRTY output is ARC4-obfuscated",
        () async {
      // the parser deobfuscates OP_RETURN data with the txid of the first
      // input's prevout: this is a reveal as much as the clear marker
      givenRevealPsbt("sweep_raw", outputs: [
        (hex.encode(arc4Marker), null),
        (p2wpkhOther, otherAddress),
      ]);
      givenUnpacked(const CounterpartyMessage(
        messageType: "sweep",
        messageTypeId: 4,
        messageData: {"destination": "x", "flags": 1},
      ));

      final data = await run();
      expect(data.tapscriptRefusal, isNull);
      expect(data.counterpartyReveal!.message!.messageType, "sweep");
      expect(data.counterpartyReveal!.risk, RevealRisk.high);
    });

    test("shows the leaf that gets signed when several are closed by the key",
        () async {
      // a benign issuance first, a sweep second, both closed by the source
      // key and committed by the same output: the wallet shows, and signs,
      // the first only
      givenPsbt([envelopeOf("issuance_raw"), envelopeOf("sweep_raw")]);
      givenUnpacked(issuance);

      final reveal = (await run()).counterpartyReveal!;
      verify(() => transactionRepository.unpackMessage(
          datahex: "$prefixHex${vector("issuance_raw")["message"]}",
          httpConfig: any(named: "httpConfig"))).called(1);
      expect(reveal.leafHashHex,
          hex.encode(tapLeafHash(envelopeOf("issuance_raw"))));
    });

    test("refuses up front a reveal the signer would refuse", () async {
      // Counterparty data besides the envelope would change the message
      final p2pkhData = Uint8List.fromList([
        0x76,
        0xa9,
        0x14,
        ...arc4(h(commitTxid),
            [9, ...ascii.encode("CNTRPRTY"), 4, ...List.filled(10, 0)]),
        0x88,
        0xac,
      ]);
      givenRevealPsbt("issuance_raw", outputs: [
        (hex.encode(p2pkhData), null),
        (opReturnCntrprty, null),
      ]);
      var data = await run();
      expect(data.counterpartyReveal, isNull);
      expect(data.tapscriptRefusal, contains("besides the envelope"));

      // a canonical envelope without its CNTRPRTY output
      givenRevealPsbt("issuance_raw", outputs: [(p2wpkhOther, otherAddress)]);
      data = await run();
      expect(data.counterpartyReveal, isNull);
      expect(data.tapscriptRefusal, contains("CNTRPRTY output"));

      verifyNever(() => transactionRepository.unpackMessage(
          datahex: any(named: "datahex"),
          httpConfig: any(named: "httpConfig")));
    });

    test("refuses an envelope not closed by the designated address' key",
        () async {
      givenRevealPsbt("sweep_raw");

      final data = await run(signInputs: {
        otherAddress: [0]
      });
      expect(data.counterpartyReveal, isNull);
      expect(data.tapscriptRefusal, contains("closed by this address' key"));
    });

    test("warns when the message cannot be decoded", () async {
      givenRevealPsbt("unknown_type");
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenThrow(Exception("Failed to unpack Counterparty message"));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.message, isNull);
      expect(reveal.decodeError, contains("Failed to unpack"));
      expect(reveal.risk, RevealRisk.unrecognized);
      expect(reveal.requiresAcknowledgement, isTrue);
      expect(reveal.messageTypeLabel, "unknown");
    });

    test("warns when the node does not know the message type", () async {
      givenRevealPsbt("unknown_type");
      givenUnpacked(const CounterpartyMessage(
        messageType: "unknown",
        messageTypeId: 255,
        messageData: {"error": "Unknown message type"},
      ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.risk, RevealRisk.unrecognized);
      expect(reveal.entries, isEmpty);
    });

    test("warns when the node cannot unpack a message of a known type",
        () async {
      givenRevealPsbt("issuance_raw");
      givenUnpacked(const CounterpartyMessage(
        messageType: "issuance",
        messageTypeId: 22,
        messageData: {"error": "invalid asset name"},
      ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.decodeError, "invalid asset name");
      expect(reveal.risk, RevealRisk.unrecognized);
      expect(reveal.requiresAcknowledgement, isTrue);
    });

    test("keeps a leading CNTRPRTY in the message the node decodes", () async {
      // the parser reads this message from its first byte; the node would
      // strip the prefix and decode what follows
      givenPsbt([
        envelopeWith([
          [...counterpartyPrefix, 4, 0x78]
        ])
      ]);
      givenUnpacked(const CounterpartyMessage(
        messageType: "unknown",
        messageTypeId: 67,
        messageData: {"error": "Unknown message type"},
      ));

      final reveal = (await run()).counterpartyReveal!;
      verify(() => transactionRepository.unpackMessage(
          datahex: "$prefixHex${prefixHex}0478",
          httpConfig: any(named: "httpConfig"))).called(1);
      expect(reveal.messageHex, "${prefixHex}0478");
      expect(reveal.risk, RevealRisk.unrecognized);
    });

    test("decodes a long inscription without its content", () async {
      // [22, 1000, 100, true, false, false]: an issuance, whose description
      // is the 10 KB content
      final envelope = envelopeWith([
        ascii.encode("ord"),
        [7],
        ascii.encode("xcp"),
        [1],
        ascii.encode("image/png"),
        [5],
        h("86" "16" "1903e8" "1864" "f5" "f4" "f4"),
        0x00,
        List.filled(10000, 0xab),
      ]);
      givenPsbt([envelope]);
      givenUnpacked(const CounterpartyMessage(
        messageType: "issuance",
        messageTypeId: 22,
        messageData: {
          "asset": "A95428956661682189",
          "reset": false,
          "mime_type": "image/png",
          "description": "",
        },
      ));

      final reveal = (await run()).counterpartyReveal!;
      final message = counterpartyEnvelopeMessage(envelope)!;
      // the content field keeps its place, empty
      verify(() => transactionRepository.unpackMessage(
          datahex: "$prefixHex${hex.encode(message.bytesWithoutContent)}",
          httpConfig: any(named: "httpConfig"))).called(1);
      expect(hex.encode(message.bytesWithoutContent), endsWith("40"));
      // the message shown and signed is the whole one
      expect(reveal.messageHex, hex.encode(message.bytes));
      expect(message.bytes.length, greaterThan(10000));
      expect(reveal.omittedContent,
          const OmittedContent(length: 10000, mimeType: "image/png"));
      expect(Map.fromEntries(reveal.entries)["description"],
          "image/png, 10000 bytes, too long to decode: not shown");
      expect(reveal.risk, RevealRisk.normal);
    });

    test("keeps a text content the node would not decode", () async {
      // a text content that is not UTF-8 sends the node back to the legacy
      // decoding of the whole message: without it, the node would read
      // another message
      Uint8List inscription(String mime, List<int> content) => envelopeWith([
            ascii.encode("ord"),
            [7],
            ascii.encode("xcp"),
            [1],
            ascii.encode(mime),
            [5],
            h("86" "16" "1903e8" "1864" "f5" "f4" "f4"),
            0x00,
            content,
          ]);
      givenUnpacked(issuance);

      for (final mime in ["text/plain", "", "application/json; x", "a+xml"]) {
        givenPsbt([inscription(mime, List.filled(5000, 0xff))]);
        final reveal = (await run()).counterpartyReveal!;
        expect(reveal.omittedContent, isNull, reason: mime);
        expect(reveal.decodeError, contains("too long"), reason: mime);
        expect(reveal.risk, RevealRisk.unrecognized, reason: mime);
      }
      verifyNever(() => transactionRepository.unpackMessage(
          datahex: any(named: "datahex"),
          httpConfig: any(named: "httpConfig")));

      // valid UTF-8 text, or content of a binary type, is left out
      for (final (mime, content) in [
        ("text/plain", List.filled(5000, 0x61)),
        ("image/webp", List.filled(5000, 0xff)),
      ]) {
        givenPsbt([inscription(mime, content)]);
        final reveal = (await run()).counterpartyReveal!;
        expect(reveal.omittedContent,
            OmittedContent(length: 5000, mimeType: mime));
        expect(reveal.decodeError, isNull);
      }
    });

    test("does not send the node a message too long for its URL", () async {
      givenPsbt([
        envelopeWith([List.filled(4000, 0x14)])
      ]);

      final reveal = (await run()).counterpartyReveal!;
      verifyNever(() => transactionRepository.unpackMessage(
          datahex: any(named: "datahex"),
          httpConfig: any(named: "httpConfig")));
      expect(reveal.decodeError, contains("too long (4000 bytes)"));
      expect(reveal.risk, RevealRisk.unrecognized);
    });

    test("lists each send of an MPMA send", () async {
      givenRevealPsbt("unknown_type");
      givenUnpacked(const CounterpartyMessage(
        messageType: "mpma_send",
        messageTypeId: 3,
        messageData: {
          "sends": [
            {"asset": "XCP", "destination": "bc1qa", "quantity": 100},
            {
              "asset": "PEPE",
              "destination": "bc1qb",
              "quantity": 5,
              "memo": "hi"
            },
          ]
        },
      ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.risk, RevealRisk.high);
      expect(reveal.entries.where((e) => e.key == "send").map((e) => e.value),
          ["100 XCP to bc1qa", "5 PEPE to bc1qb, memo hi"]);
    });

    test("describes nothing for a PSBT that is not a reveal", () async {
      when(() => bitcoindService.decoderawtransaction(
              raw: any(named: "raw"), httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => decoded([
                vout(0, p2wpkhOther, address: otherAddress, value: 0.001),
              ]));
      when(() => transactionService.describePsbt(any(), any()))
          .thenReturn(PsbtDescription(
        inputs: [
          PsbtInputDescription(
            prevoutTxid: h(commitTxid),
            witnessUtxoScript: h(source["source_script_pubkey"] as String),
            witnessUtxoValue: 200000,
            witnessUtxoAddress: sourceAddress,
            tapLeafScripts: const [],
            sighashType: null,
          )
        ],
        outputScripts: [h(p2wpkhOther)],
      ));

      final data = await run();
      expect(data.counterpartyReveal, isNull);
      expect(data.tapscriptRefusal, isNull);
      verifyNever(() => transactionRepository.unpackMessage(
          datahex: any(named: "datahex"),
          httpConfig: any(named: "httpConfig")));
    });
  });

  group("classifyRevealMessage", () {
    CounterpartyMessage msg(String type,
            [Map<String, dynamic> data = const {}]) =>
        CounterpartyMessage(
            messageType: type, messageTypeId: 0, messageData: data);

    test("anything that can take assets from the address is high impact", () {
      for (final type in [
        "sweep",
        "send",
        "enhanced_send",
        "mpma_send",
        "destroy",
        "dividend",
        "order",
        "dispenser",
        "attach",
        "detach",
        "utxo",
        "fairmint",
        "bet",
        "pooldeposit",
        "poolwithdraw",
        // a type added to the protocol later
        "brand_new_message",
      ]) {
        final c = classifyRevealMessage(msg(type), hasDestination: false);
        expect(c.risk, RevealRisk.high, reason: type);
        expect(c.reason, isNotEmpty, reason: type);
      }
      // broadcast.parse settles the feed's bet matches from 0 up and cancels
      // its bets at -2 and -3
      for (final value in [1.5, 0, 0.0, -2, -3.0]) {
        expect(
            classifyRevealMessage(msg("broadcast", {"value": value}),
                    hasDestination: false)
                .risk,
            RevealRisk.high,
            reason: "$value");
      }
      expect(
          classifyRevealMessage(msg("issuance", {"reset": true}),
                  hasDestination: false)
              .risk,
          RevealRisk.high);
      expect(
          classifyRevealMessage(msg("issuance", {"reset": false}),
                  hasDestination: true)
              .risk,
          RevealRisk.high);
    });

    test("ordinary types", () {
      for (final type in ["fairminter", "cancel", "btcpay", "dispense"]) {
        expect(classifyRevealMessage(msg(type), hasDestination: false).risk,
            RevealRisk.normal,
            reason: type);
      }
      // no value, or a negative one that leaves the bets alone
      for (final value in [null, -1, -1.5]) {
        expect(
            classifyRevealMessage(
                    msg("broadcast", {"value": value, "text": "hi"}),
                    hasDestination: false)
                .risk,
            RevealRisk.normal,
            reason: "$value");
      }
      expect(
          classifyRevealMessage(msg("issuance", {"reset": false}),
                  hasDestination: false)
              .risk,
          RevealRisk.normal);
    });

    test("unrecognized", () {
      expect(classifyRevealMessage(null, hasDestination: false).risk,
          RevealRisk.unrecognized);
      expect(classifyRevealMessage(msg("unknown"), hasDestination: false).risk,
          RevealRisk.unrecognized);
      expect(
          classifyRevealMessage(msg("issuance", {"error": "bad"}),
                  hasDestination: false)
              .risk,
          RevealRisk.unrecognized);
    });
  });

  test("describes an omitted content on its own line without a field for it",
      () {
    const reveal = CounterpartyRevealInfo(
      sourceAddress: "a",
      leafHashHex: "",
      messageHex: "",
      message: CounterpartyMessage(
          messageType: "sweep",
          messageTypeId: 4,
          messageData: {"destination": "b", "memo": ""}),
      decodeError: null,
      omittedContent: OmittedContent(length: 5000, mimeType: ""),
      destinations: [],
      risk: RevealRisk.high,
      riskReason: "",
    );
    final entries = Map.fromEntries(reveal.entries);
    expect(entries["memo"], "");
    expect(entries["content"], "5000 bytes, too long to decode: not shown");
  });
}
