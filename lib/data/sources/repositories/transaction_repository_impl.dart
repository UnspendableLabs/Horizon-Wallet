
import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";

class TransactionRepositoryImpl implements TransactionRepository {
  final V2Api api;
  final TransactionsDao transactionDao;

  TransactionRepositoryImpl({required this.api, required this.transactionDao});

  @override
  Future<TransactionUnpacked> unpack(String hex) async {
    final response = await api.unpackTransaction(hex);
    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    Unpack unpacked = response.result!;

    return TransactionUnpacked(
      messageType: unpacked.messageType,
      messageData: unpacked.toJson(),
    );
  }

  @override
  Future<void> insert(
      {required String hash,
      required String hex,
      required String source,
      required TransactionUnpacked unpacked}) async {
    TransactionModel tx = TransactionModel(
        hash: hash,
        submittedAt: DateTime.now(),
        hex: hex,
        source: source,
        unpacked: "");

    await transactionDao.insert(tx);
  }
}
