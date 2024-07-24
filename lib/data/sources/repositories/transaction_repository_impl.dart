import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";

class TransactionRepositoryImpl implements TransactionRepository {
  final V2Api api;
  final TransactionsDao transactionDao;
  final AddressRepository addressRepository;

  TransactionRepositoryImpl(
      {required this.api,
      required this.transactionDao,
      required this.addressRepository});

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
    // can only save transactions created locally
    if (transactionInfo.domain != TransactionInfoDomainLocal) {
      throw Exception("Cannot save transaction that was not created locally");
    }

    Map<String, dynamic> unpackedJson = {
      "messageType": transactionInfo.unpackedData.messageType,
      "messageData": transactionInfo.unpackedData.messageData,
    };

    TransactionModel tx = TransactionModel(
      hash: transactionInfo.hash,
      raw: (transactionInfo.domain as TransactionInfoDomainLocal).raw,
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
      domain: TransactionInfoDomainLocal(raw: raw),
      source: info.source,
      destination: info.destination,
      btcAmount: info.btcAmount,
      fee: info.fee,
      data: info.data,
      unpackedData: TransactionUnpacked(
          messageType: unpacked.messageType, messageData: unpacked.messageData),
    );
  }

  @override
  Future<List<TransactionInfo>> getAllByAccount(String accoundUuid) async {
    final addresses = await addressRepository.getAllByAccountUuid(accoundUuid);
    final transactions = await transactionDao
        .getAllBySources(addresses.map((e) => e.address).toList());

    return transactions
        .map((tx) => TransactionInfo(
              domain: TransactionInfoDomainLocal(raw: tx.raw),
              hash: tx.hash,
              source: tx.source,
              destination: tx.destination,
              btcAmount: tx.btcAmount,
              fee: tx.fee,
              data: tx.data,
              unpackedData: TransactionUnpacked(
                  messageType: "",
                  messageData: Map<String, dynamic>.from(jsonDecode(tx
                      .unpackedData))), // TODO: this is a little broken, lift up message type
            ))
        .toList();
  }
}
