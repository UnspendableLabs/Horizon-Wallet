import 'package:horizon/common/format.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as ai;
import 'package:horizon/domain/entities/balance.dart' as b;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class BalanceRepositoryImpl implements BalanceRepository {
  final V2Api api;
  final UtxoRepository utxoRepository;
  final BitcoinRepository bitcoinRepository;

  BalanceRepositoryImpl({
    required this.api,
    required this.utxoRepository,
    required this.bitcoinRepository,
  });

  @override
  Future<List<b.Balance>> getBalancesForAddress(String address) async {
    final List<b.Balance> balances = [];
    balances.addAll([await _getBtcBalance(address: address)]);
    balances.addAll(await _fetchBalances(address));
    return balances;
  }

  @override
  Future<List<b.Balance>> getBalancesForAddresses(
      List<String> addresses) async {
    final List<b.Balance> balances = [];
    balances.addAll([await _getBtcBalance(address: addresses.first)]);
    balances.addAll(await _fetchBalancesByAllAddresses(addresses));
    return balances;
  }

  Future<List<b.Balance>> _fetchBalances(String address) async {
    final List<b.Balance> balances = [];
    int limit = 50;
    cursor_entity.Cursor? cursor;

    do {
      final response = await api.getBalancesByAddressVerbose(
          address, cursor_model.CursorMapper.toData(cursor), limit);

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
      cursor = cursor_model.CursorMapper.toDomain(response.nextCursor);
    } while (cursor != null);

    return balances;
  }

  Future<List<b.Balance>> _fetchBalancesByAllAddresses(
      List<String> addresses) async {
    final List<b.Balance> balances = [];
    int limit = 50;
    cursor_model.CursorModel? cursor;

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

  Future<b.Balance> _getBtcBalance({required String address}) async {
    final info = await bitcoinRepository.getAddressInfo(address);
    return info.fold((failure) {
      throw Exception('Failed to get address info for $address: $failure');
    }, (success) {
      final funded = success.chainStats.fundedTxoSum;
      final spent = success.chainStats.spentTxoSum;
      final quantity = funded - spent;
      final quantityNormalized = satoshisToBtc(quantity).toStringAsFixed(8);

      return b.Balance(
          address: address,
          quantity: quantity,
          quantityNormalized: quantityNormalized,
          asset: 'BTC',
          // TODO: this is a bit of a hack
          assetInfo: const ai.AssetInfo(
            assetLongname: 'BTC',
            description: 'Bitcoin',
            divisible: true,
          ));
    });
  }

  @override
  Future<b.Balance> getBalanceForAddressAndAssetVerbose(
      String address, String assetName) async {
    final response =
        await api.getBalanceForAddressAndAssetVerbose(assetName, address);
    final balance = response.result;
    if (balance == null) {
      throw Exception('Failed to get balance for $address and $assetName');
    }
    return b.Balance(
        address: address,
        quantity: balance.quantity.toInt(),
        quantityNormalized: balance.quantityNormalized,
        asset: balance.asset,
        assetInfo: ai.AssetInfo(
          assetLongname: balance.assetInfo.assetLongname,
          description: balance.assetInfo.description,
          divisible: balance.assetInfo.divisible,
        ));
  }
}
