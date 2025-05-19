import 'package:horizon/data/models/bitcoin_decoded_tx.dart';
import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:get_it/get_it.dart';

class BitcoindServiceCounterpartyProxyImpl implements BitcoindService {
  final CounterpartyClientFactory _counterpartyClientFactory;

  BitcoindServiceCounterpartyProxyImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<String> sendrawtransaction(
      String signedHex, HttpConfig httpConfig) async {
    v2_api.Response<String> res = await _counterpartyClientFactory
        .getClient(httpConfig)
        .createTransaction(signedHex);
    return res.result!;
  }

  @override
  Future<int> estimateSmartFee(
      {required int confirmationTarget, required HttpConfig httpConfig}) async {
    v2_api.Response<int> res = await _counterpartyClientFactory
        .getClient(httpConfig)
        .estimateSmartFee(confirmationTarget);
    return res.result!;
  }

  @override
  Future<DecodedTx> decoderawtransaction(
      String raw, HttpConfig httpConfig) async {
    v2_api.Response<DecodedTxModel> res = await _counterpartyClientFactory
        .getClient(httpConfig)
        .decodeTransaction(raw);
    return res.result!.toDomain();
  }
}
