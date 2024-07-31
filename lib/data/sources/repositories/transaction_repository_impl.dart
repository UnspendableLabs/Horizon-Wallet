import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import "package:horizon/data/models/unpacked.dart" as unpacked_model;

// TODO: move to shared
class UnpackedMapper {
  static TransactionUnpacked toDomain(unpacked_model.TransactionUnpacked u) {
    print("u ${u}");
    print("u.messageType ${u.messageType}");
    switch (u.messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedMapper.toDomain(
            u as unpacked_model.EnhancedSendUnpacked);
      default:
        return TransactionUnpacked(
          messageType: u.messageType,
        );
    }
  }
}

class EnhancedSendUnpackedMapper {
  static EnhancedSendUnpacked toDomain(unpacked_model.EnhancedSendUnpacked u) {
    return EnhancedSendUnpacked(
      asset: u.asset,
      quantity: u.quantity,
      address: u.address,
      memo: u.memo,
    );
  }
}

class TransactionRepositoryImpl implements TransactionRepository {
  final V2Api api;
  final AddressRepository addressRepository;

  TransactionRepositoryImpl(
      {required this.api, required this.addressRepository});

  @override
  Future<TransactionUnpacked> unpack(String hex) async {
    final response = await api.unpackTransaction(hex);
    // todo: check for errors
    if (response.result == null) {
      throw Exception("Failed to unpack transaction: $hex");
    }

    Map<String, dynamic> unpacked = response.result!.toJson();

    return UnpackedMapper.toDomain(
        unpacked_model.TransactionUnpacked.fromJson(unpacked));
  }

  @override
  Future<TransactionInfo> getInfo(String raw) async {
    final response = await api.getTransactionInfo(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    Info info = response.result!;

    print("info.unpackedData ${info.unpackedData!.toJson()}");

    TransactionUnpacked unpacked = UnpackedMapper.toDomain(
        unpacked_model.TransactionUnpacked.fromJson(
            info.unpackedData!.toJson()));

    // TODO: domain isn't being properly set here
    return TransactionInfo(
      hash: "",
      domain: TransactionInfoDomainLocal(raw: raw, submittedAt: DateTime.now()),
      source: info.source,
      destination: info.destination,
      btcAmount: info.btcAmount,
      fee: info.fee,
      data: info.data,
      unpackedData: unpacked,
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

    final response = await api.getTransactionsByAddressesVerbose(
        addressesParam, cursor, limit, unconfirmed);

    if (response.error != null) {
      throw Exception("Failed to get transactions by account: $accountUuid");
    }

    List<TransactionInfo> transactions = response.result!.map((tx) {
      Map<String, dynamic> json = tx.unpackedData.toJson();

      TransactionUnpacked unpacked = UnpackedMapper.toDomain(
          unpacked_model.TransactionUnpacked.fromJson(json));

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
