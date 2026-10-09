import "dart:typed_data";

import "package:convert/convert.dart";
import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:collection/collection.dart";
import "package:decimal/decimal.dart";
import "package:horizon/common/tapscript.dart";
import "package:horizon/domain/entities/bitcoin_decoded_tx.dart" as dbtc;
import "package:horizon/domain/entities/counterparty_reveal.dart";
import "package:horizon/domain/repositories/transaction_repository.dart";
import "package:horizon/data/sources/repositories/network_error_helpers.dart";
import "package:horizon/domain/entities/http_config.dart";
import "package:horizon/domain/entities/address_v2.dart";
import "package:horizon/domain/entities/failure.dart";
import "package:horizon/domain/entities/utxo.dart";
import "package:horizon/domain/entities/utxo_attach.dart";
import "package:horizon/domain/entities/balance.dart";
import "package:horizon/domain/entities/balance_v2.dart";
import "package:horizon/domain/entities/asset_quantity.dart";
import "package:horizon/domain/entities/bitcoin_tx.dart";
import "package:horizon/domain/entities/event.dart";
import "package:horizon/domain/services/transaction_service.dart";
import "package:horizon/domain/services/bitcoind_service.dart";
import "package:horizon/domain/services/error_service.dart";
import "package:horizon/domain/repositories/bitcoin_repository.dart";
import "package:horizon/domain/repositories/balance_repository.dart";
import "package:horizon/domain/repositories/events_repository.dart";
import "package:horizon/domain/repositories/utxo_attach_repository.dart";
import "package:horizon/common/format.dart";
import "package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart";
import "package:horizon/extensions.dart";

import "./usecase.dart";
export "./usecase.dart";

const dummyTxID =
    "0000000000000000000000000000000000000000000000000000000000000000";

class AugmentedPsbtData {
  final List<AssetDebit> debits;
  final List<AssetCredit> credits;
  final List<AugmentedInput> augmentedInputs;
  final List<AugmentedOutput> augmentedOutputs;

  /// The Counterparty message this PSBT reveals, when the wallet is asked to
  /// sign a canonical taproot envelope with one of its keys; null otherwise.
  final CounterpartyRevealInfo? counterpartyReveal;

  /// Why the wallet will refuse to sign a tapscript input of this PSBT, when
  /// it will.
  final String? tapscriptRefusal;

  const AugmentedPsbtData({
    required this.debits,
    required this.credits,
    required this.augmentedInputs,
    required this.augmentedOutputs,
    this.counterpartyReveal,
    this.tapscriptRefusal,
  });
}

class GetAugmentedPsbtDataParams {
  final HttpConfig httpConfig;
  final String unsignedPsbt;
  final List<AddressV2> addresses;
  final Map<String, List<int>> signInputs;

  const GetAugmentedPsbtDataParams({
    required this.httpConfig,
    required this.unsignedPsbt,
    required this.addresses,
    required this.signInputs,
  });
}

