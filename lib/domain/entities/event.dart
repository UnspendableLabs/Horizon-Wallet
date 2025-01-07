import "package:equatable/equatable.dart";

sealed class EventStatus {}

class EventStatusValid extends EventStatus {}

class EventStatusInvalid extends EventStatus {
  final String reason;
  EventStatusInvalid({required this.reason});
}

sealed class EventState {}

class EventStateMempool extends EventState {}

class EventStateConfirmed extends EventState {
  final int blockHeight;
  final int? blockTime;
  EventStateConfirmed({
    required this.blockHeight,
    this.blockTime,
  });
}

class Event extends Equatable {
  final EventState state;

  final int? eventIndex;
  final String event;
  final String? txHash;
  final int? blockIndex;
  // final bool confirmed;

  const Event({
    required this.state,
    required this.eventIndex,
    required this.event,
    required this.txHash,
    this.blockIndex,
    // required this.confirmed,
  });

  @override
  List<Object?> get props => [
        state, eventIndex, event, txHash, blockIndex,
        // confirmed
      ];
}

class VerboseEvent extends Event {
  final int? blockTime;

  const VerboseEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.blockTime,
  });

  @override
  List<Object?> get props => [
        super.state,
        super.eventIndex,
        super.event,
        super.txHash,
        super.blockIndex,
        // super.confirmed,
        blockTime
      ];
}

class EnhancedSendParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final String? memo;
  final int quantity;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;

  EnhancedSendParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    this.memo,
    required this.quantity,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });
}

class EnhancedSendEvent extends Event {
  final EnhancedSendParams params;

  const EnhancedSendEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class VerboseEnhancedSendParams extends EnhancedSendParams {
  final int? blockTime;
  // final AssetInfo assetInfo;
  final String quantityNormalized;

  VerboseEnhancedSendParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    super.memo,
    required super.quantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required this.blockTime,
    // required this.assetInfo, // ingore asset info for now
    required this.quantityNormalized,
  });
}

class VerboseEnhancedSendEvent extends VerboseEvent {
  final VerboseEnhancedSendParams params;

  const VerboseEnhancedSendEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class VerboseMpmaSendParams {
  final String asset;
  final int blockIndex;
  final String? memo;
  final int? msgIndex;
  final int quantity;
  final String destination;
  final String status;
  final String source;
  final String quantityNormalized;
  final String txHash;
  final int txIndex;

  VerboseMpmaSendParams({
    required this.asset,
    required this.blockIndex,
    this.memo,
    this.msgIndex,
    required this.quantity,
    required this.destination,
    required this.status,
    required this.source,
    required this.txHash,
    required this.txIndex,
    required this.quantityNormalized,
  });
}

class VerboseMpmaSendEvent extends VerboseEvent {
  final VerboseMpmaSendParams params;

  const VerboseMpmaSendEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class CreditParams {
  final String address;
  final String asset;
  final int blockIndex;
  final String callingFunction;
  final String event;
  final int quantity;
  final int txIndex;

  CreditParams({
    required this.address,
    required this.asset,
    required this.blockIndex,
    required this.callingFunction,
    required this.event,
    required this.quantity,
    required this.txIndex,
  });
}

class VerboseCreditParams extends CreditParams {
  final int? blockTime;
  // final AssetInfo assetInfo;
  final String? quantityNormalized;

  VerboseCreditParams({
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.callingFunction,
    required super.event,
    required super.quantity,
    required super.txIndex,
    this.blockTime,
    // required this.assetInfo,
    this.quantityNormalized,
  });
}

class CreditEvent extends Event {
  final CreditParams params;

