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
      txid: value.txid,
      createdAt: value.createdAt,
      utxoTxid: value.id.toString(),
    ));
  }
}
