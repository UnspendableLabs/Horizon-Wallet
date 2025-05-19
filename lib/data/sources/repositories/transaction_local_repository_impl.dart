import "dart:convert";

import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import "package:horizon/data/sources/local/dao/transactions_dao.dart";
import "package:horizon/data/models/transaction.dart";
import 'package:horizon/data/models/transaction_unpacked.dart';

class TransactionLocalRepositoryImpl implements TransactionLocalRepository {
  final TransactionsDao transactionDao;

  TransactionLocalRepositoryImpl({
    required this.transactionDao,
  });

  @override
  Future<void> delete(String txHash) async {
    await transactionDao.deleteByHash(txHash);
  }

  @override
  Future<void> deleteAllTransactions() async {
    await transactionDao.deleteAllTransactions();
  }

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
      TransactionInfoOrder(unpackedData: OrderUnpacked unpacked) => jsonEncode({
          "message_type": "order",
          "message_data": {
            "give_asset": unpacked.giveAsset,
            "give_quantity": unpacked.giveQuantity,
            "get_asset": unpacked.getAsset,
            "get_quantity": unpacked.getQuantity,
            "expiration": unpacked.expiration,
            "fee_required": unpacked.feeRequired,
            "status": unpacked.status,
            "give_quantity_normalized": unpacked.giveQuantityNormalized,
            "get_quantity_normalized": unpacked.getQuantityNormalized,
            "fee_required_normalized": unpacked.feeRequiredNormalized,
          }
        }),
      TransactionInfoCancel(unpackedData: CancelUnpacked unpacked) =>
        jsonEncode({
          "message_type": "cancel",
          "message_data": {
            "offer_hash": unpacked.orderHash,
            "status": unpacked.status,
          }
        }),
      TransactionInfoAttach(unpackedData: AttachUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "attach",
          "message_data": {
            "asset": unpacked.asset,
            "quantity_normalized": unpacked.quantityNormalized,
            "destination_vout": unpacked.destinationVout,
          },
        }),
      TransactionInfoDetach(unpackedData: DetachUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "detach",
          "message_data": {
            "destination": unpacked.destination,
          },
        }),
      TransactionInfoMoveToUtxo() => jsonEncode({
          "message_data": {},
        }),
      TransactionInfoMpmaSend(unpackedData: MpmaSendUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "mpma_send",
          "message_data": unpacked.messageData
              .map((d) => {
                    "asset": d.asset,
                    "destination": d.destination,
                    "quantity": d.quantity,
                    "memo": d.memo,
                    "memo_is_hex": d.memoIsHex,
                    "quantity_normalized": d.quantityNormalized,
                  })
              .toList(),
        }),
      TransactionInfoAssetDestruction(
        unpackedData: AssetDestructionUnpackedVerbose unpacked
      ) =>
        jsonEncode({
          "message_type": "destroy",
          "message_data": {
            "asset": unpacked.asset,
            "quantity_normalized": unpacked.quantityNormalized,
            "tag": unpacked.tag,
            "quantity": unpacked.quantity,
            // "asset_info": unpacked.assetInfo,
          }
        }),
      TransactionInfoAssetDividend(
        unpackedData: AssetDividendUnpackedVerbose unpacked
      ) =>
        jsonEncode({
          "message_type": "dividend",
          "message_data": {
            "asset": unpacked.asset,
            "quantity_per_unit": unpacked.quantityPerUnit,
            "dividend_asset": unpacked.dividendAsset,
            "status": unpacked.status,
          }
        }),
      TransactionInfoSweep(unpackedData: SweepUnpackedVerbose unpacked) =>
        jsonEncode({
          "message_type": "sweep",
          "message_data": {
            "destination": unpacked.destination,
            "flags": unpacked.flags,
            "memo": unpacked.memo,
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

      if (unpacked == null) {
        return TransactionInfoMoveToUtxo(
          btcAmountNormalized: "", // TODO: fix this
          hash: tx.hash,
          source: tx.source,
          destination: tx.destination,
          btcAmount: tx.btcAmount,
          fee: tx.fee,
          data: tx.data,
          domain: TransactionInfoDomainLocal(
              raw: tx.raw, submittedAt: tx.submittedAt),
        );
      }

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
        OrderUnpacked() => TransactionInfoOrder(
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
        CancelUnpacked() => TransactionInfoCancel(
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
        AttachUnpackedVerbose() => TransactionInfoAttach(
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
        DetachUnpackedVerbose() => TransactionInfoDetach(
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
        MoveToUtxoUnpackedVerbose() => TransactionInfoMoveToUtxo(
            btcAmountNormalized: "", // TODO: fix this
            hash: tx.hash,
            source: tx.source,
            destination: tx.destination,
            btcAmount: tx.btcAmount,
            fee: tx.fee,
            data: tx.data,
            domain: TransactionInfoDomainLocal(
                raw: tx.raw, submittedAt: tx.submittedAt),
          ),
        MpmaSendUnpackedVerbose() => TransactionInfoMpmaSend(
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
        AssetDestructionUnpackedVerbose() => TransactionInfoAssetDestruction(
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
        AssetDividendUnpackedVerbose() => TransactionInfoAssetDividend(
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
        SweepUnpackedVerbose() => TransactionInfoSweep(
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

  // @override
  // Future<List<TransactionInfo>> getAllByAccount(String accountUuid) async {
  //   // TODO: this will fail, we should be using addressv2
  //   final addresses = await addressRepository.getAllByAccountUuid(accountUuid);
  //
  //   final transactions = await transactionDao
  //       .getAllBySources(addresses.map((e) => e.address).toList());
  //
  //   return transactions.map((tx) {
  //     api.TransactionUnpackedVerbose? unpacked_ = tx.unpackedData != null
  //         ? api.TransactionUnpackedVerbose.fromJson(
  //             jsonDecode(tx.unpackedData!))
  //         : null;
  //
  //     TransactionUnpacked? unpacked =
  //         unpacked_ != null ? UnpackedVerboseMapper.toDomain(unpacked_) : null;
  //
  //     return switch (unpacked) {
  //       EnhancedSendUnpackedVerbose() => TransactionInfoEnhancedSend(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       IssuanceUnpackedVerbose() => TransactionInfoIssuance(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       DispenserUnpackedVerbose() => TransactionInfoDispenser(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       DispenseUnpackedVerbose() => TransactionInfoDispense(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       FairmintUnpackedVerbose() => TransactionInfoFairmint(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       OrderUnpacked() => TransactionInfoOrder(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       CancelUnpacked() => TransactionInfoCancel(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       AttachUnpackedVerbose() => TransactionInfoAttach(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       DetachUnpackedVerbose() => TransactionInfoDetach(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       MoveToUtxoUnpackedVerbose() => TransactionInfoMoveToUtxo(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //         ),
  //       MpmaSendUnpackedVerbose() => TransactionInfoMpmaSend(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       AssetDestructionUnpackedVerbose() => TransactionInfoAssetDestruction(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       AssetDividendUnpackedVerbose() => TransactionInfoAssetDividend(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       SweepUnpackedVerbose() => TransactionInfoSweep(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //           unpackedData: unpacked),
  //       _ => TransactionInfo(
  //           btcAmountNormalized: "", // TODO: fix this
  //           hash: tx.hash,
  //           source: tx.source,
  //           destination: tx.destination,
  //           btcAmount: tx.btcAmount,
  //           fee: tx.fee,
  //           data: tx.data,
  //           domain: TransactionInfoDomainLocal(
  //               raw: tx.raw, submittedAt: tx.submittedAt),
  //         )
  //     };
  //   }).toList();
  // }
}
