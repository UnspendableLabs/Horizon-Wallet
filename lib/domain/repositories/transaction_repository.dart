import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';

// TODO: rename transction info to transction verbose

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(String raw);
  Future<TransactionUnpackedVerbose> unpackVerbose(String raw);
  Future<TransactionInfo> getInfo(String raw);
  Future<TransactionInfoVerbose> getInfoVerbose(String raw);
  // Future<(List<TransactionInfo>, int? nextCursor, int? total)> getByAccount(
  //     {required String accountUuid,
  //     int? limit,
  //     int? cursor,
  //     bool? unconfirmed = false});
  Future<(List<TransactionInfoVerbose>, int? nextCursor, int? total)>
      getByAccountVerbose(
          {required String accountUuid,
          int? limit,
          int? cursor,
          bool? unconfirmed = false});
}
