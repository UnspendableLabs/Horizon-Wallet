import 'package:horizon/common/format.dart';
import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/data/models/event.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';

class StateMapper {
  static EventState getVerbose(api.VerboseEvent apiEvent) {
    return apiEvent.blockIndex != null
        ? EventStateConfirmed(
            blockHeight: apiEvent.blockIndex!, blockTime: apiEvent.blockTime)
        : EventStateMempool();
  }
}

class VerboseEventMapper {
  final BitcoinRepository bitcoinRepository;
  VerboseEventMapper({required this.bitcoinRepository});

  Future<VerboseEvent> toDomain(
      api.VerboseEvent apiEvent, String currentAddress) async {
    switch (apiEvent.event) {
      case 'ENHANCED_SEND':
        return VerboseEnhancedSendEventMapper.toDomain(
            apiEvent as api.VerboseEnhancedSendEvent);
      case 'CREDIT':
        return VerboseCreditEventMapper.toDomain(
            apiEvent as api.VerboseCreditEvent);
      case 'DEBIT':
        return VerboseDebitEventMapper.toDomain(
            apiEvent as api.VerboseDebitEvent);
      case "DISPENSE":
        return VerboseDispenseEventMapper.toDomain(
            apiEvent as api.VerboseDispenseEvent);
      case 'ASSET_ISSUANCE':
        return VerboseAssetIssuanceEventMapper.toDomain(
            apiEvent as api.VerboseAssetIssuanceEvent);
      case 'OPEN_DISPENSER':
        return VerboseOpenDispenserEventMapper.toDomain(
            apiEvent as api.VerboseOpenDispenserEvent);
      case "REFILL_DISPENSER":
        return VerboseRefillDispenserEventMapper.toDomain(
            apiEvent as api.VerboseRefillDispenserEvent);
      case "DISPENSER_UPDATE":
        return VerboseDispenserUpdateEventMapper.toDomain(
            apiEvent as api.VerboseDispenserUpdateEvent);
      case "RESET_ISSUANCE":
        return VerboseResetIssuanceEventMapper.toDomain(
            apiEvent as api.VerboseResetIssuanceEvent);
      case "ASSET_CREATION":
        return VerboseAssetIssuanceEventMapper.toDomain(
            apiEvent as api.VerboseAssetIssuanceEvent);
      case "NEW_FAIRMINT":
        return VerboseNewFairmintEventMapper.toDomain(
            apiEvent as api.VerboseNewFairmintEvent);
      case "NEW_FAIRMINTER":
        return VerboseNewFairminterEventMapper.toDomain(
            apiEvent as api.VerboseNewFairminterEvent);
      case "OPEN_ORDER":
        return VerboseOpenOrderEventMapper.toDomain(
            apiEvent as api.VerboseOpenOrderEvent);
      case "ORDER_MATCH":
        return VerboseOrderMatchEventMapper.toDomain(
            apiEvent as api.VerboseOrderMatchEvent);
      case "ORDER_UPDATE":
        return VerboseOrderUpdateEventMapper.toDomain(
            apiEvent as api.VerboseOrderUpdateEvent);
      case "ORDER_FILLED":
        return VerboseOrderFilledEventMapper.toDomain(
            apiEvent as api.VerboseOrderFilledEvent);
      case "CANCEL_ORDER":
        return VerboseCancelOrderEventMapper.toDomain(
            apiEvent as api.VerboseCancelOrderEvent);
      case "ORDER_EXPIRATION":
        return VerboseOrderExpirationEventMapper.toDomain(
            apiEvent as api.VerboseOrderExpirationEvent);
      case "ATTACH_TO_UTXO":
        return VerboseAttachToUtxoEventMapper.toDomain(
            apiEvent as api.VerboseAttachToUtxoEvent);
      case "DETACH_FROM_UTXO":
        return VerboseDetachFromUtxoEventMapper.toDomain(
            apiEvent as api.VerboseDetachFromUtxoEvent);
      case "UTXO_MOVE":
        // Both moves and swaps are captured by the UTXO_MOVE event
        // they can be distinguished by the input/output details of the transaction
        if (apiEvent.txHash == null) {
          return VerboseMoveToUtxoEventMapper.toDomain(
              apiEvent as api.VerboseMoveToUtxoEvent);
        }
        // final transactionInfo =
        //     await transactionInfoUseCase.call(apiEvent.txHash!);

        final BitcoinTx transactionInfo =
            await bitcoinRepository.getTransaction(apiEvent.txHash!).then(
                  (either) => either.fold(
                    (error) => throw Exception("GetTransactionInfo failure"),
                    (transactionInfo) => transactionInfo,
                  ),
                ); {}

        // atomic swaps will have at least 2 different input sources
        final isAtomicSwap = _isAtomicSwap(transactionInfo);

        // the btc that was swapped for the asset is held in the vout of the _other_ holder's address
        // the output with value 546 and 547 are the values for attaching utxos, so we exclude them
        if (isAtomicSwap) {
          final bitcoinSwapOutputs = transactionInfo.vout
              .where((output) =>
                  currentAddress != output.scriptpubkeyAddress &&
                  output.value != 546 &&
                  output.value != 547)
              .toList();
          if (bitcoinSwapOutputs.length > 1) {
            throw Exception("Atomic swap must have only one bitcoin output");
          }
          final bitcoinSwapOutput = bitcoinSwapOutputs.first;
          final bitcoinSwapAmount =
              satoshisToBtc(bitcoinSwapOutput.value).toStringAsFixed(8);

          // construct the swap from the move event
          return VerboseAtomicSwapEventMapper.toDomain(
              apiEvent as api.VerboseMoveToUtxoEvent, bitcoinSwapAmount);
        }

        return VerboseMoveToUtxoEventMapper.toDomain(
            apiEvent as api.VerboseMoveToUtxoEvent);

      // case 'NEW_TRANSACTION':
      //   return VerboseNewTransactionEventMapper.toDomain(
      //       apiEvent as api.VerboseNewTransactionEvent);
      default:
        return VerboseEvent(
          state: StateMapper.getVerbose(apiEvent),
          eventIndex: apiEvent.eventIndex,
          event: apiEvent.event,
          txHash: apiEvent.txHash,
          blockIndex: apiEvent.blockIndex,
          // confirmed: apiEvent.confirmed,
          blockTime: apiEvent.blockTime,
        );
    }
  }
}

