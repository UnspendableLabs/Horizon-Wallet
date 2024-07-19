import 'package:horizon/domain/entities/transaction_unpacked.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String hex);
  Future<void> insert(
      {required String hash,
      required String hex,
      required String source,
      required TransactionUnpacked unpacked});
}
