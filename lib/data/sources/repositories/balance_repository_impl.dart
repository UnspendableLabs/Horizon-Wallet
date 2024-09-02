import 'package:collection/collection.dart' as _;
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as ai;
import 'package:horizon/domain/entities/balance.dart' as b;
import 'package:horizon/domain/entities/utxo.dart' as entity;
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
    throw Exception('test');
    return balances;
  }

  @override
  Future<List<b.Balance>> getBalancesForAddresses(
      List<String> addresses) async {
    final List<b.Balance> balances = [];
    balances.addAll(await _getBtcBalances(addresses));
    balances.addAll(await _fetchBalancesByAllAddresses(addresses));
    throw DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(path: 'test'));
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

  Future<List<b.Balance>> _fetchBalancesByAllAddresses(
      List<String> addresses) async {
    final List<b.Balance> balances = [];
    int limit = 50;
    int? cursor;

    do {
      final response = await api.getBalancesByAddressesVerbose(
          addresses.join(','), cursor, limit);
      for (MultiAddressBalanceVerbose a in response.result ?? []) {
        for (MultiBalanceVerbose balance in a.addresses) {
          balances.add(b.Balance(
              address: balance.address,
              quantity: balance.quantity,
              quantityNormalized: balance.quantityNormalized,
              asset: a.asset,
              assetInfo: ai.AssetInfo(
                assetLongname: a.assetInfo.assetLongname,
                description: a.assetInfo.description,
                // issuer: a.assetInfo.issuer,
                divisible: a.assetInfo.divisible,
                // locked: a.assetInfo.locked,
              )));
        }
      }
      cursor = response.nextCursor;
    } while (cursor != null);
    return balances;
  }

  Future<List<b.Balance>> _getBtcBalances(List<String> addresses) async {
    final List<b.Balance> balances = [];

    List<entity.Utxo> utxos =
        await utxoRepository.getUnspentForAddresses(addresses);
    Map<String, List<entity.Utxo>> utxosByAddress =
        _.groupBy(utxos, (utxo) => utxo.address);

    utxosByAddress.forEach((address, utxos) {
      int sum = utxos.fold(0, (sum, utxo) => sum + utxo.value);
      Decimal normalized = utxos.fold(Decimal.zero,
          (sum, utxo) => sum + Decimal.parse(utxo.amount.toString()));
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
    });

    return balances;
  }
}
