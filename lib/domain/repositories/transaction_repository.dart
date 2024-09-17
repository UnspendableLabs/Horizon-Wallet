import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionUnpackedVerbose> unpackVerbose(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<TransactionInfoVerbose> getInfoVerbose(String raw);
  // Future<(List<TransactionInfo>, Cursor? nextCursor, int? total)> getByAccount(
  //     {required String accountUuid,
  //     int? limit,
  //     Cursor? cursor,
  //     bool? unconfirmed = false});
  Future<(List<TransactionInfoVerbose>, Cursor? nextCursor, int? total)>
      getByAccountVerbose(
          {required String accountUuid,
          int? limit,
          Cursor? cursor,
          bool? unconfirmed = false});
}
