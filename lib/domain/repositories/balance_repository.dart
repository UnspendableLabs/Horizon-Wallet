import 'package:horizon/domain/entities/balance.dart';

abstract class BalanceRepository {
  Future<List<Balance>> getBalancesForAddress(String address);
  Future<List<Balance>> getBalancesForAddresses(List<String> addresses);
  Future<List<Balance>> getBalancesForAddressAndAssetVerbose(
      String address, String assetName);
}
