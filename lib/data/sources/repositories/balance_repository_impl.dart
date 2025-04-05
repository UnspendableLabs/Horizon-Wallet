import 'package:horizon/common/constants.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as ai;
import 'package:horizon/domain/entities/balance.dart' as b;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/domain/entities/multi_address_balance.dart' as mba;
import 'package:horizon/domain/entities/multi_address_balance_entry.dart'
    as mba_entry;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';

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
  Future<List<b.Balance>> getBalancesForAddress(String address,
      [bool? excludeUtxoAttached]) async {
    final List<b.Balance> balances = [];
    balances.addAll([await _getBtcBalance(address: address)]);
    final balances_ = await _fetchBalances(address);
    if (excludeUtxoAttached == null || excludeUtxoAttached == false) {
      balances.addAll(balances_);
    } else {
      balances.addAll(balances_.where((balance) => balance.utxo == null));
    }
    return balances;
  }

  @override
  Future<List<mba.MultiAddressBalance>> getBalancesForAddresses(
      List<String> addresses) async {
    final List<mba.MultiAddressBalance> balances = [];
    balances.addAll([await _getBtcBalancesForAddresses(addresses: addresses)]);
    balances.addAll(await _fetchBalancesByAllAddresses(addresses));
    return balances;
  }

  @override
  Future<mba.MultiAddressBalance> getBalancesForAddressesAndAsset(
      List<String> addresses, String assetName,
      [BalanceType? type]) async {
    final List<mba.MultiAddressBalance> balances =
        await _fetchBalancesByAllAddresses(addresses, assetName, type);

    // This multi-address balance is for a single asset, so though the response returns a list, there will only be one item
    return balances.first;
  }

  @override
  Future<mba.MultiAddressBalance> getBtcBalancesForAddresses(
      List<String> addresses) async {
    return await _getBtcBalancesForAddresses(addresses: addresses);
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
              locked: a.assetInfo.locked,
            ),
            utxo: a.utxo,
            utxoAddress: a.utxoAddress));
      }
      cursor = cursor_model.CursorMapper.toDomain(response.nextCursor);
    } while (cursor != null);

    return balances;
  }

  Future<List<mba.MultiAddressBalance>> _fetchBalancesByAllAddresses(
      List<String> addresses,
      [String? asset,
      BalanceType? type]) async {
    final List<mba.MultiAddressBalance> balances = [];
    int limit = 50;
    cursor_model.CursorModel? cursor;

    do {
      final response = await api.getBalancesByAddressesVerbose(
          addresses.join(','), cursor, limit, asset, type?.name);
      for (var a in response.result ?? []) {
        balances.add(mba.MultiAddressBalance(
            asset: a.asset,
            assetLongname: a.assetInfo.assetLongname,
            total: a.total,
            totalNormalized: a.totalNormalized,
            entries: a.addresses
                .map((e) => mba_entry.MultiAddressBalanceEntry(
                    address: e.address,
                    quantity: e.quantity,
                    quantityNormalized: e.quantityNormalized,
                    utxo: e.utxo,
                    utxoAddress: e.utxoAddress))
                .cast<mba_entry.MultiAddressBalanceEntry>()
                .toList(),
            assetInfo: ai.AssetInfo(
              assetLongname: a.assetInfo.assetLongname,
              description: a.assetInfo.description,
              divisible: a.assetInfo.divisible,
              owner: a.assetInfo.owner,
              issuer: a.assetInfo.issuer,
              locked: a.assetInfo.locked,
            )));
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
            locked: false,
          ));
    });
  }

  Future<mba.MultiAddressBalance> _getBtcBalancesForAddresses(
      {required List<String> addresses}) async {
    // final List<mba.MultiAddressBalance> balances = [];
    final List<b.Balance> balances_ = [];
    for (var address in addresses) {
      final balance = await _getBtcBalance(address: address);
      balances_.add(balance);
    }
    final total = balances_.fold(0, (sum, balance) => sum + balance.quantity);
    final totalNormalized = satoshisToBtc(total).toStringAsFixed(8);
    return mba.MultiAddressBalance(
      asset: 'BTC',
      assetLongname: null,
      total: total,
      totalNormalized: totalNormalized,
      entries: balances_
          .map((e) => mba_entry.MultiAddressBalanceEntry(
              address: e.address,
              quantity: e.quantity,
              quantityNormalized: e.quantityNormalized,
              utxo: e.utxo,
              utxoAddress: e.utxoAddress))
          .cast<mba_entry.MultiAddressBalanceEntry>()
          .toList(),
      assetInfo: const ai.AssetInfo(
          assetLongname: 'BTC',
          description: 'Bitcoin',
          divisible: true,
          locked: false),
    );
  }

  @override
  Future<List<b.Balance>> getBalancesForAddressAndAssetVerbose(
      String address, String assetName) async {
    final response =
        await api.getBalancesForAddressAndAssetVerbose(address, assetName);
    final balances = response.result;
    if (balances == null) {
      throw Exception('Failed to get balance for $address and $assetName');
    }

    final List<b.Balance> entityBalances = [];
    for (var balance in balances) {
      entityBalances.add(b.Balance(
        address: address,
        quantity: balance.quantity.toInt(),
        quantityNormalized: balance.quantityNormalized,
        asset: balance.asset,
        assetInfo: ai.AssetInfo(
          assetLongname: balance.assetInfo.assetLongname,
          description: balance.assetInfo.description,
          issuer: balance.assetInfo.issuer,
          owner: balance.assetInfo.owner,
          divisible: balance.assetInfo.divisible,
          locked: balance.assetInfo.locked,
        ),
        utxo: balance.utxo,
        utxoAddress: balance.utxoAddress,
      ));
    }
    return entityBalances;
  }

  @override
  Future<List<b.Balance>> getBalancesForUTXO(String utxo) async {
    final response = await api.getBalancesByUTXO(utxo);
    final balances = response.result;
    if (balances == null) {
      throw Exception('Failed to get balances for $utxo');
    }
    final List<b.Balance> entityBalances = [];
    for (var balance in balances) {
      entityBalances.add(b.Balance(
        address: balance.address,
        quantity: balance.quantity.toInt(),
        quantityNormalized: balance.quantityNormalized,
        asset: balance.asset,
        utxo: utxo,
        utxoAddress: balance.utxoAddress,
        assetInfo: ai.AssetInfo(
          assetLongname: balance.assetInfo.assetLongname,
          description: balance.assetInfo.description,
          issuer: balance.assetInfo.issuer,
          owner: balance.assetInfo.owner,
          divisible: balance.assetInfo.divisible,
          locked: balance.assetInfo.locked,
        ),
      ));
    }
    return entityBalances;
  }
}
