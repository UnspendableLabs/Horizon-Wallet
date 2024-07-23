import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
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
  Future<void> insert(TransactionInfo transactionInfo) async {
    Map<String, dynamic> unpackedJson = {
      "messageType": transactionInfo.unpackedData.messageType,
      "messageData": transactionInfo.unpackedData.messageData,
    };

    TransactionModel tx = TransactionModel(
      hash: transactionInfo.hash,
      raw: transactionInfo.raw,
      source: transactionInfo.source,
      destination: transactionInfo.destination,
      btcAmount: transactionInfo.btcAmount,
      fee: transactionInfo.fee,
      data: transactionInfo.data,
      unpackedData: jsonEncode(unpackedJson),
      submittedAt: DateTime.now(),
    );

    await transactionDao.insert(tx);
  }

  @override
  Future<TransactionInfo> getInfo(String raw) async {
    final response = await api.getTransactionInfo(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    Info info = response.result!;

    Unpack unpacked = info.unpackedData;

    return TransactionInfo(
      hash: "",
      raw: raw,
      source: info.source,
      destination: info.destination,
      btcAmount: info.btcAmount,
      fee: info.fee,
      data: info.data,
      unpackedData: TransactionUnpacked(
          messageType: unpacked.messageType, messageData: unpacked.messageData),
    );
  }
}
