import 'package:horizon/domain/entities/node_info.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class NodeInfoRepository {
  Future<NodeInfo> getNodeInfo(HttpConfig httpConfig);
}
