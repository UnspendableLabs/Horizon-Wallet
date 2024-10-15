import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<(List<TransactionInfo>, Cursor? nextCursor, int? total)>
      getByAccount(
          {required String accountUuid,
          int? limit,
          Cursor? cursor,
          bool? unconfirmed = false});
}