class VerboseEnhancedSendEventMapper {
  static VerboseEnhancedSendEvent toDomain(
      api.VerboseEnhancedSendEvent apiEvent) {
    return VerboseEnhancedSendEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ENHANCED_SEND",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseEnhancedSendParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseEnhancedSendParamsMapper {
  static VerboseEnhancedSendParams toDomain(
      api.VerboseEnhancedSendParams apiParams) {
    return VerboseEnhancedSendParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      memo: apiParams.memo,
      quantity: apiParams.quantity,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      // assetInfo: AssetInfoMapper.toDomain(apiParams.assetInfo),
      quantityNormalized: apiParams.quantityNormalized,
      blockTime: apiParams.blockTime,
    );
  }
}

class VerboseCreditEventMapper {
  static VerboseCreditEvent toDomain(api.VerboseCreditEvent apiEvent) {
    return VerboseCreditEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "CREDIT",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseCreditParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseCreditParamsMapper {
  static VerboseCreditParams toDomain(api.VerboseCreditParams apiParams) {
    return VerboseCreditParams(
      address: apiParams.address,
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      callingFunction: apiParams.callingFunction,
      event: apiParams.event,
      quantity: apiParams.quantity,
      txIndex: apiParams.txIndex,
      blockTime: apiParams.blockTime,
      // assetInfo: AssetInfoMapper.toDomain(apiParams.assetInfo),
      quantityNormalized: apiParams.quantityNormalized,
    );
  }
}

class VerboseDebitEventMapper {
  static VerboseDebitEvent toDomain(api.VerboseDebitEvent apiEvent) {
    return VerboseDebitEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "DEBIT",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseDebitParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseDebitParamsMapper {
  static VerboseDebitParams toDomain(api.VerboseDebitParams apiParams) {
    return VerboseDebitParams(
      action: apiParams.action,
      address: apiParams.address,
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      event: apiParams.event,
      quantity: apiParams.quantity,
      txIndex: apiParams.txIndex,
      blockTime: apiParams.blockTime,
      // assetInfo: AssetInfoMapper.toDomain(apiParams.assetInfo),
      quantityNormalized: apiParams.quantityNormalized,
    );
  }
}

class VerboseNewFairminterEventMapper {
  static VerboseNewFairminterEvent toDomain(
      api.VerboseNewFairminterEvent apiEvent) {
    return VerboseNewFairminterEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "NEW_FAIRMINTER",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseNewFairminterParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseNewFairminterParamsMapper {
  static VerboseNewFairminterParams toDomain(
      api.VerboseNewFairminterParams apiParams) {
    return VerboseNewFairminterParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      assetLongname: apiParams.assetLongname,
      assetParent: apiParams.assetParent,
      burnPayment: apiParams.burnPayment,
      description: apiParams.description,
      divisible: apiParams.divisible,
      endBlock: apiParams.endBlock,
      hardCap: apiParams.hardCap,
      lockDescription: apiParams.lockDescription,
      lockQuantity: apiParams.lockQuantity,
      maxMintPerTx: apiParams.maxMintPerTx,
      mintedAssetCommissionInt: apiParams.mintedAssetCommissionInt,
      preMinted: apiParams.preMinted,
      premintQuantity: apiParams.premintQuantity,
      price: apiParams.price,
      quantityByPrice: apiParams.quantityByPrice,
      softCap: apiParams.softCap,
      softCapDeadlineBlock: apiParams.softCapDeadlineBlock,
      source: apiParams.source,
      startBlock: apiParams.startBlock,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      blockTime: apiParams.blockTime,
    );
  }
}

class VerboseNewFairmintEventMapper {
  static VerboseNewFairmintEvent toDomain(
      api.VerboseNewFairmintEvent apiEvent) {
    return VerboseNewFairmintEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "NEW_FAIRMINT",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseNewFairmintParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseNewFairmintParamsMapper {
  static VerboseNewFairmintParams toDomain(
      api.VerboseNewFairmintParams apiParams) {
    return VerboseNewFairmintParams(
      asset: apiParams.asset, // TODO: this is temporary hack
      blockIndex: apiParams.blockIndex,
      commission: apiParams.commission,
      earnQuantity: apiParams.earnQuantity,
      fairminterTxHash: apiParams.fairminterTxHash,
      paidQuantity: apiParams.paidQuantity,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      // assetInfo: AssetInfoMapper.toDomain(apiParams.assetInfo),
    );
  }
}

class VerboseAssetIssuanceEventMapper {
  static VerboseAssetIssuanceEvent toDomain(
      api.VerboseAssetIssuanceEvent apiEvent) {
    final x = VerboseAssetIssuanceEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ASSET_ISSUANCE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseAssetIssuanceParamsMapper.toDomain(apiEvent.params),
    );

    return x;
  }
}

class VerboseResetIssuanceEventMapper {
  static VerboseResetIssuanceEvent toDomain(
      api.VerboseResetIssuanceEvent apiEvent) {
    final x = VerboseResetIssuanceEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "RESET_ISSUANCE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseAssetIssuanceParamsMapper.toDomain(apiEvent.params),
    );

    return x;
  }
}

class VerboseAssetIssuanceParamsMapper {
  static VerboseAssetIssuanceParams toDomain(
      api.VerboseAssetIssuanceParams apiParams) {
    return VerboseAssetIssuanceParams(
      asset: apiParams.asset,
      assetLongname: apiParams.assetLongname,
      assetEvents: apiParams.assetEvents,
      // blockIndex: apiParams.blockIndex,
      // callDate: apiParams.callDate,
      // callPrice: apiParams.callPrice,
      // callable: apiParams.callable,
      // description: apiParams.description,
      // divisible: apiParams.divisible,
      // feePaid: apiParams.feePaid,
      // issuer: apiParams.issuer,
      // locked: apiParams.locked,
      quantity: apiParams.quantity,
      // reset: apiParams.reset,
      source: apiParams.source,
      status: EventStatusMapper.fromString(apiParams.status),
      transfer: apiParams.transfer,
      // txHash: apiParams.txHash,
      // txIndex: apiParams.txIndex,
      blockTime: apiParams.blockTime,
      quantityNormalized: apiParams.quantityNormalized,
      feePaidNormalized: apiParams.feePaidNormalized,
    );
  }
}

class VerboseDispenseEventMapper {
  static VerboseDispenseEvent toDomain(api.VerboseDispenseEvent apiEvent) {
    return VerboseDispenseEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "DISPENSE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseDispenseParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseDispenseParamsMapper {
  static VerboseDispenseParams toDomain(api.VerboseDispenseParams apiParams) {
    return VerboseDispenseParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      btcAmount: apiParams.btcAmount,
      destination: apiParams.destination,
      dispenseIndex: apiParams.dispenseIndex,
      dispenseQuantity: apiParams.dispenseQuantity,
      dispenserTxHash: apiParams.dispenserTxHash,
      source: apiParams.source,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      btcAmountNormalized: apiParams.btcAmountNormalized,
      dispenseQuantityNormalized: apiParams.dispenseQuantityNormalized,
    );
  }
}

// class NewTransactionEventMapper {
//   static NewTransactionEvent toDomain(api.NewTransactionEvent apiEvent) {
//     return NewTransactionEvent(
//       state: StateMapper.get(apiEvent),
//       event: "NEW_TRANSACTION",
//       eventIndex: apiEvent.eventIndex,
//       txHash: apiEvent.txHash,
//       blockIndex: apiEvent.blockIndex,
//       confirmed: apiEvent.confirmed,
//       params: NewTransactionParamsMapper.toDomain(apiEvent.params),
//     );
//   }
// }
//
// class NewTransactionParamsMapper {
//   static NewTransactionParams toDomain(api.NewTransactionParams apiParams) {
//     return NewTransactionParams(
//       blockHash: apiParams.blockHash,
//       blockIndex: apiParams.blockIndex,
//       blockTime: apiParams.blockTime,
//       btcAmount: apiParams.btcAmount,
//       data: apiParams.data,
//       destination: apiParams.destination,
//       fee: apiParams.fee,
//       source: apiParams.source,
//       txHash: apiParams.txHash,
//       txIndex: apiParams.txIndex,
//     );
//   }
// }

class VerboseNewTransactionEventMapper {
  static VerboseNewTransactionEvent toDomain(
      api.VerboseNewTransactionEvent apiEvent) {
    return VerboseNewTransactionEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "NEW_TRANSACTION",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      blockTime: apiEvent.blockTime,
      params: VerboseNewTransactionParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseNewTransactionParamsMapper {
  static VerboseNewTransactionParams toDomain(
      api.VerboseNewTransactionParams apiParams) {
    return VerboseNewTransactionParams(
      blockHash: apiParams.blockHash,
      blockIndex: apiParams.blockIndex,
      blockTime: apiParams.blockTime,
      btcAmount: apiParams.btcAmount,
      data: apiParams.data,
      destination: apiParams.destination,
      fee: apiParams.fee,
      source: apiParams.source,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      unpackedData: apiParams.unpackedData,
      btcAmountNormalized: apiParams.btcAmountNormalized,
    );
  }
}

class VerboseOpenDispenserEventMapper {
  static VerboseOpenDispenserEvent toDomain(
      api.VerboseOpenDispenserEvent apiEvent) {
    return VerboseOpenDispenserEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "OPEN_DISPENSER",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseOpenDispenserParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOpenDispenserParamsMapper {
  static VerboseOpenDispenserParams toDomain(
      api.VerboseOpenDispenserParams apiParams) {
    return VerboseOpenDispenserParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      escrowQuantity: apiParams.escrowQuantity,
      giveQuantity: apiParams.giveQuantity,
      giveRemaining: apiParams.giveRemaining,
      oracleAddress: apiParams.oracleAddress,
      origin: apiParams.origin,
      satoshirate: apiParams.satoshirate,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      // blockTime: apiParams.blockTime,
      giveQuantityNormalized: apiParams.giveQuantityNormalized,
      giveRemainingNormalized: apiParams.giveRemainingNormalized,
      escrowQuantityNormalized: apiParams.escrowQuantityNormalized,
      satoshirateNormalized: apiParams.satoshirateNormalized,
      // description: apiParams.description,
      // issuer: apiParams.issuer,
      // divisible: apiParams.divisible,
      // locked: apiParams.locked,
    );
  }
}

class VerboseDispenserUpdateEventMapper {
  static VerboseDispenserUpdateEvent toDomain(
      api.VerboseDispenserUpdateEvent apiEvent) {
    return VerboseDispenserUpdateEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "DISPENSER_UPDATE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseDispenserUpdateParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseDispenserUpdateParamsMapper {
  static VerboseDispenserUpdateParams toDomain(
      api.VerboseDispenserUpdateParams apiParams) {
    return VerboseDispenserUpdateParams(
      asset: apiParams.asset,
      closeBlockIndex: apiParams.closeBlockIndex,
      lastStatusTxHash: apiParams.lastStatusTxHash,
      lastStatusTxSource: apiParams.lastStatusTxSource,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      // assetInfo: AssetInfoMapper.toDomain(apiParams.assetInfo),
    );
  }
}

class VerboseRefillDispenserEventMapper {
  static VerboseRefillDispenserEvent toDomain(
      api.VerboseRefillDispenserEvent apiEvent) {
    return VerboseRefillDispenserEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "REFILL_DISPENSER",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseRefillDispenserParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseRefillDispenserParamsMapper {
  static VerboseRefillDispenserParams toDomain(
      api.VerboseRefillDispenserParams apiParams) {
    return VerboseRefillDispenserParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      dispenseQuantity: apiParams.dispenseQuantity,
      dispenserTxHash: apiParams.dispenserTxHash,
      source: apiParams.source,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      dispenseQuantityNormalized: apiParams.dispenseQuantityNormalized,
      // assetInfo: AssetInfoMapper.toDomain(
      //     apiParams.assetInfo), // Assuming AssetInfoMapper exists
    );
  }
}

class VerboseOpenOrderEventMapper {
  static VerboseOpenOrderEvent toDomain(api.VerboseOpenOrderEvent apiEvent) {
    return VerboseOpenOrderEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "OPEN_ORDER",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseOpenOrderParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOpenOrderParamsMapper {
  static VerboseOpenOrderParams toDomain(api.VerboseOpenOrderParams apiParams) {
    return VerboseOpenOrderParams(
      blockIndex: apiParams.blockIndex,
      expiration: apiParams.expiration,
      expireIndex: apiParams.expireIndex,
      feeProvided: apiParams.feeProvided,
      feeProvidedRemaining: apiParams.feeProvidedRemaining,
      feeRequired: apiParams.feeRequired,
      feeRequiredRemaining: apiParams.feeRequiredRemaining,
      getAsset: apiParams.getAsset,
      getQuantity: apiParams.getQuantity,
      getRemaining: apiParams.getRemaining,
      giveAsset: apiParams.giveAsset,
      giveQuantity: apiParams.giveQuantity,
      giveRemaining: apiParams.giveRemaining,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
      // blockTime: apiParams.blockTime,
      giveQuantityNormalized: apiParams.giveQuantityNormalized,
      getQuantityNormalized: apiParams.getQuantityNormalized,
      getRemainingNormalized: apiParams.getRemainingNormalized,
      giveRemainingNormalized: apiParams.giveRemainingNormalized,
      feeProvidedNormalized: apiParams.feeProvidedNormalized,
      feeRequiredNormalized: apiParams.feeRequiredNormalized,
      feeRequiredRemainingNormalized: apiParams.feeRequiredRemainingNormalized,
      feeProvidedRemainingNormalized: apiParams.feeProvidedRemainingNormalized,
    );
  }
}

class VerboseOrderMatchEventMapper {
  static VerboseOrderMatchEvent toDomain(api.VerboseOrderMatchEvent apiEvent) {
    return VerboseOrderMatchEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ORDER_MATCH",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseOrderMatchParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOrderMatchParamsMapper {
  static VerboseOrderMatchParams toDomain(
      api.VerboseOrderMatchParams apiParams) {
    return VerboseOrderMatchParams(
      backwardAsset: apiParams.backwardAsset,
      backwardQuantity: apiParams.backwardQuantity,
      blockIndex: apiParams.blockIndex,
      feePaid: apiParams.feePaid,
      forwardAsset: apiParams.forwardAsset,
      forwardQuantity: apiParams.forwardQuantity,
      id: apiParams.id,
      matchExpireIndex: apiParams.matchExpireIndex,
      status: apiParams.status,
      tx0Address: apiParams.tx0Address,
      tx0BlockIndex: apiParams.tx0BlockIndex,
      tx0Expiration: apiParams.tx0Expiration,
      tx0Hash: apiParams.tx0Hash,
      tx0Index: apiParams.tx0Index,
      tx1Address: apiParams.tx1Address,
      tx1BlockIndex: apiParams.tx1BlockIndex,
      tx1Expiration: apiParams.tx1Expiration,
      tx1Hash: apiParams.tx1Hash,
      tx1Index: apiParams.tx1Index,
      forwardQuantityNormalized: apiParams.forwardQuantityNormalized,
      backwardQuantityNormalized: apiParams.backwardQuantityNormalized,
      feePaidNormalized: apiParams.feePaidNormalized,
    );
  }
}

class VerboseOrderUpdateEventMapper {
  static VerboseOrderUpdateEvent toDomain(
      api.VerboseOrderUpdateEvent apiEvent) {
    return VerboseOrderUpdateEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ORDER_UPDATE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      // params: VerboseOrderUpdateParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOrderUpdateParamsMapper {
  static VerboseOrderUpdateParams toDomain(
      api.VerboseOrderUpdateParams apiParams) {
    return VerboseOrderUpdateParams(
      feeProvidedRemaining: apiParams.feeProvidedRemaining,
      feeRequiredRemaining: apiParams.feeRequiredRemaining,
      getRemaining: apiParams.getRemaining,
      giveRemaining: apiParams.giveRemaining,
      status: apiParams.status,
      txHash: apiParams.txHash,
      feeProvidedRemainingNormalized: apiParams.feeProvidedRemainingNormalized,
      feeRequiredRemainingNormalized: apiParams.feeRequiredRemainingNormalized,
    );
  }
}

class VerboseOrderFilledEventMapper {
  static VerboseOrderFilledEvent toDomain(
      api.VerboseOrderFilledEvent apiEvent) {
    return VerboseOrderFilledEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ORDER_FILLED",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseOrderFilledParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOrderFilledParamsMapper {
  static VerboseOrderFilledParams toDomain(
      api.VerboseOrderFilledParams apiParams) {
    return VerboseOrderFilledParams(
      status: apiParams.status,
      txHash: apiParams.txHash,
    );
  }
}

class VerboseCancelOrderEventMapper {
  static VerboseCancelOrderEvent toDomain(
      api.VerboseCancelOrderEvent apiEvent) {
    return VerboseCancelOrderEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "CANCEL_ORDER",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseCancelOrderParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseCancelOrderParamsMapper {
  static VerboseCancelOrderParams toDomain(
      api.VerboseCancelOrderParams apiParams) {
    return VerboseCancelOrderParams(
      blockIndex: apiParams.blockIndex,
      offerHash: apiParams.offerHash,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
    );
  }
}

class VerboseOrderExpirationEventMapper {
  static VerboseOrderExpirationEvent toDomain(
      api.VerboseOrderExpirationEvent apiEvent) {
    return VerboseOrderExpirationEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ORDER_EXPIRATION",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseOrderExpirationParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseOrderExpirationParamsMapper {
  static VerboseOrderExpirationParams toDomain(
      api.VerboseOrderExpirationParams apiParams) {
    return VerboseOrderExpirationParams(
      blockIndex: apiParams.blockIndex,
      orderHash: apiParams.orderHash,
      source: apiParams.source,
      blockTime: apiParams.blockTime,
    );
  }
}

class VerboseAttachToUtxoParamsMapper {
  static VerboseAttachToUtxoParams toDomain(
      api.VerboseAttachToUtxoParams apiParams) {
    return VerboseAttachToUtxoParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      feePaid: apiParams.feePaid,
      quantityNormalized: apiParams.quantityNormalized,
      feePaidNormalized: apiParams.feePaidNormalized,
    );
  }
}

class VerboseAttachToUtxoEventMapper {
  static VerboseAttachToUtxoEvent toDomain(
      api.VerboseAttachToUtxoEvent apiEvent) {
    return VerboseAttachToUtxoEvent(
      state: StateMapper.getVerbose(apiEvent),
      eventIndex: apiEvent.eventIndex,
      event: apiEvent.event,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseAttachToUtxoParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseMoveToUtxoParamsMapper {
  static VerboseMoveToUtxoParams toDomain(
      api.VerboseMoveToUtxoParams apiParams) {
    return VerboseMoveToUtxoParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      quantityNormalized: apiParams.quantityNormalized,
    );
  }
}

class AtomicSwapParamsMapper {
  static AtomicSwapParams toDomain(
      api.VerboseMoveToUtxoParams apiParams, String bitcoinSwapAmount) {
    return AtomicSwapParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      quantityNormalized: apiParams.quantityNormalized,
      bitcoinSwapAmount: bitcoinSwapAmount,
    );
  }
}

class VerboseDetachFromUtxoParamsMapper {
  static VerboseDetachFromUtxoParams toDomain(
      api.VerboseDetachFromUtxoParams apiParams) {
    return VerboseDetachFromUtxoParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      feePaid: apiParams.feePaid,
      quantityNormalized: apiParams.quantityNormalized,
      feePaidNormalized: apiParams.feePaidNormalized,
    );
  }
}

class VerboseDetachFromUtxoEventMapper {
  static VerboseDetachFromUtxoEvent toDomain(
      api.VerboseDetachFromUtxoEvent apiEvent) {
    return VerboseDetachFromUtxoEvent(
      state: StateMapper.getVerbose(apiEvent),
      eventIndex: apiEvent.eventIndex,
      event: apiEvent.event,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseDetachFromUtxoParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseMoveToUtxoEventMapper {
  static VerboseMoveToUtxoEvent toDomain(api.VerboseMoveToUtxoEvent apiEvent) {
    return VerboseMoveToUtxoEvent(
      state: StateMapper.getVerbose(apiEvent),
      eventIndex: apiEvent.eventIndex,
      event: apiEvent.event,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params: VerboseMoveToUtxoParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class VerboseAtomicSwapEventMapper {
  static AtomicSwapEvent toDomain(
      api.VerboseMoveToUtxoEvent apiEvent, String bitcoinSwapAmount) {
    return AtomicSwapEvent(
      state: StateMapper.getVerbose(apiEvent),
      eventIndex: apiEvent.eventIndex,
      event: apiEvent.event,
      txHash: apiEvent.txHash,
      blockIndex: apiEvent.blockIndex,
      blockTime: apiEvent.blockTime,
      params:
          AtomicSwapParamsMapper.toDomain(apiEvent.params, bitcoinSwapAmount),
    );
  }
}

class EventsRepositoryImpl implements EventsRepository {
  final api.V2Api api_;
  final BitcoinRepository bitcoinRepository;
  EventsRepositoryImpl({
    required this.api_,
    required this.bitcoinRepository,
  });

  @override
  Future<
      (
        List<VerboseEvent>,
        cursor_entity.Cursor? nextCursor,
        int? resultCount
      )> getByAddressVerbose({
    required String address,
    cursor_entity.Cursor? cursor,
    int? limit,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    List<VerboseEvent> events = [];

    final addressesParam = address;

    final whitelist_ = whitelist?.join(",");

    final response = await api_.getEventsByAddressesVerbose(addressesParam,
        cursor_model.CursorMapper.toData(cursor), limit, whitelist_);

    if (response.error != null) {
      throw Exception("Error getting events by addresses: ${response.error}");
    }

    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);

    List<VerboseEvent> events_ =
        await Future.wait(response.result!.map((event) async {
      return await VerboseEventMapper(bitcoinRepository: bitcoinRepository)
          .toDomain(event, address);
    }).toList());

    events.addAll(events_);

    return (events, nextCursor, response.resultCount);
  }

  @override
  Future<List<VerboseEvent>> getAllByAddressVerbose({
    required String address,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addresses = [address];
    final List<VerboseEvent> events = [];

    if (unconfirmed == true) {
      final mempoolEvents =
          await _getAllMempoolVerboseEventsForAddress(address, whitelist);
      events.addAll(mempoolEvents);
    }

    final futures = addresses.map((address) =>
        _getAllVerboseEventsForAddress(address, unconfirmed, whitelist));

    final eventResults = await Future.wait(futures);
    final allEvents = eventResults.expand((events) => events).toList();
    events.addAll(allEvents);

    return events;
  }

  Future<List<VerboseEvent>> _getAllVerboseEventsForAddress(
      String address, bool? unconfirmed, List<String>? whitelist) async {
    final allEvents = <VerboseEvent>[];
    Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (events, nextCursor, _) = await getByAddressVerbose(
        address: address,
        limit: 1000,
        cursor: cursor,
        unconfirmed: unconfirmed,
        whitelist: whitelist,
      );

      allEvents.addAll(events);

      if (nextCursor == null) {
        hasMore = false;
      } else {
        cursor = nextCursor;
      }
    }

    return allEvents;
  }

  @override
  Future<
      (
        List<VerboseEvent>,
        cursor_entity.Cursor? nextCursor,
        int? resultCount
      )> getMempoolEventsByAddressVerbose({
    required String address,
    cursor_entity.Cursor? cursor,
    int? limit,
    List<String>? whitelist,
  }) async {
    final addressesParam = address;

    final whitelist_ = whitelist?.join(",");

    final response = await api_.getMempoolEventsByAddressesVerbose(
        addressesParam,
        cursor_model.CursorMapper.toData(cursor),
        limit,
        whitelist_);

    if (response.error != null) {
      throw Exception(
          "Error getting mempool events by addresses: ${response.error}");
    }
    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);
    List<VerboseEvent> events =
        await Future.wait(response.result!.map((event) async {
      return await VerboseEventMapper(bitcoinRepository: bitcoinRepository)
          .toDomain(event, address);
    }).toList());

    return (events, nextCursor, response.resultCount);
  }

  Future<List<VerboseEvent>> _getAllMempoolVerboseEventsForAddress(
      String address, List<String>? whitelist) async {
    final allEvents = <VerboseEvent>[];
    Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (events, nextCursor, _) = await getMempoolEventsByAddressVerbose(
        address: address,
        limit: 1000,
        cursor: cursor,
      );
      final whitelistedEvents = events
          .where((event) => whitelist?.contains(event.event) ?? true)
          .toList();

      allEvents.addAll(whitelistedEvents);

      if (nextCursor == null) {
        hasMore = false;
      } else {
        cursor = nextCursor;
      }
    }

    return allEvents;
  }
}

bool _isAtomicSwap(BitcoinTx transactionInfo) {
  // if a move has multiple inputs, then we can assume it is a swap
  // this will cover most cases, except those were an address swaps with itself
  // opting for simiplicity now, and we can improve later if needed
  return transactionInfo.vin
          .map((input) => input.prevout?.scriptpubkeyAddress)
          .where((address) => address != null)
          .toSet()
          .length >
      1;
}
