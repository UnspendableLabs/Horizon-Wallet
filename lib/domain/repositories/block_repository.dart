import 'package:horizon/domain/entities/block.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class BlockRepository {
  Future<Block> getLastBlock({ required HttpConfig httpConfig });
}