  const CreditEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class VerboseCreditEvent extends VerboseEvent {
  final VerboseCreditParams params;

  const VerboseCreditEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class DebitParams {
  final String action;
  final String address;
  final String asset;
  final int blockIndex;
  final String event;
  final int quantity;
  final int txIndex;

  DebitParams({
    required this.action,
    required this.address,
    required this.asset,
    required this.blockIndex,
    required this.event,
    required this.quantity,
    required this.txIndex,
  });
}

class VerboseDebitParams extends DebitParams {
  final int? blockTime;
  // final AssetInfo assetInfo;
  final String? quantityNormalized;

  VerboseDebitParams({
    required super.action,
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.event,
    required super.quantity,
    required super.txIndex,
    this.blockTime,
    // required this.assetInfo,
    this.quantityNormalized,
  });
}

class DebitEvent extends Event {
  final DebitParams params;

  const DebitEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class VerboseDebitEvent extends VerboseEvent {
  final VerboseDebitParams params;

  const VerboseDebitEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class NewFairmintParams {
  final String? asset; // Asset might not exist
  final int? blockIndex;
  final int? commission;
  final int? earnQuantity;
  final String? fairminterTxHash;
  final int? paidQuantity;
  final String? source;
  final String? status;
  final String? txHash;
  final int? txIndex;

  NewFairmintParams({
    required this.asset,
    required this.blockIndex,
    required this.commission,
    required this.earnQuantity,
    required this.fairminterTxHash,
    required this.paidQuantity,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });
}

class NewFairmintEvent extends Event {
  final NewFairmintParams params;

  const NewFairmintEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseNewFairmintEvent extends VerboseEvent {
  final VerboseNewFairmintParams params;

  const VerboseNewFairmintEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class VerboseNewFairmintParams extends NewFairmintParams {
  // final AssetInfoModel assetInfo;

  VerboseNewFairmintParams({
    required super.asset,
    required super.blockIndex,
    required super.commission,
    required super.earnQuantity,
    required super.fairminterTxHash,
    required super.paidQuantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    // required this.assetInfo,
  });
}

class NewFairminterParams {
  final String? asset;
  final String? assetLongname;
  final String? assetParent;
  final int? blockIndex;
  final bool? burnPayment;
  final String? description;
  final bool? divisible;
  final int? endBlock;
  final int? hardCap;
  final bool? lockDescription;
  final bool? lockQuantity;
  final int? maxMintPerTx;
  final int? mintedAssetCommissionInt;
  final bool? preMinted;
  final int? premintQuantity;
  final int? price;
  final int? quantityByPrice;
  final int? softCap;
  final int? softCapDeadlineBlock;
  final String? source;
  final int? startBlock;
  final String? status;
  final String? txHash;
  final int? txIndex;
  final int? blockTime;

  NewFairminterParams({
    required this.asset,
    this.assetLongname,
    this.assetParent,
    required this.blockIndex,
    this.burnPayment,
    this.description,
    this.divisible,
    this.endBlock,
    this.hardCap,
    this.lockDescription,
    this.lockQuantity,
    this.maxMintPerTx,
    this.mintedAssetCommissionInt,
    this.preMinted,
    this.premintQuantity,
    this.price,
    this.quantityByPrice,
    this.softCap,
    this.softCapDeadlineBlock,
    required this.source,
    this.startBlock,
    this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });
}

class NewFairminterEvent extends Event {
  final NewFairminterParams params;

  const NewFairminterEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseNewFairminterEvent extends VerboseEvent {
  final VerboseNewFairminterParams params;

  const VerboseNewFairminterEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class VerboseNewFairminterParams extends NewFairminterParams {
  // final AssetInfoModel assetInfo;

  VerboseNewFairminterParams({
    required super.asset,
    required super.blockIndex,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required super.blockTime,
    required super.assetLongname,
    required super.assetParent,
    required super.burnPayment,
    required super.description,
    required super.divisible,
    required super.endBlock,
    required super.hardCap,
    required super.lockDescription,
    required super.lockQuantity,
    required super.maxMintPerTx,
    required super.mintedAssetCommissionInt,
    required super.preMinted,
    required super.premintQuantity,
    required super.price,
    required super.quantityByPrice,
    required super.softCap,
    required super.softCapDeadlineBlock,
    required super.startBlock,
    // required this.assetInfo,
  });
}

class NewTransactionParams {
  final String blockHash;
  final int blockIndex;
  final int blockTime;
  final int btcAmount;
  final String data;
  final String destination;
  final int fee;
  final String source;
  final String txHash;
  final int txIndex;

  NewTransactionParams({
    required this.blockHash,
    required this.blockIndex,
    required this.blockTime,
    required this.btcAmount,
    required this.data,
    required this.destination,
    required this.fee,
    required this.source,
    required this.txHash,
    required this.txIndex,
  });
}

class NewTransactionEvent extends Event {
  final NewTransactionParams params;

  const NewTransactionEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class VerboseNewTransactionParams extends NewTransactionParams {
  final Map<String, dynamic>? unpackedData;
  final String btcAmountNormalized;

  VerboseNewTransactionParams({
    required super.blockHash,
    required super.blockIndex,
    required super.blockTime,
    required super.btcAmount,
    required super.data,
    required super.destination,
    required super.fee,
    required super.source,
    required super.txHash,
    required super.txIndex,
    required this.unpackedData,
    required this.btcAmountNormalized,
  });
}

class VerboseNewTransactionEvent extends VerboseEvent {
  final VerboseNewTransactionParams params;

  const VerboseNewTransactionEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class AssetIssuanceParams {
  final String? asset;
  final String? assetLongname;
  final String? assetEvents;
  // final int? blockIndex;
  // final int callDate;
  // final int callPrice;
  // final bool callable;
  // final String description;
  // final bool divisible;
  // final int feePaid;
  // final String issuer;
  // final bool locked;
  final int? quantity;
  // final bool reset;
  final String source;
  final EventStatus status;
  final bool transfer;
  // final String txHash;
  // final int txIndex;

  AssetIssuanceParams({
    this.asset,
    this.assetLongname,
    this.assetEvents,
    // this.blockIndex,
    // required this.callDate,
    // required this.callPrice,
    // required this.callable,
    // required this.description,
    // required this.divisible,
    // required this.feePaid,
    // required this.issuer,
    // required this.locked,
    this.quantity,
    // required this.reset,
    required this.source,
    required this.status,
    required this.transfer,
    // required this.txHash,
    // required this.txIndex,
  });
}

class AssetIssuanceEvent extends Event {
  final AssetIssuanceParams params;

  const AssetIssuanceEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class ResetIssuanceEvent extends Event {
  final AssetIssuanceParams params;

  const ResetIssuanceEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseAssetIssuanceParams extends AssetIssuanceParams {
  final int? blockTime;
  final String? quantityNormalized;
  final String feePaidNormalized;
  VerboseAssetIssuanceParams({
    required super.asset,
    required super.assetLongname,
    required super.assetEvents,
    // required super.callDate,
    // required super.callPrice,
    // required super.callable,
    // required super.description,
    // required super.divisible,
    // required super.feePaid,
    // required super.issuer,
    // required super.locked,
    required super.quantity,
    // required super.reset,
    required super.source,
    required super.status,
    required super.transfer,
    // required super.txHash,
    // required super.txIndex,
    required this.blockTime,
    this.quantityNormalized,
    required this.feePaidNormalized,
  });
}

class VerboseAssetIssuanceEvent extends VerboseEvent {
  final VerboseAssetIssuanceParams params;
  const VerboseAssetIssuanceEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class VerboseResetIssuanceEvent extends VerboseEvent {
  final VerboseAssetIssuanceParams params;
  const VerboseResetIssuanceEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class DispenseParams {
  final String asset;
  final int blockIndex;
  final int btcAmount;
  final String destination;
  final int dispenseIndex;
  final int dispenseQuantity;
  final String dispenserTxHash;
  final String source;
  final String txHash;
  final int txIndex;

  DispenseParams({
    required this.asset,
    required this.blockIndex,
    required this.btcAmount,
    required this.destination,
    required this.dispenseIndex,
    required this.dispenseQuantity,
    required this.dispenserTxHash,
    required this.source,
    required this.txHash,
    required this.txIndex,
  });
}

class VerboseDispenseParams extends DispenseParams {
  // final AssetInfo assetInfo;
  final String dispenseQuantityNormalized;
  final String btcAmountNormalized;

  VerboseDispenseParams(
      {required super.asset,
      required super.blockIndex,
      required super.btcAmount,
      required super.destination,
      required super.dispenseIndex,
      required super.dispenseQuantity,
      required super.dispenserTxHash,
      required super.source,
      required super.txHash,
      required super.txIndex,
      // required this.assetInfo,
      required this.dispenseQuantityNormalized,
      required this.btcAmountNormalized});
}

class DispenseEvent extends Event {
  final DispenseParams params;
  const DispenseEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });
}

class VerboseDispenseEvent extends VerboseEvent {
  final VerboseDispenseParams params;
  const VerboseDispenseEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });
}

class OpenDispenserParams {
  final String asset;
  final int blockIndex;
  final int escrowQuantity;
  final int giveQuantity;
  final int giveRemaining;
  final String? oracleAddress;
  final String origin;
  final int satoshirate;
  final String source;
  final int status;
  final String txHash;
  final int txIndex;

  OpenDispenserParams({
    required this.asset,
    required this.blockIndex,
    required this.escrowQuantity,
    required this.giveQuantity,
    required this.giveRemaining,
    this.oracleAddress,
    required this.origin,
    required this.satoshirate,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });
}

class OpenDispenserEvent extends Event {
  final OpenDispenserParams params;

  const OpenDispenserEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseOpenDispenserParams extends OpenDispenserParams {
  final String giveQuantityNormalized;
  final String giveRemainingNormalized;
  final String escrowQuantityNormalized;
  final String satoshirateNormalized;
  // final AssetInfo assetInfo;
  // final String description;
  // final String issuer;
  // final bool divisible;
  // final bool locked;
  //
  VerboseOpenDispenserParams({
    required super.asset,
    required super.blockIndex,
    required super.escrowQuantity,
    required super.giveQuantity,
    required super.giveRemaining,
    super.oracleAddress,
    required super.origin,
    required super.satoshirate,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required this.giveQuantityNormalized,
    required this.giveRemainingNormalized,
    required this.escrowQuantityNormalized,
    required this.satoshirateNormalized,
    // this.assetInfo
  });
}

class VerboseOpenDispenserEvent extends VerboseEvent {
  final VerboseOpenDispenserParams params;

  const VerboseOpenDispenserEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class DispenserUpdateParams {
  final String asset;
  final int? closeBlockIndex;
  final String? lastStatusTxHash;
  final String? lastStatusTxSource;
  final String source;
  final int status;
  final String? txHash;
  final int? giveRemaining;
  final int? dispenseCount;

  DispenserUpdateParams({
    required this.asset,
    required this.closeBlockIndex,
    this.lastStatusTxHash,
    required this.lastStatusTxSource,
    required this.source,
    required this.status,
    required this.txHash,
    this.giveRemaining,
    this.dispenseCount,
  });
}

class DispenserUpdateEvent extends Event {
  final DispenserUpdateParams params;

  const DispenserUpdateEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseDispenserUpdateParams extends DispenserUpdateParams {
  // final AssetInfo? assetInfo;

  VerboseDispenserUpdateParams({
    required super.asset,
    required super.closeBlockIndex,
    required super.lastStatusTxHash,
    required super.lastStatusTxSource,
    required super.source,
    required super.status,
    required super.txHash,
    // required this.assetInfo,
  });
}

class VerboseDispenserUpdateEvent extends VerboseEvent {
  final VerboseDispenserUpdateParams params;

  const VerboseDispenserUpdateEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class RefillDispenserParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int dispenseQuantity;
  final String dispenserTxHash;
  final String source;
  final String txHash;
  final int txIndex;

  RefillDispenserParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.dispenseQuantity,
    required this.dispenserTxHash,
    required this.source,
    required this.txHash,
    required this.txIndex,
  });
}

class RefillDispenserEvent extends Event {
  final RefillDispenserParams params;

  const RefillDispenserEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseRefillDispenserParams extends RefillDispenserParams {
  final String dispenseQuantityNormalized;
  // final AssetInfo? assetInfo;

  VerboseRefillDispenserParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.dispenseQuantity,
    required super.dispenserTxHash,
    required super.source,
    required super.txHash,
    required super.txIndex,
    required this.dispenseQuantityNormalized,
    // this.assetInfo,
  });
}

class VerboseRefillDispenserEvent extends VerboseEvent {
  final VerboseRefillDispenserParams params;

  const VerboseRefillDispenserEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class OpenOrderParams {
  final int blockIndex;
  final int expiration;
  final int expireIndex;
  final int feeProvided;
  final int feeProvidedRemaining;
  final int feeRequired;
  final int feeRequiredRemaining;
  final String getAsset;
  final int getQuantity;
  final int getRemaining;
  final String giveAsset;
  final int giveQuantity;
  final int giveRemaining;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  // final int blockTime;

  OpenOrderParams({
    required this.blockIndex,
    required this.expiration,
    required this.expireIndex,
    required this.feeProvided,
    required this.feeProvidedRemaining,
    required this.feeRequired,
    required this.feeRequiredRemaining,
    required this.getAsset,
    required this.getQuantity,
    required this.getRemaining,
    required this.giveAsset,
    required this.giveQuantity,
    required this.giveRemaining,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    // required this.blockTime,
  });
}

class OpenOrderEvent extends Event {
  final OpenOrderParams params;

  const OpenOrderEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseOpenOrderParams extends OpenOrderParams {
  final String giveQuantityNormalized;
  final String getQuantityNormalized;
  final String getRemainingNormalized;
  final String giveRemainingNormalized;
  final String feeProvidedNormalized;
  final String feeRequiredNormalized;
  final String feeRequiredRemainingNormalized;
  final String feeProvidedRemainingNormalized;
  // final AssetInfo giveAssetInfo;
  // final AssetInfo getAssetInfo;

  VerboseOpenOrderParams({
    required super.blockIndex,
    required super.expiration,
    required super.expireIndex,
    required super.feeProvided,
    required super.feeProvidedRemaining,
    required super.feeRequired,
    required super.feeRequiredRemaining,
    required super.getAsset,
    required super.getQuantity,
    required super.getRemaining,
    required super.giveAsset,
    required super.giveQuantity,
    required super.giveRemaining,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    // required super.blockTime,
    required this.giveQuantityNormalized,
    required this.getQuantityNormalized,
    required this.getRemainingNormalized,
    required this.giveRemainingNormalized,
    required this.feeProvidedNormalized,
    required this.feeRequiredNormalized,
    required this.feeRequiredRemainingNormalized,
    required this.feeProvidedRemainingNormalized,
    // required this.giveAssetInfo,
    // required this.getAssetInfo,
  });
}

class VerboseOpenOrderEvent extends VerboseEvent {
  final VerboseOpenOrderParams params;

  const VerboseOpenOrderEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

// OrderMatch Event
class OrderMatchParams {
  final String backwardAsset;
  final int backwardQuantity;
  final int blockIndex;
  final int feePaid;
  final String forwardAsset;
  final int forwardQuantity;
  final String id;
  final int matchExpireIndex;
  final String status;
  final String tx0Address;
  final int tx0BlockIndex;
  final int tx0Expiration;
  final String tx0Hash;
  final int tx0Index;
  final String tx1Address;
  final int tx1BlockIndex;
  final int tx1Expiration;
  final String tx1Hash;
  final int tx1Index;

  OrderMatchParams({
    required this.backwardAsset,
    required this.backwardQuantity,
    required this.blockIndex,
    required this.feePaid,
    required this.forwardAsset,
    required this.forwardQuantity,
    required this.id,
    required this.matchExpireIndex,
    required this.status,
    required this.tx0Address,
    required this.tx0BlockIndex,
    required this.tx0Expiration,
    required this.tx0Hash,
    required this.tx0Index,
    required this.tx1Address,
    required this.tx1BlockIndex,
    required this.tx1Expiration,
    required this.tx1Hash,
    required this.tx1Index,
  });
}

class OrderMatchEvent extends Event {
  final OrderMatchParams params;

  const OrderMatchEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseOrderMatchParams extends OrderMatchParams {
  final String forwardQuantityNormalized;
  final String backwardQuantityNormalized;
  final String feePaidNormalized;

  VerboseOrderMatchParams({
    required super.backwardAsset,
    required super.backwardQuantity,
    required super.blockIndex,
    required super.feePaid,
    required super.forwardAsset,
    required super.forwardQuantity,
    required super.id,
    required super.matchExpireIndex,
    required super.status,
    required super.tx0Address,
    required super.tx0BlockIndex,
    required super.tx0Expiration,
    required super.tx0Hash,
    required super.tx0Index,
    required super.tx1Address,
    required super.tx1BlockIndex,
    required super.tx1Expiration,
    required super.tx1Hash,
    required super.tx1Index,
    required this.forwardQuantityNormalized,
    required this.backwardQuantityNormalized,
    required this.feePaidNormalized,
  });
}

class VerboseOrderMatchEvent extends VerboseEvent {
  final VerboseOrderMatchParams params;

  const VerboseOrderMatchEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

// OrderUpdate Event
class OrderUpdateParams {
  final int feeProvidedRemaining;
  final int feeRequiredRemaining;
  final int getRemaining;
  final int giveRemaining;
  final String status;
  final String txHash;

  OrderUpdateParams({
    required this.feeProvidedRemaining,
    required this.feeRequiredRemaining,
    required this.getRemaining,
    required this.giveRemaining,
    required this.status,
    required this.txHash,
  });
}

class OrderUpdateEvent extends Event {
  // final OrderUpdateParams params;

  const OrderUpdateEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required this.params,
  });
}

class VerboseOrderUpdateParams extends OrderUpdateParams {
  final String feeProvidedRemainingNormalized;
  final String feeRequiredRemainingNormalized;

  VerboseOrderUpdateParams({
    required super.feeProvidedRemaining,
    required super.feeRequiredRemaining,
    required super.getRemaining,
    required super.giveRemaining,
    required super.status,
    required super.txHash,
    required this.feeProvidedRemainingNormalized,
    required this.feeRequiredRemainingNormalized,
  });
}

class VerboseOrderUpdateEvent extends VerboseEvent {
  // final VerboseOrderUpdateParams params;

  const VerboseOrderUpdateEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,

    // required this.params,
  });
}

// OrderFilled Event
class OrderFilledParams {
  final String status;
  final String txHash;

  OrderFilledParams({
    required this.status,
    required this.txHash,
  });
}

class OrderFilledEvent extends Event {
  final OrderFilledParams params;

  const OrderFilledEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseOrderFilledParams extends OrderFilledParams {
  VerboseOrderFilledParams({
    required super.status,
    required super.txHash,
  });
}

class VerboseOrderFilledEvent extends VerboseEvent {
  final VerboseOrderFilledParams params;

  const VerboseOrderFilledEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

// CancelOrder Event
class CancelOrderParams {
  final int blockIndex;
  final String offerHash;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;

  CancelOrderParams({
    required this.blockIndex,
    required this.offerHash,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });
}

class CancelOrderEvent extends Event {
  final CancelOrderParams params;

  const CancelOrderEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseCancelOrderParams extends CancelOrderParams {
  VerboseCancelOrderParams({
    required super.blockIndex,
    required super.offerHash,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
  });
}

class VerboseCancelOrderEvent extends VerboseEvent {
  final VerboseCancelOrderParams params;

  const VerboseCancelOrderEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

// OrderExpiration Event
class OrderExpirationParams {
  final int blockIndex;
  final String orderHash;
  final String source;
  final int blockTime;

  OrderExpirationParams({
    required this.blockIndex,
    required this.orderHash,
    required this.source,
    required this.blockTime,
  });
}

class OrderExpirationEvent extends Event {
  final OrderExpirationParams params;

  const OrderExpirationEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseOrderExpirationParams extends OrderExpirationParams {
  VerboseOrderExpirationParams({
    required super.blockIndex,
    required super.orderHash,
    required super.source,
    required super.blockTime,
  });
}

class VerboseOrderExpirationEvent extends VerboseEvent {
  final VerboseOrderExpirationParams params;

  const VerboseOrderExpirationEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class MoveToUtxoParams {
  final String asset;
  final int blockIndex;
  final String destination;

  MoveToUtxoParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
  });
}

class MoveToUtxoEvent extends Event {
  final MoveToUtxoParams params;

  const MoveToUtxoEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });
}

class VerboseMoveToUtxoParams extends MoveToUtxoParams {
  final String quantityNormalized;

  VerboseMoveToUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required this.quantityNormalized,
  });
}

class VerboseMoveToUtxoEvent extends VerboseEvent {
  final VerboseMoveToUtxoParams params;

  const VerboseMoveToUtxoEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class AtomicSwapParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final String bitcoinSwapAmount;
  final String quantityNormalized;

  AtomicSwapParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.bitcoinSwapAmount,
    required this.quantityNormalized,
  });
}

class AtomicSwapEvent extends VerboseEvent {
  final AtomicSwapParams params;

  const AtomicSwapEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class DetachFromUtxoParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int feePaid;

  DetachFromUtxoParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.feePaid,
  });
}

class VerboseDetachFromUtxoParams extends DetachFromUtxoParams {
  // final AssetInfo assetInfo;
  final String quantityNormalized;
  final String feePaidNormalized;

  VerboseDetachFromUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.feePaid,
    required this.quantityNormalized,
    required this.feePaidNormalized,
  });
}

class VerboseDetachFromUtxoEvent extends VerboseEvent {
  final VerboseDetachFromUtxoParams params;

  const VerboseDetachFromUtxoEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class VerboseAttachToUtxoEvent extends VerboseEvent {
  final VerboseAttachToUtxoParams params;

  const VerboseAttachToUtxoEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class VerboseAttachToUtxoParams extends AttachToUtxoEventParams {
  // final AssetInfo assetInfo;
  final String quantityNormalized;
  final String feePaidNormalized;

  VerboseAttachToUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.feePaid,
    // required this.assetInfo,
    required this.quantityNormalized,
    required this.feePaidNormalized,
  });
}

class AttachToUtxoEventParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int feePaid;

  AttachToUtxoEventParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.feePaid,
  });
}

class AttachToUtxoEvent extends VerboseEvent {
  final AttachToUtxoEventParams params;

  const AttachToUtxoEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class AssetDestructionEvent extends VerboseEvent {
  final AssetDestructionParams params;

  const AssetDestructionEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });
}

class AssetDestructionParams {
  final String asset;
  final int blockIndex;
  final int quantity;
  final String source;
  final String status;
  final String tag;
  final String txHash;
  final int txIndex;
  final String quantityNormalized;

  AssetDestructionParams({
    required this.asset,
    required this.blockIndex,
    required this.quantity,
    required this.source,
    required this.status,
    required this.tag,
    required this.txHash,
    required this.txIndex,
    required this.quantityNormalized,
  });
}

class SweepEvent extends VerboseEvent {
  final SweepParams params;

  const SweepEvent({
    required super.state,
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    super.blockTime,
    required this.params,
  });
}

class SweepParams {
  final String destination;
  final int flags;
  final String memo;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;
  final String feePaidNormalized;

  SweepParams({
    required this.destination,
    required this.flags,
    required this.memo,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
    required this.feePaidNormalized,
  });
}

final Map<int, String> flagMapper = {
  1: 'balance',
  2: 'ownership',
  3: 'ownership and balance',
  4: 'binary memo', // Historical only - not supported
  5: 'binary memo+sweep balance', // Historical only - not supported
  6: 'binary memo+sweep ownership', // Historical only - not supported
  7: 'binary memo+sweep balance+sweep ownership', // Historical only - not supported
};
