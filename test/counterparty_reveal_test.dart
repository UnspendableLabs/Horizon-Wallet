import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

void main() {
  final reveals = json.decode(
          File("test/fixtures/taproot_reveal_fixtures.json").readAsStringSync())
      as Map<String, dynamic>;
  final messages = json.decode(
          File("test/fixtures/counterparty_reveal_messages.json")
              .readAsStringSync())
      as Map<String, dynamic>;
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
            any(), any(), any()))
        .thenAnswer((_) async => <VerboseEvent>[]);
    when(() => utxoAttachRepository.getByID(any()))
        .thenAnswer((_) async => null as UtxoAttach?);
    when(() => errorService.captureException(any(),
        stackTrace: any(named: "stackTrace"),
        message: any(named: "message"),
        context: any(named: "context"))).thenReturn(null);
  });

  void givenRevealPsbt(String vectorName,
      {List<dbtc.Vout>? extraOutputs}) {
    when(() => bitcoindService.decoderawtransaction(
            raw: any(named: "raw"), httpConfig: any(named: "httpConfig")))
        .thenAnswer((_) async => decoded([
              vout(0, opReturnCntrprty),
              ...?extraOutputs,
            ]));
    when(() => transactionService.getPsbtInputPrevouts(any(), any()))
        .thenReturn([
      PsbtInputPrevout(
        scriptPubKeyHex: source["reveal_lock_scripts"][0] as String,
        value: source["reveal_inputs_values"][0] as int,
        address: source["commit_address"] as String,
        isTapscriptSpend: true,
        tapLeafScriptHex: vector(vectorName)["envelope_script"] as String,
      )
    ]);
  }

  Future<AugmentedPsbtData> run({Map<String, List<int>>? signInputs}) async {
    final result = await useCase
        .call(GetAugmentedPsbtDataParams(
          httpConfig: HttpConfig.mainnet(),
          unsignedPsbt: "70736274ff",
          addresses: addresses,
          signInputs: signInputs ?? {sourceAddress: [0]},
        ))
        .run();
    return result.fold((l) => throw Exception("use case failed: $l"), (r) => r);
  }

  group("GetAugmentedPsbtDataUseCase on a Counterparty reveal", () {
    test("decodes a sweep with the node and flags it as high impact", () async {
      givenRevealPsbt("sweep_raw");
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => const CounterpartyMessage(
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

      // the bytes sent to the node are the message rebuilt from the envelope
      verify(() => transactionRepository.unpackMessage(
          datahex: vector("sweep_raw")["message"] as String,
          httpConfig: any(named: "httpConfig"))).called(1);
      expect(reveal.messageHex, vector("sweep_raw")["message"]);
      expect(reveal.message!.messageType, "sweep");
      expect(reveal.sourceAddress, sourceAddress);
      expect(reveal.sourceKeyMatches, isTrue);
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
        when(() => transactionRepository.unpackMessage(
                datahex: any(named: "datahex"),
                httpConfig: any(named: "httpConfig")))
            .thenAnswer((_) async => const CounterpartyMessage(
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
            datahex: vector(name)["message"] as String,
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

    test("flags an issuance with a destination before the data output (ownership transfer)",
        () async {
      // an address output placed BEFORE the OP_RETURN CNTRPRTY is a
      // Counterparty destination; the parser makes it the asset's issuer
      when(() => bitcoindService.decoderawtransaction(
              raw: any(named: "raw"), httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => decoded([
                vout(0, "0014a3df8a5a83d4e2827b59b43f5ce6ce5d2e52093f",
                    address: otherAddress, value: 0.00000546),
                vout(1, opReturnCntrprty),
              ]));
      when(() => transactionService.getPsbtInputPrevouts(any(), any()))
          .thenReturn([
        PsbtInputPrevout(
          scriptPubKeyHex: source["reveal_lock_scripts"][0] as String,
          value: source["reveal_inputs_values"][0] as int,
          address: source["commit_address"] as String,
          isTapscriptSpend: true,
          tapLeafScriptHex: vector("issuance_raw")["envelope_script"] as String,
        )
      ]);
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => const CounterpartyMessage(
                messageType: "issuance",
                messageTypeId: 22,
                messageData: {"asset": "A95428956661682189", "reset": false},
              ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.risk, RevealRisk.high);
      expect(reveal.riskReason, contains("owner"));
    });

    test("an address output after the data output is change, not a destination",
        () async {
      givenRevealPsbt("issuance_raw", extraOutputs: [
        vout(1, "0014a3df8a5a83d4e2827b59b43f5ce6ce5d2e52093f",
            address: otherAddress, value: 0.00000546),
      ]);
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => const CounterpartyMessage(
                messageType: "issuance",
                messageTypeId: 22,
                messageData: {"asset": "A95428956661682189", "reset": false},
              ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.risk, RevealRisk.normal);
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
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => const CounterpartyMessage(
                messageType: "unknown",
                messageTypeId: 255,
                messageData: {"error": "Unknown message type"},
              ));

      final reveal = (await run()).counterpartyReveal!;
      expect(reveal.risk, RevealRisk.unrecognized);
      expect(reveal.entries, isEmpty);
    });

    test("reports an envelope not closed by the designated address' key",
        () async {
      givenRevealPsbt("sweep_raw");
      when(() => transactionRepository.unpackMessage(
              datahex: any(named: "datahex"),
              httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => const CounterpartyMessage(
                messageType: "sweep",
                messageTypeId: 4,
                messageData: {"destination": "x", "flags": 1},
              ));

      final reveal = (await run(signInputs: {
        otherAddress: [0]
      }))
          .counterpartyReveal!;
      expect(reveal.sourceAddress, otherAddress);
      expect(reveal.sourceKeyMatches, isFalse);
    });

    test("describes nothing for a PSBT that is not a reveal", () async {
      when(() => bitcoindService.decoderawtransaction(
              raw: any(named: "raw"), httpConfig: any(named: "httpConfig")))
          .thenAnswer((_) async => decoded([
                vout(0, "0014a3df8a5a83d4e2827b59b43f5ce6ce5d2e52093f",
                    address: otherAddress, value: 0.001),
              ]));
      when(() => transactionService.getPsbtInputPrevouts(any(), any()))
          .thenReturn([
        PsbtInputPrevout(
          scriptPubKeyHex: source["source_script_pubkey"] as String,
          value: 200000,
          address: sourceAddress,
          isTapscriptSpend: false,
        )
      ]);

      final data = await run();
      expect(data.counterpartyReveal, isNull);
      verifyNever(() => transactionRepository.unpackMessage(
          datahex: any(named: "datahex"),
          httpConfig: any(named: "httpConfig")));
    });
  });

  group("classifyRevealMessage", () {
    CounterpartyMessage msg(String type, [Map<String, dynamic> data = const {}]) =>
        CounterpartyMessage(messageType: type, messageTypeId: 0, messageData: data);

    test("high impact types", () {
      for (final type in ["sweep", "order", "dispenser", "attach", "detach"]) {
        expect(classifyRevealMessage(msg(type), hasDestination: false).risk,
            RevealRisk.high,
            reason: type);
      }
      expect(
          classifyRevealMessage(msg("broadcast", {"value": 1.5}),
                  hasDestination: false)
              .risk,
          RevealRisk.high);
      expect(
          classifyRevealMessage(msg("issuance", {"reset": true}),
                  hasDestination: false)
              .risk,
          RevealRisk.high);
    });

    test("ordinary types", () {
      for (final type in ["enhanced_send", "fairmint", "fairminter", "dividend", "cancel", "destroy"]) {
        expect(classifyRevealMessage(msg(type), hasDestination: false).risk,
            RevealRisk.normal,
            reason: type);
      }
      expect(
          classifyRevealMessage(msg("broadcast", {"value": 0, "text": "hi"}),
                  hasDestination: false)
              .risk,
          RevealRisk.normal);
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
    });
  });
}
