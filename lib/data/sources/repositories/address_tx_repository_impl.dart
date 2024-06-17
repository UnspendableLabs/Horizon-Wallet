import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_entity;
import 'package:horizon/domain/entities/send.dart' as entity;
import 'package:horizon/domain/repositories/address_tx_repository.dart';

class AddressTxRepositoryImpl extends AddressTxRepository {
  final V2Api api;
  AddressTxRepositoryImpl({required this.api});

  @override
  Future<List<entity.Send>> getSends(String address) async {
    Response<List<Send>> response = await api.getSends(address, true, 10);
    final List<entity.Send> sends = [];

    for (var send in response.result ?? []) {
      sends.add(entity.Send(
          asset: send.asset,
          quantity: send.quantity,
          status: send.status,
          txIndex: send.txIndex,
          txHash: send.txHash,
          blockIndex: send.blockIndex,
          source: send.source,
          destination: send.destination,
          msgIndex: send.msgIndex,
          memo: send.memo,
          assetInfo: asset_entity.AssetInfo(
              assetLongname: send.assetInfo.assetLongname,
              description: send.assetInfo.description,
              divisible: send.assetInfo.divisible,
              locked: send.assetInfo.locked,
              issuer: send.assetInfo.issuer),
          quantityNormalized: send.quantityNormalized));
    }

    return sends;
  }
}
