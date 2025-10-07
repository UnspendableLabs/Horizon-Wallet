import 'package:decimal/decimal.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo_attach.dart';

import "./usecase.dart";
export "./usecase.dart";

import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/utxo_attach_repository.dart';

import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/event.dart';

class GetUTXOBalancesUseCaseParams {
  final HttpConfig httpConfig;
  final UtxoID utxoID;
  final List<String> addresses;
  const GetUTXOBalancesUseCaseParams({
    required this.httpConfig,
    required this.utxoID,
    required this.addresses,
  });
}

class GetUTXOBalancesUseCase
    implements
        UseCaseTE<List<UtxoBalance>, GetUTXOBalancesUseCaseParams, String> {
  final BalanceRepository _balanceRepository;
  final EventsRepository _eventsRepository;
  final UtxoAttachRepository _utxoAttachRepository;

  GetUTXOBalancesUseCase(
      {BalanceRepository? balanceRepository,
      EventsRepository? eventsRepository,
      UtxoAttachRepository? utxoAttachRepository})
      : _eventsRepository = eventsRepository ?? GetIt.I<EventsRepository>(),
        _balanceRepository = balanceRepository ?? GetIt.I<BalanceRepository>(),
        _utxoAttachRepository = GetIt.I<UtxoAttachRepository>();

  @override
  TaskEither<String, List<UtxoBalance>> call(
      GetUTXOBalancesUseCaseParams params) {
    final onChainTask = TaskEither.sequenceList<String, List<UtxoBalance>>([
      _balanceRepository
          .getBalancesForUTXOT(
            httpConfig: params.httpConfig,
            utxo: params.utxoID.toString(),
            onError: (_, __) =>
                "Failed to get balances for UTXO: ${params.utxoID.toString()}",
          )
          .map((balances) => balances
              .map((Balance balance) => UtxoBalance(
                    confirmed: true,
                    asset: balance.asset,
                    assetLongname: balance.assetInfo.assetLongname,
                    utxoId: params.utxoID,
                    address: balance.utxoAddress!,
                    quantity: AssetQuantity(
                      quantity: BigInt.from(balance.quantity),
                      divisible: balance.assetInfo.divisible,
                    ),
                  ))
              .toList()),
      _eventsRepository
          .getAllMempoolVerboseEventsForAddressesT(
            params.httpConfig,
            params.addresses,
            ["ATTACH_TO_UTXO"],
            (_, __) =>
                "Failed to get mempool events for UTXO: ${params.utxoID.toString()}",
          )
          .map(
            (List<VerboseEvent> events) => events
                .whereType<VerboseAttachToUtxoEvent>()
                .where((event) =>
                    event.params.destination == params.utxoID.toString())
                .map(
                  (VerboseAttachToUtxoEvent event) => UtxoBalance(
                      confirmed: false,
                      asset: event.params.asset,
                      assetLongname: event.params.assetInfo.assetLongname,
                      utxoId: params.utxoID,
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
    ]).map((lists) => lists.expand((e) => e).toList());

    return TaskEither<String, List<UtxoBalance>>.Do(($) async {
      final List<UtxoBalance> onChainBalances = await $(onChainTask);

      if (onChainBalances.isNotEmpty) {
        return onChainBalances;
      }

      final UtxoAttach? utxoAttach =
          await $(_utxoAttachRepository.getByIDTE(params.utxoID));

      if (utxoAttach != null) {
        return [
          UtxoBalance(
            confirmed: false,
            asset: utxoAttach.asset,
            assetLongname: "", // local cache does not have asset longname
            utxoId: params.utxoID,
            address: utxoAttach.address,
            quantity: utxoAttach.quantity,
          )
        ];
      }

      return [];
    });
  }
}
