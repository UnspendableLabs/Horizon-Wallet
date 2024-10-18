import 'package:horizon/domain/entities/block.dart';

abstract class BlockRepository {
  Future<Block> getLastBlock();
}
