import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/http_clients.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

// TODO: this is a smell, we shouldn't be referencing data
// domain directly here.  we need an abstract client

import 'package:horizon/data/sources/network/api/v2_api.dart' show V2Api;

abstract class BalanceRepository {
  Future<List<Balance>> getBalancesForAddress({
    required V2Api client,
    required String address,
    bool? excludeUtxoAttached,
  });

  Future<List<MultiAddressBalance>> getBalancesForAddresses({
    required V2Api client,
    required List<String> addresses,
  });

  Future<MultiAddressBalance> getBalancesForAddressesAndAsset({
    required V2Api client,
    required List<String> addresses,
    required String assetName,
    BalanceType? type,
  });

  Future<List<Balance>> getBalancesForAddressAndAssetVerbose({
    required V2Api client,
    required String address,
    required String assetName,
  });

  Future<List<Balance>> getBalancesForUTXO({
    required V2Api client,
    required String utxo,
  });
}
