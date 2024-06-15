import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/services/bitcoind_service.dart';

class BitcoindServiceCounterpartyProxyImpl implements BitcoindService {
  final v2_api.V2Api api;

  BitcoindServiceCounterpartyProxyImpl(this.api);

  @override
  Future<v2_api.Response<String>> sendrawtransaction(String signedHex) async {
    return api.createTransaction(signedHex);
  }
}
