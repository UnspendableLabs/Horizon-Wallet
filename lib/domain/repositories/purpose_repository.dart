import 'package:horizon/domain/entities/purpose.dart' as entity;

abstract class PurposeRepository {
  Future<entity.Purpose?> getPurpose(String uuid);
  Future<void> insert(entity.Purpose purpose);
  Future<List<entity.Purpose>> getPurposesByWalletUuid(String walletUuid);
  Future<void> deletePurpose(entity.Purpose purpose);
  // Future<void> deleteAllPurposes();
}
