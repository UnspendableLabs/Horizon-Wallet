import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/balance.dart' as b;
import 'package:horizon/domain/entities/asset_info.dart' as ai;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class BalanceRepositoryImpl implements BalanceRepository {
  final V2Api api;
  final UtxoRepository utxoRepository;

  BalanceRepositoryImpl({required this.api, required this.utxoRepository});

  @override
  Future<List<b.Balance>> getBalancesForAddress(String address) async {
    final List<b.Balance> balances = [];
    balances.addAll(await _getBtcBalances([address]));
    balances.addAll(await _fetchBalances(address));
    return balances;
  }

  @override
  Future<List<b.Balance>> getBalancesForAddresses(
      List<String> addresses) async {
    final List<b.Balance> balances = [];
    balances.addAll(await _getBtcBalances(addresses));

    for (var address in addresses) {
      try {
        balances.addAll(await _fetchBalances(address));
      } catch (e, callstack) {
        print(callstack);
        continue;
      }
    }

    return balances;
  }

  Future<List<b.Balance>> _fetchBalances(String address) async {
    final List<b.Balance> balances = [];
    int limit = 50;
    int? cursor;

    do {
      final response =
          await api.getBalancesByAddressVerbose(address, cursor, limit);

      for (var a in response.result ?? []) {

        balances.add(b.Balance(
            address: address,
            quantity: a.quantity,
            quantityNormalized: a.quantityNormalized,
            asset: a.asset,
            assetInfo: ai.AssetInfo(
              assetLongname: a.assetInfo.assetLongname,
              description: a.assetInfo.description,
              // issuer: a.assetInfo.issuer,
              divisible: a.assetInfo.divisible,
              // locked: a.assetInfo.locked,
            )));
      }
      cursor = response.nextCursor;
    } while (cursor != null);

    return balances;
  }

  Future<List<b.Balance>> _getBtcBalances(List<String> addresses) async {
    final List<b.Balance> balances = [];
    for (var address in addresses) {
      final utxos = await utxoRepository.getUnspentForAddress(address);
      // value is in sats, amount is in BTC
      int sum = utxos.fold(0, (sum, utxo) => sum + utxo.value);
      double normalized = utxos.fold(0, (sum, utxo) => sum + utxo.amount);
      balances.add(b.Balance(
          asset: 'BTC',
          quantity: sum,
          quantityNormalized: normalized.toString(),
          address: address,
          // this is a bit of a hack admittedly
          assetInfo: const ai.AssetInfo(
            assetLongname: 'Bitcoin',
            description: 'Bitcoin',
            // issuer: 'Bitcoin',
            divisible: true,
            // locked: false,
          )));
    }
    return balances;
  }
}
