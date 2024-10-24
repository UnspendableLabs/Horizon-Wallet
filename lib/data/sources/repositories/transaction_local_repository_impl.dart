import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";
import 'package:logger/logger.dart';
import 'package:horizon/data/models/transaction_unpacked.dart';

final logger = Logger();

class TransactionLocalRepositoryImpl implements TransactionLocalRepository {
  final api.V2Api api_;
  final TransactionsDao transactionDao;
  final AddressRepository addressRepository;

  TransactionLocalRepositoryImpl(
      {required this.api_,
      required this.transactionDao,
      required this.addressRepository});

  @override
  Future<void> insert(TransactionInfo transactionInfo) async {
    // can only save transactions created locally
    if (transactionInfo.domain.runtimeType != TransactionInfoDomainLocal) {
      throw Exception("Cannot save transaction that was not created locally");
    }

    String? unpacked = switch (transactionInfo) {
      TransactionInfoEnhancedSend(
        unpackedData: EnhancedSendUnpackedVerbose unpacked
      ) =>
        // TODO: don't do this manually
        jsonEncode({
          "message_type": "enhanced_send",
          "message_data": {
            "asset": unpacked.asset,
            "quantity": unpacked.quantity,
            "address": unpacked.address,
            "memo": unpacked.memo,
            "quantity_normalized": unpacked.quantityNormalized,
          }
        }),
      TransactionInfoIssuance(unpackedData: IssuanceUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "issuance",
          "message_data": {
            "asset_id": unpacked.assetId,
            "asset": unpacked.asset,
            "subasset_longname": unpacked.subassetLongname,
            "quantity": unpacked.quantity,
            "divisible": unpacked.divisible,
            "lock": unpacked.lock,
            "reset": unpacked.reset,
            "callable": unpacked.callable,
            "call_date": unpacked.callDate,
            "call_price": unpacked.callPrice,
            "description": unpacked.description,
            "status": unpacked.status,
            "quantity_normalized": unpacked.quantityNormalized,
          }
        }),
      TransactionInfoDispenser(
        unpackedData: DispenserUnpackedVerbose unpacked
      ) =>
        jsonEncode({
          "message_type": "dispenser",
          "message_data": {
            "asset": unpacked.asset,
            "give_quantity": unpacked.giveQuantity,
            "escrow_quantity": unpacked.escrowQuantity,
            "mainchainrate": unpacked.mainchainrate,
            "status": unpacked.status,
            "give_quantity_normalized": unpacked.giveQuantityNormalized,
            "escrow_quantity_normalized": unpacked.escrowQuantityNormalized,
            // "mainchainrate_normalized": unpacked.mainchainrateNormalized,
          }
        }),
      TransactionInfoDispense(unpackedData: DispenseUnpackedVerbose _) =>
        jsonEncode({"message_type": "dispense", "message_data": {}}),
      TransactionInfoFairmint(unpackedData: FairmintUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "fairmint",
          "message_data": {
            "asset": unpacked.asset,
            "price": unpacked.price,
          }
        }),
      TransactionInfoFairminter(
        unpackedData: FairminterUnpackedVerbose unpacked
      ) =>
        jsonEncode({
          "message_type": "fairminter",
          "message_data": {
            "asset": unpacked.asset,
          }
        }),
      _ => null
    };

    TransactionModel tx = TransactionModel(
      hash: transactionInfo.hash,
      raw: (transactionInfo.domain as TransactionInfoDomainLocal).raw,
      source: transactionInfo.source,
      destination: transactionInfo.destination,
      btcAmount: transactionInfo.btcAmount,
      fee: transactionInfo.fee,
      data: transactionInfo.data,
      unpackedData: unpacked,
      submittedAt: DateTime.now(),
    );

    await transactionDao.insert(tx);
  }

  @override
  Future<List<TransactionInfo>> getAllByAddresses(
      List<String> addresses) async {
    final transactions = await transactionDao.getAllBySources(addresses);

    return transactions.map((tx) {
      api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
          ? api.TransactionUnpackedVerbose.fromJson(
              jsonDecode(tx.unpackedData!))
          : null;

      TransactionUnpacked? unpacked =
          unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;

      return switch (unpacked) {
        EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSend(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        IssuanceUnpackedVerbose() => TransactionInfoIssuance(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        DispenserUnpackedVerbose() => TransactionInfoDispenser(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        DispenseUnpackedVerbose() => TransactionInfoDispense(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        FairmintUnpackedVerbose() => TransactionInfoFairmint(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        FairminterUnpackedVerbose() => TransactionInfoFairminter(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        _ => TransactionInfo(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
          )
      };
    }).toList();
  }

  @override
  Future<List<TransactionInfo>> getAllByAccount(String accountUuid) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
    final transactions = await transactionDao
        .getAllBySources(addresses.map((e) => e.address).toList());

    return transactions.map((tx) {
      api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
          ? api.TransactionUnpackedVerbose.fromJson(
              jsonDecode(tx.unpackedData!))
          : null;

      TransactionUnpacked? unpacked =
          unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;

      return switch (unpacked) {
        EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSend(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        IssuanceUnpackedVerbose() => TransactionInfoIssuance(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        DispenserUnpackedVerbose() => TransactionInfoDispenser(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        DispenseUnpackedVerbose() => TransactionInfoDispense(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        FairmintUnpackedVerbose() => TransactionInfoFairmint(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        FairminterUnpackedVerbose() => TransactionInfoFairminter(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
            unpackedData: unpacked),
        _ => TransactionInfo(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
          )
      };
    }).toList();
  }
}
