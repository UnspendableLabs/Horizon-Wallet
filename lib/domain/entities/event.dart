import "package:equatable/equatable.dart";

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

  final int eventIndex;
  final String event;
  final String txHash;
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
  final int blockTime;

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
  final int blockTime;
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
  final int blockTime;
  // final AssetInfo assetInfo;
  final String quantityNormalized;

  VerboseCreditParams({
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.callingFunction,
    required super.event,
    required super.quantity,
    required super.txIndex,
    required this.blockTime,
    // required this.assetInfo,
    required this.quantityNormalized,
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
  final int blockTime;
  // final AssetInfo assetInfo;
  final String quantityNormalized;

  VerboseDebitParams({
    required super.action,
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.event,
    required super.quantity,
    required super.txIndex,
    required this.blockTime,
    // required this.assetInfo,
    required this.quantityNormalized,
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
  final Map<String, dynamic> unpackedData;
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
  // final String status;
  // final bool transfer;
  // final String txHash;
  // final int txIndex;

  AssetIssuanceParams({
    this.asset,
    this.assetLongname,
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
    // required this.status,
    // required this.transfer,
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

class VerboseAssetIssuanceParams extends AssetIssuanceParams {
  final int blockTime;
  final String? quantityNormalized;
  final String feePaidNormalized;
  VerboseAssetIssuanceParams({
    required super.asset,
    required super.assetLongname,
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
    // required super.status,
    // required super.transfer,
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
