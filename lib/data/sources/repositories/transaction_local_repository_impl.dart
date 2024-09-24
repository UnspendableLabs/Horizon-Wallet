import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/data/sources/repositories/transaction_repository_impl.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";

class UnpackedMapper {
  static TransactionUnpacked toDomain(api.TransactionUnpacked u) {
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedMapper.toDomain(
            u as api.EnhancedSendUnpacked);
      default:
        return TransactionUnpacked(
          messageType: u.messageType,
        );
    }
  }
}

class EnhancedSendUnpackedMapper {
  static EnhancedSendUnpacked toDomain(api.EnhancedSendUnpacked u) {
    return EnhancedSendUnpacked(
      asset: u.asset,
      quantity: u.quantity,
      address: u.address,
      memo: u.memo,
    );
  }
}

class UnpackedVerboseMapper {
  static TransactionUnpackedVerbose toDomain(api.TransactionUnpackedVerbose u) {
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedVerboseMapper.toDomain(
            u as api.EnhancedSendUnpackedVerbose);
      case "issuance":
        return IssuanceUnpackedVerboseMapper.toDomain(
            u as api.IssuanceUnpackedVerbose);
      default:
        return TransactionUnpackedVerbose(
          messageType: u.messageType,
          // btcAmountNormalized: u.btcAmountNormalized,
        );
    }
  }
}

class EnhancedSendUnpackedVerboseMapper {
  static EnhancedSendUnpackedVerbose toDomain(
      api.EnhancedSendUnpackedVerbose u) {
    return EnhancedSendUnpackedVerbose(
      asset: u.asset,
      quantity: u.quantity,
      address: u.address,
      memo: u.memo,
      quantityNormalized: u.quantityNormalized,
    );
  }
}

class TransactionLocalRepositoryImpl implements TransactionLocalRepository {
  final api.V2Api api_;
  final TransactionsDao transactionDao;
  final AddressRepository addressRepository;

  TransactionLocalRepositoryImpl(
      {required this.api_,
      required this.transactionDao,
      required this.addressRepository});

  @override
  Future<void> insertVerbose(TransactionInfoVerbose transactionInfo) async {
    // can only save transactions created locally
    if (transactionInfo.domain.runtimeType != TransactionInfoDomainLocal) {
      throw Exception("Cannot save transaction that was not created locally");
    }

    String? unpacked = switch (transactionInfo) {
      TransactionInfoEnhancedSendVerbose(
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
      TransactionInfoIssuanceVerbose(
        unpackedData: IssuanceUnpackedVerbose unpacked
      ) =>
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
  Future<List<TransactionInfoVerbose>> getAllByAddressesVerbose(
      List<String> addresses) async {
    final transactions = await transactionDao.getAllBySources(addresses);

    return transactions.map((tx) {
      api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
          ? api.TransactionUnpackedVerbose.fromJson(
              jsonDecode(tx.unpackedData!))
          : null;

      TransactionUnpackedVerbose? unpacked =
          unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;

      return switch (unpacked) {
        EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSendVerbose(
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
        IssuanceUnpackedVerbose() => TransactionInfoIssuanceVerbose(
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
        _ => TransactionInfoVerbose(
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
  Future<List<TransactionInfoVerbose>> getAllByAccountVerbose(
      String accountUuid) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
    final transactions = await transactionDao
        .getAllBySources(addresses.map((e) => e.address).toList());

    return transactions.map((tx) {
      api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
          ? api.TransactionUnpackedVerbose.fromJson(
              jsonDecode(tx.unpackedData!))
          : null;

      TransactionUnpackedVerbose? unpacked =
          unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;

      return switch (unpacked) {
        EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSendVerbose(
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
        IssuanceUnpackedVerbose() => TransactionInfoIssuanceVerbose(
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
        _ => TransactionInfoVerbose(
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
  Future<List<TransactionInfoVerbose>> getAllByAccountAfterDateVerbose(
      String accountUuid, DateTime date) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
    final transactions = await transactionDao.getAllBySourcesAfterDate(
        addresses.map((e) => e.address).toList(), date);

    return transactions.map((tx) {
      // TODO: refactor
      api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
          ? api.TransactionUnpackedVerbose.fromJson(
              jsonDecode(tx.unpackedData!))
          : null;

      TransactionUnpackedVerbose? unpacked =
          unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;

      return switch (unpacked) {
        EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSendVerbose(
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
        IssuanceUnpackedVerbose() => TransactionInfoIssuanceVerbose(
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
        _ => TransactionInfoVerbose(
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
