import 'package:horizon/data/sources/local/dao/locked_utxo_dao.dart';
import 'package:horizon/data/models/locked_utxo.dart';
import 'package:horizon/domain/entities/locked_utxo.dart';
import 'package:horizon/domain/repositories/locked_utxo_repository.dart';

class LockedUtxoMapper {
  static LockedUtxo toEntity(LockedUtxoModel model) {
    return LockedUtxo(
      id: model.id,
      txHash: model.txHash,
      address: model.address,
      txid: model.txid,
      vout: model.vout,
      value: model.value,
      lockedAt: model.lockedAt,
    );
  }

  static LockedUtxoModel toModel(LockedUtxo entity) {
    return LockedUtxoModel(
      id: entity.id,
      txHash: entity.txHash,
      address: entity.address,
      txid: entity.txid,
      vout: entity.vout,
      value: entity.value,
      lockedAt: entity.lockedAt,
    );
  }
}

class LockedUtxoRepositoryImpl implements LockedUtxoRepository {
  final LockedUtxoDao lockedUtxoDao;

  LockedUtxoRepositoryImpl({required this.lockedUtxoDao});

  @override
  Future<void> deleteLockedUtxo(LockedUtxo lockedUtxo) {
    return lockedUtxoDao.deleteLockedUtxo(LockedUtxoMapper.toModel(lockedUtxo));
  }

  @override
  Future<void> deleteLockedUtxoByTxHash(String txHash) {
    return lockedUtxoDao.deleteLockedUtxoByTxHash(txHash);
  }

  @override
  Future<List<LockedUtxo>> getLockedUtxosForAddress(String address) {
    return lockedUtxoDao
        .getLockedUtxosForAddress(address)
        .then((models) => models.map(LockedUtxoMapper.toEntity).toList());
  }

  @override
  Future<List<LockedUtxo>> getLockedUtxosForTxHash(String txHash) {
    return lockedUtxoDao
        .getLockedUtxosForTxHash(txHash)
        .then((models) => models.map(LockedUtxoMapper.toEntity).toList());
  }

  @override
  Future<void> insertLockedUtxo(LockedUtxo lockedUtxo) {
    return lockedUtxoDao.insertLockedUtxo(LockedUtxoMapper.toModel(lockedUtxo));
  }
}
