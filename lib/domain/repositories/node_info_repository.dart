import 'package:horizon/domain/entities/node_info.dart';

abstract class NodeInfoRepository {
  Future<NodeInfo> getNodeInfo();
}
