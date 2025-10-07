import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/repositories/utxo_attach_repository.dart';
import "package:horizon/data/sources/local/dao/utxo_attaches_dao.dart";
import "package:horizon/data/sources/local/db.dart";
import 'package:horizon/domain/entities/utxo_attach.dart' as entity;

class UtxoAttachRepositoryImpl implements UtxoAttachRepository {
  final UtxoAttachesDao _dao;

  UtxoAttachRepositoryImpl({required UtxoAttachesDao dao}) : _dao = dao;

  @override
  Future<void> create(entity.UtxoAttach value) {
    return _dao.insert(UtxoAttach(
      createdAt: value.createdAt,
      utxoID: value.id.toString(),
      quantity: value.quantity.quantity.toInt(),
      divisible: value.quantity.divisible,
      asset: value.asset,
      address: value.address,
    ));
  }

  @override
  Future<entity.UtxoAttach?> getByID(UtxoID utxoID) async {
    final attach = await _dao.getByID(utxoID.toString());

    if (attach != null) {
      return entity.UtxoAttach(
        address: attach.address,
        asset: attach.asset,
        quantity: AssetQuantity(
          quantity: BigInt.from(attach.quantity),
          divisible: attach.divisible,
        ),
        id: UtxoID.fromString(attach.utxoID),
        createdAt: attach.createdAt,
      );
    }

    return null;
  }
}
