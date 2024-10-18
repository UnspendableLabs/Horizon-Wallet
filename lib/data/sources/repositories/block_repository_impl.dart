import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/block.dart' as e;
import 'package:horizon/domain/repositories/block_repository.dart';

class BlockRepositoryImpl implements BlockRepository {
  final api.V2Api _api;

  BlockRepositoryImpl(this._api);

  @override
  Future<e.Block> getLastBlock() async {
    final response = await _api.getLastBlock();
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
