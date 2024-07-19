import 'package:horizon/domain/entities/transaction_unpacked.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String hex);
}