class GetAugmentedPsbtDataUseCase
    implements
        UseCaseTE<AugmentedPsbtData, GetAugmentedPsbtDataParams, String> {
  final TransactionService _transactionService;
  final BitcoindService _bitcoindService;
  final BitcoinRepository _bitcoinRepository;
  final BalanceRepository _balanceRepository;
  final EventsRepository _eventsRepository;
  final UtxoAttachRepository _utxoAttachRepository;
  final ErrorService _errorService;
  final TransactionRepository _transactionRepository;

  GetAugmentedPsbtDataUseCase({
    TransactionService? transactionService,
    BitcoindService? bitcoindService,
    BitcoinRepository? bitcoinRepository,
    BalanceRepository? balanceRepository,
    EventsRepository? eventsRepository,
    UtxoAttachRepository? utxoAttachRepository,
    ErrorService? errorService,
    TransactionRepository? transactionRepository,
  })  : _transactionRepository =
            transactionRepository ?? GetIt.I<TransactionRepository>(),
        _transactionService =
            transactionService ?? GetIt.I<TransactionService>(),
        _bitcoindService = bitcoindService ?? GetIt.I<BitcoindService>(),
        _bitcoinRepository = bitcoinRepository ?? GetIt.I<BitcoinRepository>(),
        _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>(),
        _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _utxoAttachRepository =
            utxoAttachRepository ?? GetIt.I<UtxoAttachRepository>(),
        _errorService = errorService ?? GetIt.I<ErrorService>();

  @override
  TaskEither<String, AugmentedPsbtData> call(GetAugmentedPsbtDataParams params,
      {int maxRetries = 1}) {
    return handleNetworkCall(
      () async {
        // decode the psbt transaction
        final transactionHex = _transactionService
            .psbtToUnsignedTransactionHex(params.unsignedPsbt);

        final decoded = await _bitcoindService.decoderawtransaction(
          raw: transactionHex,
          httpConfig: params.httpConfig,
        );

        PsbtDescription? description;
        try {
          description = _transactionService.describePsbt(
              params.unsignedPsbt, params.httpConfig);
        } catch (_) {
          description = null;
        }

        Either<Failure, List<Option<AugmentedInput>>> inputs =
            await TaskEither.traverseListWithIndex(decoded.vin, (vin, index) {
          return TaskEither<Failure, Option<AugmentedInput>>.Do(($) async {
            if (vin.txid == dummyTxID && vin.vout == 0) {
              // this is a dummy input, skip it
              return $(TaskEither.right(const Option.none()));
            }

            // TODO: don't go chasin' waterfalls.
            final getPrevoutTask = TaskEither.tryCatch(
              () => _bitcoinRepository.getTransaction(
                txid: vin.txid,
                httpConfig: params.httpConfig,
              ),
              (error, stackTrace) => error.toString(),
            )
                .mapLeft((s) => UnexpectedFailure(message: s))
                .map((transaction) => (
                      confirmed: transaction.status.confirmed,
                      prevout: transaction.vout[vin.vout],
                    ))
                // The explorer does not know a transaction that has not been
                // broadcast yet: the reveal of a Counterparty taproot
                // envelope spends the commit output before the commit is
                // sent. The PSBT carries that prevout itself.
                .orElse((failure) => TaskEither.fromOption(
                    _prevoutFromPsbt(description, index), () => failure));

            final utxoID = UtxoID.fromString("${vin.txid}:${vin.vout}");
            final utxoBalancesTask = _getUtxoBalances(
              utxoID: utxoID,
              addresses: params.addresses.map((a) => a.address).toList(),
              httpConfig: params.httpConfig,
            );

            final results = await $(TaskEither.sequenceList([
              getPrevoutTask,
              utxoBalancesTask,
            ]));

            final (:confirmed, :prevout) =
                results[0] as ({bool confirmed, Vout prevout});
            final balances = results[1] as List<UtxoBalance>;

            final address = prevout.scriptpubkeyAddress;

            // The dApp names the wallet address whose key signs each input.
            // For a taproot script path spend (a reveal) the prevout address
            // is the commit address, not that wallet address.
            final signatureRequired = params.signInputs.values
                .any((indexes) => indexes.contains(index));

            return $(TaskEither.right(Option.of(AugmentedInput(
                confirmed: confirmed,
                address: address,
                vin: vin,
                prevOut: prevout,
                balances: balances,
                signatureRequired: signatureRequired))));
          });
        }).run();

        List<Option<AugmentedInput>> augmentedInputs_ =
            inputs.getOrElse((error) {
          throw error;
        });

        List<AugmentedInput> augmentedInputs = augmentedInputs_
            .where((input) => input.isSome())
            .map((input) => input.getOrElse(() => throw Exception("Invariant")))
            .toList();

        // append asset balances to output that has same value as input
        final augmentedOutputs = decoded.vout
            .map((o) => AugmentedOutput(
                vout: o,
                balances: augmentedInputs.firstWhereOrNull((input) {
                      return satoshisToBtc(input.prevOut.value).toDouble() ==
                          o.value;
                    })?.balances ??
                    []))
            .toList();

        final addressSet =
            params.addresses.map((address) => address.address).toSet();

        final debits = augmentedInputs
            .map((i) => i.getDebits(addressSet))
            .flatten
            .toList();

        final credits = augmentedOutputs
            .map((o) => o.getCredits(addressSet))
            .flatten
            .toList();

        Map<String, AssetQuantity> map = {};

        for (final debit in debits) {
          map.putIfAbsent(debit.asset,
              () => AssetQuantity.empty(divisible: debit.quantity.divisible));
          map[debit.asset] = map[debit.asset]! - debit.quantity;
        }

        for (final credit in credits) {
          map.putIfAbsent(credit.asset,
              () => AssetQuantity.empty(divisible: credit.quantity.divisible));
          map[credit.asset] = map[credit.asset]! + credit.quantity;
        }

        final netDebits = map.entries
            .filter((entry) => entry.value.quantity < BigInt.zero)
            .map((e) => AssetDebit(
                  asset: e.key,
                  quantity: e.value.map((value) => value.abs()),
                ));

        final netCredits = map.entries
            .filter((entry) => entry.value.quantity > BigInt.zero)
            .map((e) => AssetCredit(
                  asset: e.key,
                  quantity: e.value.map((value) => value.abs()),
                ));

        final tapscript =
            await _describeTapscriptInputs(params, decoded, description);

        return AugmentedPsbtData(
          debits: netDebits.toList(),
          credits: netCredits.toList(),
          augmentedInputs: augmentedInputs,
          augmentedOutputs: augmentedOutputs,
          counterpartyReveal: tapscript.reveal,
          tapscriptRefusal: tapscript.refusal,
        );
      },
      maxRetries: maxRetries,
    ).tapError((error) {
      _errorService.captureException(
        error,
        message: "Failed to get augmented PSBT data",
        context: {
          "message": error.message,
          "endpoint": error.endpoint,
          "fullUrl": error.fullUrl,
          "statusCode": error.statusCode,
          "debugMessage": error.toDebugString(),
        },
      );
    }).mapLeft((error) => error.message);
  }

  /// What signing the tapscript inputs of the PSBT will do: the Counterparty
  /// message it reveals, or why the wallet will refuse to sign.
  ///
  /// With `require_reveal_source_signature` the wallet's signature is the
  /// consent to the message of a reveal, so it is shown before signing: a
  /// dApp can hand the wallet a well-formed reveal whose envelope holds a
  /// sweep, an order, a dispenser... Each tapscript input is planned exactly
  /// as the signer will plan it ([PsbtDescription.planTapLeafSigningForInput])
  /// with the key of the address the dApp designated to sign it, so the
  /// message shown is the one of the leaf that gets signed. The signer refuses
  /// a reveal whose leaf was not shown.
  Future<({CounterpartyRevealInfo? reveal, String? refusal})>
      _describeTapscriptInputs(GetAugmentedPsbtDataParams params,
          dbtc.DecodedTx decoded, PsbtDescription? description) async {
    if (description == null) return (reveal: null, refusal: null);

    // the signing address of each input, resolved like the sign step does
    final signers = <int, String>{
      for (final entry in params.signInputs.entries)
        for (final index in entry.value) index: entry.key,
    };

    for (var index = 0; index < description.inputs.length; index++) {
      if (description.inputs[index].tapLeafScripts.isEmpty) continue;
      final signerAddress = signers[index];
      if (signerAddress == null) continue;
      final address =
          params.addresses.firstWhereOrNull((a) => a.address == signerAddress);
      final xOnly = address == null ? null : _xOnlyKey(address.publicKey);
      if (xOnly == null) continue;

      final TapLeafSigningPlan? plan;
      try {
        plan = description.planTapLeafSigningForInput(index,
            xOnly: xOnly, signerAddress: signerAddress);
      } on TapscriptException catch (e) {
        return (reveal: null, refusal: "Input $index: ${e.message}");
      }
      if (plan == null || !plan.isCounterpartyReveal) continue;

      // a reveal has a single input
      return (
        reveal: await _describeReveal(params, decoded, plan, signerAddress),
        refusal: null,
      );
    }
    return (reveal: null, refusal: null);
  }

  Future<CounterpartyRevealInfo> _describeReveal(
    GetAugmentedPsbtDataParams params,
    dbtc.DecodedTx decoded,
    TapLeafSigningPlan plan,
    String sourceAddress,
  ) async {
    // The parser (counterparty-rs indexer, parse_vout) takes as destinations
    // the address outputs placed BEFORE the data output; after the data, the
    // first address output is change and the rest is ignored. The composer
    // always puts the CNTRPRTY output first, so a node-built reveal never has
    // a destination: one can only come from a hand-built PSBT. For an
    // issuance that destination becomes the asset's issuer (an ownership
    // transfer); a classic send pays it.
    final destinations = [
      for (final output in decoded.vout.take(plan.markerOutputIndex!))
        output.scriptPubKey.address ?? output.scriptPubKey.hex,
    ];

    var messageHex = "";
    CounterpartyMessage? message;
    String? decodeError;
    try {
      final bytes = counterpartyMessageFromEnvelope(plan.script);
      if (bytes == null) {
        throw const TapscriptException("not a canonical envelope");
      }
      messageHex = hex.encode(bytes);
      message = await _transactionRepository.unpackMessage(
          datahex: messageHex, httpConfig: params.httpConfig);
    } on TapscriptException catch (e) {
      decodeError = e.message;
    } catch (e) {
      decodeError = e.toString();
    }

    final classification =
        classifyRevealMessage(message, hasDestination: destinations.isNotEmpty);

    return CounterpartyRevealInfo(
      sourceAddress: sourceAddress,
      leafHashHex: hex.encode(plan.leafHash),
      messageHex: messageHex,
      message: message,
      decodeError: decodeError,
      destinations: destinations,
      risk: classification.risk,
      riskReason: classification.reason,
    );
  }

  /// The x-only key of an address' public key: x-only already for a P2TR
  /// address, compressed otherwise. Null when it is neither.
  static Uint8List? _xOnlyKey(String publicKeyHex) {
    final Uint8List pub;
    try {
      pub = Uint8List.fromList(hex.decode(publicKeyHex));
    } catch (_) {
      return null;
    }
    return switch (pub.length) {
      32 => pub,
      33 => Uint8List.sublistView(pub, 1),
      _ => null,
    };
  }

  /// The prevout the PSBT embeds for input `index` (`witnessUtxo`), when the
  /// transaction it spends cannot be fetched.
  static Option<({bool confirmed, Vout prevout})> _prevoutFromPsbt(
      PsbtDescription? description, int index) {
    if (description == null || index >= description.inputs.length) {
      return const Option.none();
    }
    final input = description.inputs[index];
    final script = input.witnessUtxoScript;
    final value = input.witnessUtxoValue;
    if (script == null || value == null) return const Option.none();
    return Option.of((
      confirmed: false,
      prevout: Vout(
        scriptpubkey: hex.encode(script),
        scriptpubkeyAsm: "",
        scriptpubkeyType: _scriptType(script),
        scriptpubkeyAddress: input.witnessUtxoAddress,
        value: value,
      ),
    ));
  }

  /// The type name the explorer gives a scriptPubKey.
  static String _scriptType(Uint8List script) {
    if (isP2trScript(script)) return "v1_p2tr";
    if (isP2wpkhScript(script)) return "v0_p2wpkh";
    if (isP2wshScript(script)) return "v0_p2wsh";
    if (isP2shScript(script)) return "p2sh";
    if (isP2pkhScript(script)) return "p2pkh";
    return "unknown";
  }

  TaskEither<Failure, List<UtxoBalance>> _getUtxoBalances({
    required UtxoID utxoID,
    required List<String> addresses,
    required HttpConfig httpConfig,
  }) {
    final onChainTask = TaskEither.sequenceList<Failure, List<UtxoBalance>>([
      _balanceRepository
          .getBalancesForUTXOT(
            httpConfig: httpConfig,
            utxo: utxoID.toString(),
            onError: (error, stackTrace) =>
                UnexpectedFailure(message: error.toString()),
          )
          .map((balances) => balances
              .map((Balance balance) => UtxoBalance(
                    confirmed: true,
                    asset: balance.asset,
                    assetLongname: balance.assetInfo.assetLongname,
                    utxoId: utxoID,
                    address: balance.utxoAddress!,
                    quantity: AssetQuantity(
                      quantity: BigInt.from(balance.quantity),
                      divisible: balance.assetInfo.divisible,
                    ),
                  ))
              .toList()),
      _eventsRepository
          .getAllMempoolVerboseEventsForAddressesT(
            httpConfig,
            addresses,
            ["ATTACH_TO_UTXO"],
            (error, stackTrace) => error.toString(),
          )
          .map(
            (List<VerboseEvent> events) => events
                .whereType<VerboseAttachToUtxoEvent>()
                .where((event) => event.params.destination == utxoID.toString())
                .map(
                  (VerboseAttachToUtxoEvent event) => UtxoBalance(
                      confirmed: false,
                      asset: event.params.asset,
                      assetLongname: event.params.assetInfo.assetLongname,
                      utxoId: utxoID,
                      address: event.params.destination,
                      quantity: AssetQuantity.fromNormalizedString(
                        input: event.params.quantityNormalized,
                        divisible:
                            Decimal.parse(event.params.quantityNormalized) !=
                                Decimal.fromInt(event.params.quantity),
                      )),
                )
                .toList(),
          )
          .mapLeft((s) => UnexpectedFailure(message: s))
    ]).map((lists) => lists.expand((e) => e).toList());

    return TaskEither<Failure, List<UtxoBalance>>.Do(($) async {
      final List<UtxoBalance> onChainBalances = await $(onChainTask);

      if (onChainBalances.isNotEmpty) {
        return onChainBalances;
      }

      final UtxoAttach? utxoAttach = await $(_utxoAttachRepository
          .getByIDTE(utxoID)
          .mapLeft((s) => UnexpectedFailure(message: s)));

      if (utxoAttach != null) {
        return [
          UtxoBalance(
            confirmed: false,
            asset: utxoAttach.asset,
            assetLongname: "", // local cache does not have asset longname
            utxoId: utxoID,
            address: utxoAttach.address,
            quantity: utxoAttach.quantity,
          )
        ];
      }

      return [];
    });
  }
}
