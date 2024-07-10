import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/balance.dart' as entity;
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class BalanceRepositoryImpl implements BalanceRepository {
  final V2Api api;

  BalanceRepositoryImpl({required this.api});

  @override
  Future<List<entity.Balance>> getBalance(String address) async {
    return _fetchBalances(address);
  }

  @override
  Future<List<entity.Balance>> getBalances(List<String> addresses) async {
    final List<entity.Balance> balances = [];
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
    int? cursor;

    do {
      final response = await api.getBalancesByAddress(address, true, cursor);

      for (var a in response.result ?? []) {
        balances.add(entity.Balance(address: address, quantity: a.quantity, asset: a.asset));
      }
      cursor = response.nextCursor;
    } while (cursor != null);

    return balances;
  }
}
