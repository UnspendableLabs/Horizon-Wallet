import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/node_info.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';

class NodeInfoRepositoryImpl implements NodeInfoRepository {
  final V2Api _v2Api;

  NodeInfoRepositoryImpl(this._v2Api);

  @override
  Future<NodeInfo> getNodeInfo() async {
    final response = await _v2Api.getNodeInfo();
    final nodeInfo = response.result;
    if (nodeInfo == null) {
      throw Exception('Failed to fetch node info');
    }
    return nodeInfo.toDomain();
  }
}
