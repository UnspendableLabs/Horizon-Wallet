import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/services/transaction_service.dart';

class GetMaxSendQuantity {
  final String source;
  // final String destination;
  final String asset;
  final int feeRate;
  final BalanceRepository balanceRepository;
  final ComposeRepository composeRepository;
  final TransactionService transactionService;

  const GetMaxSendQuantity(
      {required this.source,
      // required this.destination,
      required this.asset,
      required this.feeRate,
      required this.balanceRepository,
      required this.composeRepository,
      required this.transactionService});

  Future<int> call() async {
    List<Balance> balances =
        await balanceRepository.getBalancesForAddress(source);

    Balance sendAsset =
        balances.firstWhere((element) => element.asset == asset);

    if (sendAsset.asset != "BTC") {
      return sendAsset.quantity;
    }

    // we take quantity to max, less 1000 sat in the
    // case of btc, for computing the transaction size
    // tom make sure we accont for fee / change

    final quantity = switch (sendAsset.asset) {
      "BTC" => sendAsset.quantity - 1000,
      _ => sendAsset.quantity
    };
    //
    // final send = await composeRepository.composeSendVerbose(
    //     source, destination, asset, quantity, true, 1);

    final send = await composeRepository.composeSendVerbose(
        source, source, asset, quantity, true, 1);

    final virtualSize = transactionService.getVirtualSize(send.rawtransaction);

    final totalCost = virtualSize * feeRate;

    final max = sendAsset.quantity - totalCost;

    if (max <= 0) {
      throw Exception("Inadequate funds: try adjusting fee");
    }

    return max;
  }
}
