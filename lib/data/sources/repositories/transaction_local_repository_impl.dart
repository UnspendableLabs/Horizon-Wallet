import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart'
    as unpacked_domain;
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";
import "package:horizon/data/models/unpacked.dart" as unpacked_model;

class UnpackedMapper {
  static unpacked_domain.TransactionUnpacked toDomain(
      unpacked_model.TransactionUnpacked u) {
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedMapper.toDomain(
            u as unpacked_model.EnhancedSendUnpacked);
      default:
        return unpacked_domain.TransactionUnpacked(
          messageType: u.messageType,
        );
    }
  }
}

class EnhancedSendUnpackedMapper {
  static unpacked_domain.EnhancedSendUnpacked toDomain(
      unpacked_model.EnhancedSendUnpacked u) {
    return unpacked_domain.EnhancedSendUnpacked(
      asset: u.asset,
      quantity: u.quantity,
      address: u.address,
      memo: u.memo,
    );
  }
}

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

    unpacked_domain.TransactionUnpacked? unpacked =
        transactionInfo.unpackedData;

    Map<String, dynamic>? json = unpacked == null
        ? null
        : unpacked_model.TransactionUnpacked.fromDomain(unpacked).toJson();

    TransactionModel tx = TransactionModel(
      hash: transactionInfo.hash,
      raw: (transactionInfo.domain as TransactionInfoDomainLocal).raw,
      source: transactionInfo.source,
      destination: transactionInfo.destination,
      btcAmount: transactionInfo.btcAmount,
      fee: transactionInfo.fee,
      data: transactionInfo.data,
      unpackedData: jsonEncode(json),
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
            unpackedData: UnpackedMapper.toDomain(
                unpacked_model.TransactionUnpacked.fromJson(
                    jsonDecode(tx.unpackedData!)))

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
          unpackedData: UnpackedMapper.toDomain(
              unpacked_model.TransactionUnpacked.fromJson(
                  jsonDecode(tx.unpackedData!)))
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
