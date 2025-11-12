import "package:fpdart/fpdart.dart";
import "package:get_it/get_it.dart";
import "package:collection/collection.dart";
import "package:decimal/decimal.dart";
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

  const AugmentedPsbtData({
    required this.debits,
    required this.credits,
    required this.augmentedInputs,
    required this.augmentedOutputs,
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

  GetAugmentedPsbtDataUseCase({
    TransactionService? transactionService,
    BitcoindService? bitcoindService,
    BitcoinRepository? bitcoinRepository,
    BalanceRepository? balanceRepository,
    EventsRepository? eventsRepository,
    UtxoAttachRepository? utxoAttachRepository,
    ErrorService? errorService,
  })  : _transactionService =
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

        Either<Failure, List<Option<AugmentedInput>>> inputs =
            await TaskEither.traverseListWithIndex(decoded.vin, (vin, index) {
          return TaskEither<Failure, Option<AugmentedInput>>.Do(($) async {
            if (vin.txid == dummyTxID && vin.vout == 0) {
              // this is a dummy input, skip it
              return $(TaskEither.right(const Option.none()));
            }

            // TODO: don't go chasin' waterfalls.
            final getTransactionTask = TaskEither.tryCatch(
              () => _bitcoinRepository.getTransaction(
                txid: vin.txid,
                httpConfig: params.httpConfig,
              ),
              (error, stackTrace) => error.toString(),
            ).mapLeft((s) => UnexpectedFailure(message: s));

            final utxoID = UtxoID.fromString("${vin.txid}:${vin.vout}");
            final utxoBalancesTask = _getUtxoBalances(
              utxoID: utxoID,
              addresses: params.addresses.map((a) => a.address).toList(),
              httpConfig: params.httpConfig,
            );

            final results = await $(TaskEither.sequenceList([
              getTransactionTask,
              utxoBalancesTask,
            ]));

            final transaction = results[0] as BitcoinTx;
            final balances = results[1] as List<UtxoBalance>;

            final prevout = transaction.vout[vin.vout];
            final address = prevout.scriptpubkeyAddress;

            final signatureRequired =
                params.signInputs[address]?.contains(index) ?? false;

            return $(TaskEither.right(Option.of(AugmentedInput(
                confirmed: transaction.status.confirmed,
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

        return AugmentedPsbtData(
          debits: netDebits.toList(),
          credits: netCredits.toList(),
          augmentedInputs: augmentedInputs,
          augmentedOutputs: augmentedOutputs,
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
