import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';

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

    Unpack unpacked = response.result!;

    return TransactionUnpacked(
      messageType: unpacked.messageType,
      messageData: unpacked.toJson(),
    );
  }

  @override
  Future<TransactionInfo> getInfo(String raw) async {
    final response = await api.getTransactionInfo(raw);

    if (response.result == null) {
      throw Exception("Failed to get transaction info: $raw");
    }

    Info info = response.result!;

    Unpack unpacked = info.unpackedData;

    // TODO: domain isn't being properly set here
    return TransactionInfo(
      hash: "",
      domain: TransactionInfoDomainLocal(raw: raw, submittedAt: DateTime.now()),
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
  Future<(List<TransactionInfo>, int? nextCursor)> getByAccount({
    required String accountUuid,
    int? cursor,
    int? limit,
    bool? unconfirmed = false,
  }) async {
    final addresses = await addressRepository.getAllByAccountUuid(accountUuid);

    final addressesParam =
        addresses.map((address) => address.address).join(',');

    final response = await api.getTransactionsByAddressesVerbose(
        addressesParam, cursor, unconfirmed);

    if (response.error != null) {
      throw Exception("Failed to get transactions by account: $accountUuid");
    }

    List<TransactionInfo> transactions = response.result!.map((tx) {
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
        unpackedData: TransactionUnpacked(
            messageType: tx.unpackedData.messageType,
            messageData: tx.unpackedData.messageData),
      );
    }).toList();

    int? nextCursor = response.nextCursor;

    return (transactions, nextCursor);
  }
}
