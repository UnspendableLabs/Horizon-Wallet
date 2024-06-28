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
    final response =
        await api.getBalancesByAddress(address, true); // verbose by default

    final List<entity.Balance> balances = [];
    for (var a in response.result ?? []) {
      balances.add(entity.Balance(
          address: address, quantity: a.quantity, asset: a.asset));
    }
    return balances;
  }

  @override
  Future<List<entity.Balance>> getBalances(List<String> addresses) async {
    final List<entity.Balance> balances = [];
    for (var address in addresses) {
      try {
        final response =
            await api.getBalancesByAddress(address, true); // verbose by default
        for (var a in response.result ?? []) {
          balances.add(entity.Balance(
              address: address, quantity: a.quantity, asset: a.asset));
        }
      } catch (e) {
        continue;
      }
    }

    print(balances);

    return balances;
  }
}
