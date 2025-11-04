import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/node_info.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class NodeInfoRepository {
  TaskEither<String, NodeInfo> getNodeInfo(HttpConfig httpConfig);
}
