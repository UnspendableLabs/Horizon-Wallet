import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/balance.dart' as entity;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class BalanceRepositoryImpl implements BalanceRepository {
  final V2Api api;
  final UtxoRepository utxoRepository;

  BalanceRepositoryImpl({required this.api, required this.utxoRepository});

  @override
  Future<List<entity.Balance>> getBalancesForAddress(String address) async {
    final List<entity.Balance> balances = [];
    balances.addAll(await _getBtcBalances([address]));
    balances.addAll(await _fetchBalances(address));
    return balances;
  }

  @override
  Future<List<entity.Balance>> getBalancesForAddresses(List<String> addresses) async {
    final List<entity.Balance> balances = [];
    balances.addAll(await _getBtcBalances(addresses));

    for (var address in addresses) {
      try {
        balances.addAll(await _fetchBalances(address));
      } catch (e) {
        continue;
      }
    }

    return balances;
  }

  Future<List<entity.Balance>> _fetchBalances(String address) async {
    final List<entity.Balance> balances = [];
    int limit = 50;
    int? cursor;

    do {
      final response = await api.getBalancesByAddress(address, true, cursor, limit);

      for (var a in response.result ?? []) {
        balances.add(entity.Balance(address: address, quantity: a.quantity, asset: a.asset));
      }
      cursor = response.nextCursor;
    } while (cursor != null);

    return balances;
  }

  Future<List<entity.Balance>> _getBtcBalances(List<String> addresses) async {
    final List<entity.Balance> balances = [];
    for (var address in addresses) {
      final utxos = await utxoRepository.getUnspentForAddress(address);
      double sum = utxos.fold(0, (sum, utxo) => sum + utxo.amount);
      balances.add(entity.Balance(asset: 'BTC', quantity: sum, address: address));
    }
    return balances;
  }
}
