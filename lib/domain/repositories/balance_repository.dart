import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

// TODO: this is a smell, we shouldn't be referencing data
// domain directly here.  we need an abstract client

abstract class BalanceRepository {
  Future<List<Balance>> getBalancesForAddress({
    required HttpConfig httpConfig,
    required String address,
    bool? excludeUtxoAttached,
  });

  Future<List<MultiAddressBalance>> getBalancesForAddresses({
    required HttpConfig httpConfig,
    required List<String> addresses,
  });

  Future<MultiAddressBalance> getBalancesForAddressesAndAsset({
    required HttpConfig httpConfig,
    required List<String> addresses,
    required String assetName,
    BalanceType? type,
  });

  Future<List<Balance>> getBalancesForAddressAndAssetVerbose({
    required HttpConfig httpConfig,
    required String address,
    required String assetName,
  });

  Future<List<Balance>> getBalancesForUTXO({
    required HttpConfig httpConfig,
    required String utxo,
  });
}
