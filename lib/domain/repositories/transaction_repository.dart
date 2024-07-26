import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

// TODO: rename transction info to transction verbose

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<(List<TransactionInfo>, int? nextCursor, int? resultCount)> getByAccount(
      {required String accountUuid,
      int? limit,
      int? cursor,
      bool? unconfirmed = false});
}
