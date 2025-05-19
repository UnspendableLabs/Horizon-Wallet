import 'package:horizon/data/sources/network/api/v2_api.dart';
import 'package:horizon/domain/entities/asset_info.dart' as asset_entity;
import 'package:horizon/domain/entities/issuance.dart' as issuance_entity;
import 'package:horizon/domain/entities/send.dart' as send_entity;
import 'package:horizon/domain/entities/transaction.dart' as transaction_entity;
import 'package:horizon/domain/entities/http_config.dart';

import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/data/sources/network/counterparty_client_factory.dart';

class AddressTxRepositoryImpl extends AddressTxRepository {
  // final V2Api api;
  // AddressTxRepositoryImpl({required this.api});

  final CounterpartyClientFactory counterpartyClientFactory;

  AddressTxRepositoryImpl({
    required this.counterpartyClientFactory,
  });

  @override
  Future<List<send_entity.Send>> getSendsByAddress(
      String address, HttpConfig httpConfig) async {
    Response<List<Send>> response = await counterpartyClientFactory
        .getClient(httpConfig)
        .getSendsByAddress(address, true, 10);
    final List<send_entity.Send> sends = [];

    for (var send in response.result ?? []) {
      sends.add(send_entity.Send(
          asset: send.asset,
          quantity: send.quantity,
          status: send.status,
          txIndex: send.txIndex,
          txHash: send.txHash,
          blockIndex: send.blockIndex,
          source: send.source,
          destination: send.destination,
          msgIndex: send.msgIndex,
          memo: send.memo,
          assetInfo: asset_entity.AssetInfo(
            assetLongname: send.assetInfo.assetLongname,
            description: send.assetInfo.description,
            divisible: send.assetInfo.divisible,
            locked: send.assetInfo.locked,
          ),
          // locked: send.assetInfo.locked,
          // issuer: send.assetInfo.issuer),
          quantityNormalized: send.quantityNormalized));
    }

    return sends;
  }

  @override
  Future<List<issuance_entity.Issuance>> getIssuancesByAddress(
      String address, HttpConfig httpConfig) async {
    Response<List<Issuance>> response = await counterpartyClientFactory
        .getClient(httpConfig)
        .getIssuancesByAddress(address, true, 10);
    final List<issuance_entity.Issuance> issuances = [];

    for (var issuance in response.result ?? []) {
      issuances.add(issuance_entity.Issuance(
          txIndex: issuance.txIndex,
          txHash: issuance.txHash,
          msgIndex: issuance.msgIndex,
          blockIndex: issuance.blockIndex,
          asset: issuance.asset,
          quantity: issuance.quantity,
          divisible: issuance.divisible,
          source: issuance.source,
          issuer: issuance.issuer,
          transfer: issuance.transfer,
          callable: issuance.callable,
          callDate: issuance.callDate,
          callPrice: issuance.callPrice,
          description: issuance.description,
          feePaid: issuance.feePaid,
          locked: issuance.locked,
          status: issuance.status,
          reset: issuance.reset));
    }

    return issuances;
  }

  @override
  Future<List<transaction_entity.Transaction>> getTransactionsByAddress(
      String address, HttpConfig httpConfig) async {
    Response<List<Transaction>> response = await counterpartyClientFactory
        .getClient(httpConfig)
        .getTransactionsByAddress(address, true, 10);

    List<transaction_entity.Transaction> transactions = [];

    for (var transaction in response.result ?? []) {
      transactions.add(transaction_entity.Transaction(
          txHash: transaction.txHash,
          txIndex: transaction.txIndex,
          blockIndex: transaction.blockIndex,
          blockHash: transaction.blockHash,
          blockTime: transaction.blockTime,
          source: transaction.source,
          destination: transaction.destination,
          btcAmount: transaction.btcAmount,
          fee: transaction.fee,
          data: transaction.data,
          supported: transaction.supported));
    }

    return transactions;
  }
}
