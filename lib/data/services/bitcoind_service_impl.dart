import 'package:fpdart/fpdart.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/network_error.dart';
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
  TaskEither<NetworkError, String> sendrawtransaction(
    String signedHex,
    HttpConfig httpConfig,
  ) {
    return handleNetworkCall(() async {
      final client = _counterpartyClientFactory.getClient(httpConfig);
      final res = await client.createTransaction(signedHex);
      if (res.result == null) {
        throw Exception('Failed to send raw transaction');
      }
      return res.result!;
    });
  }

  @override
  TaskEither<NetworkError, int> estimateSmartFee({
    required int confirmationTarget,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final client = _counterpartyClientFactory.getClient(httpConfig);
      final res = await client.estimateSmartFee(confirmationTarget);
      if (res.result == null) {
        throw Exception('Failed to estimate smart fee');
      }
      return res.result!;
    });
  }

  @override
  TaskEither<NetworkError, DecodedTx> decoderawtransaction({
    required String raw,
    required HttpConfig httpConfig,
  }) {
    return handleNetworkCall(() async {
      final client = _counterpartyClientFactory.getClient(httpConfig);
      final res = await client.decodeTransaction(raw);
      if (res.result == null) {
        throw Exception('Failed to decode raw transaction');
      }
      return res.result!.toDomain();
    });
  }
}
