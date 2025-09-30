import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import "./usecase.dart";
export "./usecase.dart";

import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';

import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/event.dart';

class BalancesSetMempoolData {
  final List<VerboseAttachToUtxoEvent> attaches;
  final List<VerboseCreditEvent> credits;
  final List<VerboseDebitEvent> debits;

  const BalancesSetMempoolData({
    required this.attaches,
    required this.credits,
    required this.debits,
  });
}

class BalancesSet {
  final List<BalanceV2> confirmed;
  final BalancesSetMempoolData mempoolData;

  const BalancesSet({
    required this.confirmed,
    required this.mempoolData,
  });
}

class GetAllBalancesUseCaseParams {
  final HttpConfig httpConfig;
  final List<String> addresses;
  const GetAllBalancesUseCaseParams({
    required this.httpConfig,
    required this.addresses,
  });
}

class GetAllBalancesUseCase
    implements UseCaseTE<BalancesSet, GetAllBalancesUseCaseParams, String> {
  final BalanceRepository _balanceRepository;
  final EventsRepository _eventsRepository;

  GetAllBalancesUseCase(
      {BalanceRepository? balanceRepository,
      EventsRepository? eventsRepository})
      : _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>();

  @override
  TaskEither<String, BalancesSet> call(GetAllBalancesUseCaseParams params) {
    return TaskEither<String, BalancesSet>.Do(($) async {
      final confirmedTask = _balanceRepository
          .getBalancesForAddressesT(
            httpConfig: params.httpConfig,
            addresses: params.addresses,
            onError: (_, __) =>
                "Failed to read confirmed balances for ${params.addresses}",
          )
          .map<List<BalanceV2>>((balances) => balances
              .map<List<BalanceV2>>(
                  (MultiAddressBalance balance) => balance.entries
                      .map<BalanceV2>((entry) => entry.utxo != null
                          ? UtxoBalance(
                              confirmed: true,
                              asset: balance.asset,
                              assetLongname: balance.assetInfo.assetLongname,
                              utxoId: UtxoID.fromString(entry.utxoAddress!),
                              address: entry.utxoAddress!,
                              quantity: AssetQuantity(
                                quantity: BigInt.from(entry.quantity),
                                divisible: balance.assetInfo.divisible,
                              ),
                            )
                          : AddressBalance(
                              confirmed: true,
                              asset: balance.asset,
                              assetLongname: balance.assetInfo.assetLongname,
                              address: entry.address!,
                              quantity: AssetQuantity(
                                quantity: BigInt.from(entry.quantity),
                                divisible: balance.assetInfo.divisible,
                              )))
                      .toList())
              .expand((el) => el)
              .toList());

      final mempoolTask =
          _eventsRepository.getAllMempoolVerboseEventsForAddressesT(
        params.httpConfig,
        params.addresses,
        ["ATTACH_TO_UTXO", "CREDIT", "DEBIT"],
        (_, __) => "Failed to get mempool events ",
      );

      final result =
          await $(TaskEither.sequenceList([confirmedTask, mempoolTask]));

      final confirmed = result[0] as List<BalanceV2>;
      final mempoolEvents = result[1] as List<VerboseEvent>;

      return BalancesSet(
          confirmed: confirmed,
          mempoolData: BalancesSetMempoolData(
            attaches:
                mempoolEvents.whereType<VerboseAttachToUtxoEvent>().toList(),
            credits: mempoolEvents.whereType<VerboseCreditEvent>().toList(),
            debits: mempoolEvents.whereType<VerboseDebitEvent>().toList(),
          ));
    });
  }
}
