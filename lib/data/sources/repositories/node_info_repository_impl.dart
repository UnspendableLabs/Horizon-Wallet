import 'package:fpdart/fpdart.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/repositories/network_error_helpers.dart';
import 'package:horizon/domain/entities/node_info.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class NodeInfoRepositoryImpl implements NodeInfoRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;

  NodeInfoRepositoryImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  TaskEither<String, NodeInfo> getNodeInfo(HttpConfig httpConfig) {
    return handleNetworkCall(
      () async {
        final response = await _counterpartyClientFactory
            .getClient(httpConfig)
            .getNodeInfo();

        if (response.result == null) {
          throw Exception('Failed to fetch node info');
        }

        return response.result!.toDomain();
      },
    );
  }
}
