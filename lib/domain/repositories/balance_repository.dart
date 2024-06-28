import 'package:horizon/domain/entities/balance.dart';

abstract class BalanceRepository {
  Future<List<Balance>> getBalance(String address);
  Future<List<Balance>> getBalances(List<String> addresses);
}
