import 'package:get_it/get_it.dart';
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/block.dart' as e;
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class BlockRepositoryImpl implements BlockRepository {
  final CounterpartyClientFactory _counterpartyClientFactory;

  BlockRepositoryImpl({
    CounterpartyClientFactory? counterpartyClientFactory,
  }) : _counterpartyClientFactory =
            counterpartyClientFactory ?? GetIt.I<CounterpartyClientFactory>();

  @override
  Future<e.Block> getLastBlock({required HttpConfig httpConfig}) async {
    final response =
        await _counterpartyClientFactory.getClient(httpConfig).getLastBlock();
    if (response.result == null) {
      throw Exception('Failed to fetch last block');
    }
    final api.Block apiBlock = response.result!;
    return e.Block(
      blockIndex: apiBlock.blockIndex,
      blockHash: apiBlock.blockHash,
      blockTime: apiBlock.blockTime,
      previousBlockHash: apiBlock.previousBlockHash,
      difficulty: apiBlock.difficulty,
      ledgerHash: apiBlock.ledgerHash,
      txlistHash: apiBlock.txlistHash,
      messagesHash: apiBlock.messagesHash,
      transactionCount: apiBlock.transactionCount,
      confirmed: apiBlock.confirmed,
    );
  }
}
