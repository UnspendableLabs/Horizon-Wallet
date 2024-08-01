import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
// import "package:horizon/data/models/unpacked.dart" as unpacked_model;

// TODO: move to sh
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


    return TransactionInfo(
      hash: "", // TODO: shouldn't be empty string
      domain: TransactionInfoDomainLocal(raw: raw, submittedAt: DateTime.now()),
      source: info.source,
      destination: info.destination,
      btcAmount: info.btcAmount,
      fee: info.fee,
      data: info.data,
      unpackedData: switch (info) {
        api.EnhancedSendInfo(unpackedData: var u) =>
          EnhancedSendUnpackedMapper.toDomain(u),
        _ => null,
      },
    );
  }

  @override
  Future<TransactionInfoVerbose> getInfoVerbose(String raw) async {

    print("getInfoVerbose");

    final response = await api_.getTransactionInfoVerbose(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }
    
    api.InfoVerbose info = response.result!;

    print("getInfoVerbose: ${info.toJson()}");

    return TransactionInfoVerbose(
      btcAmountNormalized: info.btcAmountNormalized,
      hash: "", // TODO: shouldn't be empty string
      domain: TransactionInfoDomainLocal(raw: raw, submittedAt: DateTime.now()),
      source: info.source,
      destination: info.destination,
      btcAmount: info.btcAmount,
      fee: info.fee,
      data: info.data,
      unpackedData: switch (info) {
        api.EnhancedSendInfoVerbose(unpackedData: var u) =>
          EnhancedSendUnpackedVerboseMapper.toDomain(u),
        _ => null,
      },
    );

  }

  @override
  Future<(List<TransactionInfo>, int? nextCursor, int? resultCount)>
      getByAccount({
    required String accountUuid,
    int? cursor,
    int? limit,
    bool? unconfirmed = false,
  }) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);

    final addressesParam =
        addresses.map((address) => address.address).join(',');

    final response = await api_.getTransactionsByAddressesVerbose(
        addressesParam, cursor, limit, unconfirmed);

    if (response.error != null) {
      throw Exception("Failed to get transactions by account: $accountUuid");
    }

    List<TransactionInfo> transactions = response.result!.map((tx) {
      TransactionUnpacked unpacked = UnpackedMapper.toDomain(tx.unpackedData);

      return TransactionInfo(
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
          unpackedData: unpacked);
    }).toList();

    int? nextCursor = response.nextCursor;

    return (transactions, nextCursor, response.resultCount);
  }
}
