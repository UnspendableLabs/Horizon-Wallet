import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";

class TransactionLocalRepositoryImpl implements TransactionLocalRepository {
  final V2Api api;
  final TransactionsDao transactionDao;
  final AddressRepository addressRepository;

  TransactionLocalRepositoryImpl(
      {required this.api,
      required this.transactionDao,
      required this.addressRepository});

  @override
  Future<void> insert(TransactionInfo transactionInfo) async {
    // can only save transactions createk locally
    if (transactionInfo.domain.runtimeType != TransactionInfoDomainLocal) {
      throw Exception("Cannot save transaction that was not created locally");
    }

    Map<String, dynamic>? unpackedJson = transactionInfo.unpackedData == null
        ? null
        : {
            "messageType": transactionInfo.unpackedData!.messageType,
            "messageData": transactionInfo.unpackedData!.messageData,
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
  Future<List<TransactionInfo>> getAllByAccount(String accountUuid) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
    final transactions = await transactionDao
        .getAllBySources(addresses.map((e) => e.address).toList());

    return transactions
        .map((tx) => TransactionInfo(
              domain: TransactionInfoDomainLocal(
                  raw: tx.raw, submittedAt: tx.submittedAt),
              hash: tx.hash,
              source: tx.source,
              destination: tx.destination,
              btcAmount: tx.btcAmount,
              fee: tx.fee,
              data: tx.data,
              unpackedData: null,
              // unpackedData: tx.unpackedData != null
              //     ? TransactionUnpacked(
              //         messageType: "",
              //         messageData: Map<String, dynamic>.from(
              //             jsonDecode(tx.unpackedData!)))
              //     : null, // TODO: this is a little broken, lift up message type
            ))
        .toList();
  }

  @override
  Future<List<TransactionInfo>> getAllByAccountAfterDate(
      String accountUuid, DateTime date) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
    final transactions = await transactionDao.getAllBySourcesAfterDate(
        addresses.map((e) => e.address).toList(), date);


    return transactions.map((tx) {
      return TransactionInfo(
        domain: TransactionInfoDomainLocal(
            raw: tx.raw, submittedAt: tx.submittedAt),
        hash: tx.hash,
        source: tx.source,
        destination: tx.destination,
        btcAmount: tx.btcAmount,
        fee: tx.fee,
        data: tx.data,
        unpackedData: null,
        // unpackedData: tx.unpackedData != null
        //     ? TransactionUnpacked(
        //         messageType: "",
        //         messageData:
        //             Map<String, dynamic>.from(jsonDecode(tx.unpackedData!)))
        //     : null, // TODO: this is a little broken, lift up message type
      );
    }).toList();
  }
}
