import 'package:horizon/data/models/bitcoin_decoded_tx.dart';
import "package:horizon/data/sources/network/api/v2_api.dart" as v2_api;
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class BitcoindServiceCounterpartyProxyImpl implements BitcoindService {
  final CounterpartyClientFactory _counterpartyClientFactory;

  BitcoindServiceCounterpartyProxyImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<String> sendrawtransaction(
      String signedHex, HttpConfig httpConfig) async {
    try {
      final client = _counterpartyClientFactory.getClient(httpConfig);
      final res = await client.createTransaction(signedHex);
      return res.result!;
    } on DioException catch (e) {
      // Check if response exists and has data
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;

        // Try to parse meaningful error message from the response body
        final message =
            data is Map<String, dynamic> && data.containsKey('error')
                ? data['error'].toString()
                : data.toString();

        throw Exception(message);
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
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
