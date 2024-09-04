import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
// import "package:horizon/data/models/unpacked.dart" as unpacked_model;

// TODO: move to sh
class UnpackedMapper {
  static TransactionUnpacked toDomain(api.TransactionUnpacked u) {
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedMapper.toDomain(
            u as api.EnhancedSendUnpacked);
      case "issuance":
        return IssuanceUnpackedMapper.toDomain(u as api.IssuanceUnpacked);
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

class IssuanceUnpackedMapper {
  static IssuanceUnpacked toDomain(api.IssuanceUnpacked u) {
    return IssuanceUnpacked(
      assetId: u.assetId,
      asset: u.asset,
      subassetLongname: u.subassetLongname,
      quantity: u.quantity,
      divisible: u.divisible,
      lock: u.lock,
      reset: u.reset,
      callable: u.callable,
      callDate: u.callDate,
      callPrice: u.callPrice,
      description: u.description,
      status: u.status,
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

class IssuanceUnpackedVerboseMapper {
  static IssuanceUnpackedVerbose toDomain(api.IssuanceUnpackedVerbose u) {
    return IssuanceUnpackedVerbose(
      assetId: u.assetId,
      asset: u.asset,
      subassetLongname: u.subassetLongname,
      quantity: u.quantity,
      divisible: u.divisible,
      lock: u.lock,
      reset: u.reset,
      callable: u.callable,
      callDate: u.callDate,
      callPrice: u.callPrice,
      description: u.description,
      status: u.status,
      quantityNormalized: u.quantityNormalized,
    );
  }
}

class InfoMapper {
  static TransactionInfo toDomain(api.Info info) {
    return switch (info) {
      api.EnhancedSendInfo(unpackedData: var u) => TransactionInfoEnhancedSend(
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: EnhancedSendUnpackedMapper.toDomain(u),
        ),
      api.IssuanceInfo(unpackedData: var u) => TransactionInfoIssuance(
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: IssuanceUnpackedMapper.toDomain(u)),
      _ => TransactionInfo(
          hash: "",
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
        )
    };
  }
}

class InfoVerboseMapper {
  static TransactionInfoVerbose toDomain(api.InfoVerbose info) {
    return switch (info) {
      api.EnhancedSendInfoVerbose(unpackedData: var u) =>
        TransactionInfoEnhancedSendVerbose(
          btcAmountNormalized: info.btcAmountNormalized,
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: EnhancedSendUnpackedVerboseMapper.toDomain(u),
        ),
      api.IssuanceInfoVerbose(unpackedData: var u) =>
        TransactionInfoIssuanceVerbose(
          btcAmountNormalized: info.btcAmountNormalized,
          hash: "",
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          unpackedData: IssuanceUnpackedVerboseMapper.toDomain(u),
        ),
      _ => TransactionInfoVerbose(
          btcAmountNormalized: info.btcAmountNormalized,
          hash: "",
          domain: TransactionInfoDomainLocal(
              raw: "", submittedAt: DateTime.now()), // TODO: this is wrong
          source: info.source,
          destination: info.destination,
          btcAmount: info.btcAmount,
          fee: info.fee,
          data: info.data,
        )
    };
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  final api.V2Api api_;
  final AddressRepository addressRepository;

  TransactionRepositoryImpl(
      {required this.api_, required this.addressRepository});

  @override
  Future<TransactionUnpacked> unpack(String hex) async {
    final response = await api_.unpackTransaction(hex);
    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    return UnpackedMapper.toDomain(response.result!);
  }

  @override
  Future<TransactionUnpackedVerbose> unpackVerbose(String hex) async {
    final response = await api_.unpackTransactionVerbose(hex);

    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    return UnpackedVerboseMapper.toDomain(response.result!);
  }

  @override
  Future<TransactionInfo> getInfo(String raw) async {
    final response = await api_.getTransactionInfo(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    api.Info info = response.result!;

    return InfoMapper.toDomain(info);
  }

  @override
  Future<TransactionInfoVerbose> getInfoVerbose(String raw) async {
    final response = await api_.getTransactionInfoVerbose(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    api.InfoVerbose info = response.result!;

    return InfoVerboseMapper.toDomain(info);
  }

  @override
  Future<
      (
        List<TransactionInfoVerbose>,
        cursor_entity.Cursor? nextCursor,
        int? resultCount
      )> getByAccountVerbose({
    required String accountUuid,
    cursor_entity.Cursor? cursor,
    int? limit,
    bool? unconfirmed = false,
  }) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);

    final addressesParam =
        addresses.map((address) => address.address).join(',');

    final response = await api_.getTransactionsByAddressesVerbose(
        addressesParam,
        cursor_model.CursorMapper.toData(cursor),
        limit,
        unconfirmed);

    if (response.error != null) {
      throw Exception("Failed to get transactions by account: $accountUuid");
    }

    List<TransactionInfoVerbose> transactions = response.result!.map((tx) {
      final messageType = tx.unpackedData.messageType;

      return switch (messageType) {
        "enhanced_send" => TransactionInfoEnhancedSendVerbose(
            btcAmountNormalized: tx.btcAmountNormalized,
            hash: tx.txHash,
            domain: tx.confirmed
                ? TransactionInfoDomainConfirmed(
                    blockHeight: tx.blockIndex!, blockTime: tx.blockTime!)
                : TransactionInfoDomainMempool(),
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            unpackedData: EnhancedSendUnpackedVerboseMapper.toDomain(
                tx.unpackedData as api.EnhancedSendUnpackedVerbose)),
        _ => TransactionInfoVerbose(
            btcAmountNormalized: tx.btcAmountNormalized,
            hash: tx.txHash,
            domain: tx.confirmed
                ? TransactionInfoDomainConfirmed(
                    blockHeight: tx.blockIndex!, blockTime: tx.blockTime!)
                : TransactionInfoDomainMempool(),
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
          ),
      };
    }).toList();
    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);
    return (transactions, nextCursor, response.resultCount);
  }
}
