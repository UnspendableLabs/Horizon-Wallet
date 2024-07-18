import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/services/bitcoind_service.dart';

class BitcoindServiceCounterpartyProxyImpl implements BitcoindService {
  final v2_api.V2Api api;

  BitcoindServiceCounterpartyProxyImpl(this.api);

  @override
  Future<String> sendrawtransaction(String signedHex) async {
    v2_api.Response<String> res = await api.createTransaction(signedHex);
    return res.result!;
  }
}
