import 'package:horizon/data/models/purpose.dart';
import 'package:horizon/data/sources/local/dao/purposes_dao.dart';
import 'package:horizon/data/sources/local/db.dart' as local;
import 'package:horizon/domain/entities/purpose.dart' as entity;
import 'package:horizon/domain/repositories/purpose_repository.dart';

class PurposeRepositoryImpl extends PurposeRepository {
  final local.DB _db;
  final PurposesDao _purposesDao;

  PurposeRepositoryImpl(this._db) : _purposesDao = PurposesDao(_db);
  @override
  Future<void> insert(entity.Purpose purpose) async {
    await _purposesDao.insertPurpose(PurposeModel(
      uuid: purpose.uuid,
      bip: purpose.bip,
      walletUuid: purpose.walletUuid,
    ));
  }

  @override
  Future<List<entity.Purpose>> getPurposesByWalletUuid(String walletUuid) async {
    final purposes = await _purposesDao.getPurposesByWalletUuid(walletUuid);
    final List<entity.Purpose> purposesList = purposes
        .map((purpose) => entity.Purpose(
              uuid: purpose.uuid,
              bip: purpose.bip,
              walletUuid: purpose.walletUuid,
            ))
        .toList();
    return purposesList;
  }

  @override
  Future<entity.Purpose> getPurpose(String uuid) async {
    final purpose = await _purposesDao.getPurposeByUuid(uuid);
    return entity.Purpose(
      uuid: purpose!.uuid,
      bip: purpose!.bip,
      walletUuid: purpose!.walletUuid,
    );
  }

  @override
  Future<void> deletePurpose(entity.Purpose purpose) async {
    await _purposesDao.deletePurpose(PurposeModel(
      uuid: purpose.uuid,
      bip: purpose.bip,
      walletUuid: purpose.walletUuid,
    ));
  }
}
