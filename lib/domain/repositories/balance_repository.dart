import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

abstract class BalanceRepository {
  Future<List<Balance>> getBalancesForAddress(String address,
      [bool? excludeUtxoAttached]);
  Future<List<MultiAddressBalance>> getBalancesForAddresses(
      List<String> addresses);
  Future<List<Balance>> getBalancesForAddressAndAssetVerbose(
      String address, String assetName);
  Future<List<Balance>> getBalancesForUTXO(String utxo);
}
