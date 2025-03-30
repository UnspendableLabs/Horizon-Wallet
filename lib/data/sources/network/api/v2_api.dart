import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:horizon/data/models/asset_info.dart';
import 'package:horizon/data/models/bitcoin_decoded_tx.dart';
import 'package:horizon/data/models/compose.dart';
import 'package:horizon/data/models/compose_attach_utxo.dart';
import 'package:horizon/data/models/compose_burn.dart';
import 'package:horizon/data/models/compose_cancel.dart';
import 'package:horizon/data/models/compose_destroy.dart';
import 'package:horizon/data/models/compose_detach_utxo.dart';
import 'package:horizon/data/models/compose_dividend.dart';
import 'package:horizon/data/models/compose_fairmint.dart';
import 'package:horizon/data/models/compose_fairminter.dart';
import 'package:horizon/data/models/compose_movetoutxo.dart';
import 'package:horizon/data/models/compose_order.dart';
import 'package:horizon/data/models/compose_sweep.dart';
import 'package:horizon/data/models/cursor.dart';
import 'package:horizon/data/models/dispenser.dart';
import 'package:horizon/data/models/dividend_asset_info.dart';
import 'package:horizon/data/models/fairminter.dart';
import 'package:horizon/data/models/node_info.dart';
import 'package:horizon/data/models/order.dart';
import 'package:horizon/data/models/signed_tx_estimated_size.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';

part 'v2_api.g.dart';
//
// class Verbose {
//   const Verbose();
// }
//
// // Custom interceptor
// class VerboseInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     if (options.extra['verbose'] == true) {
//       options.queryParameters['verbose'] = 'true';
//     }
//     super.onRequest(options, handler);
//   }
// }

// Domain

@JsonSerializable(
    genericArgumentFactories: true, fieldRename: FieldRename.snake)
class Response<T> {
  final T? result;
  final CursorModel? nextCursor;
  final int? resultCount;
  final String? error;

  Response(
      {required this.result,
      required this.error,
      this.nextCursor,
      this.resultCount});

  factory Response.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$ResponseFromJson(json, fromJsonT);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Block {
  final int blockIndex;
  final String blockHash;
  final int blockTime;
  final String previousBlockHash;
  final int difficulty;
  final String ledgerHash;
  final String txlistHash;
  final String messagesHash;
  final int transactionCount;
  final bool confirmed;

  const Block(
      {required this.blockIndex,
      required this.blockTime,
      required this.blockHash,
      required this.previousBlockHash,
      required this.difficulty,
      required this.ledgerHash,
      required this.txlistHash,
      required this.messagesHash,
      required this.transactionCount,
      required this.confirmed});

  factory Block.fromJson(Map<String, dynamic> json) => _$BlockFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction {
  final int? txIndex;
  final String txHash;
  final int? blockIndex;
  final String? blockHash;
  final int? blockTime;
  final String source;
  final String? destination;
  final int btcAmount;
  final int fee;
  final String data;
  final bool supported;
  final bool? confirmed;

  const Transaction(
      {required this.txHash,
      required this.txIndex,
      required this.blockIndex,
      required this.blockHash,
      required this.blockTime,
      required this.source,
      required this.destination,
      required this.btcAmount,
      required this.fee,
      required this.data,
      required this.supported,
      required this.confirmed});

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TransactionVerbose extends Transaction {
  final TransactionUnpacked unpackedData;
  final String btcAmountNormalized;

  const TransactionVerbose(
      {required super.txHash,
      super.txIndex,
      super.blockIndex,
      super.blockHash,
      super.blockTime,
      required super.source,
      super.destination,
      required super.btcAmount,
      required super.fee,
      required super.data,
      required super.supported,
      required super.confirmed,
      required this.unpackedData,
      required this.btcAmountNormalized});

  factory TransactionVerbose.fromJson(Map<String, dynamic> json) =>
      _$TransactionVerboseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Balance {
  final String? address;
  final double quantity;
  final String asset;

  const Balance({
    required this.address,
    required this.quantity,
    required this.asset,
  });

  factory Balance.fromJson(Map<String, dynamic> json) =>
      _$BalanceFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BalanceVerbose extends Balance {
  @override
  final String quantityNormalized;
  final AssetInfoModel assetInfo;
  final String? utxo;
  final String? utxoAddress;

  BalanceVerbose(
      {super.address,
      required super.quantity,
      required super.asset,
      required this.assetInfo,
      required this.quantityNormalized,
      this.utxo,
      this.utxoAddress});

  factory BalanceVerbose.fromJson(Map<String, dynamic> json) =>
      _$BalanceVerboseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MultiBalance {
  final String address;
  final int quantity;
  MultiBalance({required this.address, required this.quantity});

  factory MultiBalance.fromJson(Map<String, dynamic> json) =>
      _$MultiBalanceFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MultiBalanceVerbose {
  final String? address;
  final int quantity;
  final String quantityNormalized;
  final String? utxo;
  final String? utxoAddress;
  MultiBalanceVerbose(
      {this.address,
      required this.quantity,
      required this.quantityNormalized,
      this.utxo,
      this.utxoAddress});

  factory MultiBalanceVerbose.fromJson(Map<String, dynamic> json) =>
      _$MultiBalanceVerboseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MultiAddressBalance {
  final String asset;
  final int total;
  final List<MultiBalance> addresses;
  MultiAddressBalance(
      {required this.asset, required this.total, required this.addresses});
  factory MultiAddressBalance.fromJson(Map<String, dynamic> json) =>
      _$MultiAddressBalanceFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MultiAddressBalanceVerbose {
  final String asset;
  final int total;
  final List<MultiBalanceVerbose> addresses;
  final AssetInfoModel assetInfo;
  final String totalNormalized;
  MultiAddressBalanceVerbose(
      {required this.asset,
      required this.total,
      required this.addresses,
      required this.assetInfo,
      required this.totalNormalized});
  factory MultiAddressBalanceVerbose.fromJson(Map<String, dynamic> json) =>
      _$MultiAddressBalanceVerboseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Event {
  final int? eventIndex;
  final String event;
  final String? txHash;
  final int? blockIndex;
  // final bool confirmed;

  const Event({
    required this.eventIndex,
    required this.event,
    required this.txHash,
    this.blockIndex,
    // required this.confirmed,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventType = json['event'] as String;
    switch (eventType) {
      case 'ENHANCED_SEND':
        return EnhancedSendEvent.fromJson(json);
      case 'MPMA_SEND':
        return MpmaSendEvent.fromJson(json);
      case 'CREDIT':
        return CreditEvent.fromJson(json);
      case 'DEBIT':
        return DebitEvent.fromJson(json);
      case 'NEW_TRANSACTION':
        return NewTransactionEvent.fromJson(json);
      case 'ASSET_ISSUANCE':
        return AssetIssuanceEvent.fromJson(json);
      case 'RESET_ISSUANCE':
        return ResetIssuanceEvent.fromJson(json);
      case 'DISPENSE':
        return DispenseEvent.fromJson(json);
      case 'OPEN_DISPENSER':
        return OpenDispenserEvent.fromJson(json);
      case 'REFILL_DISPENSER':
        return RefillDispenserEvent.fromJson(json);
      case 'DISPENSER_UPDATE':
        return DispenserUpdateEvent.fromJson(json);
      case 'NEW_FAIRMINT':
        return NewFairmintEvent.fromJson(json);
      case 'NEW_FAIRMINTER':
        return NewFairminterEvent.fromJson(json);
      case "OPEN_ORDER":
        return OpenOrderEvent.fromJson(json);
      case "ORDER_MATCH":
        return OrderMatchEvent.fromJson(json);
      case "ORDER_UPDATE":
        return OrderUpdateEvent.fromJson(json);
      case "CANCEL_ORDER":
        return CancelOrderEvent.fromJson(json);
      case "ORDER_EXPIRATION":
        return OrderExpirationEvent.fromJson(json);
      case "ORDER_FILLED":
        return OrderFilledEvent.fromJson(json);
      case "ATTACH_TO_UTXO":
        return AttachToUtxoEvent.fromJson(json);
      case "DETACH_FROM_UTXO":
        return DetachFromUtxoEvent.fromJson(json);
      case "UTXO_MOVE":
        return MoveToUtxoEvent.fromJson(json);
      case "ASSET_DESTRUCTION":
        return AssetDestructionEvent.fromJson(json);
      case "ASSET_DIVIDEND":
        return AssetDividendEvent.fromJson(json);
      case "BURN":
        return BurnEvent.fromJson(json);
      default:
        return _$EventFromJson(json);
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory EnhancedSendParams.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory CreditParams.fromJson(Map<String, dynamic> json) =>
      _$CreditParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory DebitParams.fromJson(Map<String, dynamic> json) =>
      _$DebitParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory NewTransactionParams.fromJson(Map<String, dynamic> json) =>
      _$NewTransactionParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnhancedSendEvent extends Event {
  final EnhancedSendParams params;

  EnhancedSendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory EnhancedSendEvent.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendEvent extends Event {
  final MpmaSendEventParams params;

  MpmaSendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory MpmaSendEvent.fromJson(Map<String, dynamic> json) =>
      _$MpmaSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendEventParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final String source;
  final String? memo;
  final int? msgIndex;
  final int quantity;
  final String status;
  final String txHash;
  final int txIndex;

  MpmaSendEventParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.source,
    this.memo,
    this.msgIndex,
    required this.quantity,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });

  factory MpmaSendEventParams.fromJson(Map<String, dynamic> json) =>
      _$MpmaSendEventParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreditEvent extends Event {
  final CreditParams params;

  CreditEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory CreditEvent.fromJson(Map<String, dynamic> json) =>
      _$CreditEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DebitEvent extends Event {
  final DebitParams params;

  DebitEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory DebitEvent.fromJson(Map<String, dynamic> json) =>
      _$DebitEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NewTransactionEvent extends Event {
  final NewTransactionParams params;

  NewTransactionEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory NewTransactionEvent.fromJson(Map<String, dynamic> json) =>
      _$NewTransactionEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetIssuanceParams {
  final String? asset;
  final String? assetLongname;
  final String? assetEvents;
  // final int blockIndex;
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
  final String status;
  final bool transfer;
  // final String txHash;
  // final int txIndex;

  AssetIssuanceParams({
    this.asset,
    this.assetLongname,
    required this.assetEvents,
    // required this.blockIndex,
    // required this.callDate,
    // required this.callPrice,
    // required this.callable,
    // required this.description,
    // required this.divisible,
    // required this.feePaid,
    // required this.issuer,
    // required this.locked,
    required this.quantity,
    // required this.reset,
    required this.source,
    required this.status,
    required this.transfer,
    // required this.txHash,
    // required this.txIndex,
  });

  factory AssetIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$AssetIssuanceParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetIssuanceParams extends AssetIssuanceParams {
  final int? blockTime;
  // final AssetInfo assetInfo;
  final String? quantityNormalized;
  final String feePaidNormalized;

  VerboseAssetIssuanceParams({
    required super.asset,
    super.assetLongname,
    required super.assetEvents,
    // required super.blockIndex, required super.callDate, required super.callPrice, required super.callable, required super.description,
    // required super.divisible,
    // required super.feePaid,
    // required super.issuer,
    // required super.locked,
    super.quantity,
    // required super.reset,
    required super.source,
    required super.status,
    required super.transfer,
    // required super.txHash,
    // required super.txIndex,
    required this.blockTime,
    // required this.assetInfo,
    this.quantityNormalized,
    required this.feePaidNormalized,
  });

  factory VerboseAssetIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetIssuanceParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ResetIssuanceEvent extends Event {
  final AssetIssuanceParams params;

  ResetIssuanceEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory ResetIssuanceEvent.fromJson(Map<String, dynamic> json) =>
      _$ResetIssuanceEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetIssuanceEvent extends Event {
  final AssetIssuanceParams params;

  AssetIssuanceEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory AssetIssuanceEvent.fromJson(Map<String, dynamic> json) =>
      _$AssetIssuanceEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetIssuanceEvent extends VerboseEvent {
  final VerboseAssetIssuanceParams params;

  VerboseAssetIssuanceEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    // required super.confirmed,
    required this.params,
  });

  factory VerboseAssetIssuanceEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetIssuanceEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OpenDispenserEvent extends Event {
  final OpenDispenserParams params;

  OpenDispenserEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    super.blockIndex,
    required this.params,
  });

  factory OpenDispenserEvent.fromJson(Map<String, dynamic> json) =>
      _$OpenDispenserEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseResetIssuanceEvent extends VerboseEvent {
  final VerboseAssetIssuanceParams params;

  VerboseResetIssuanceEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseResetIssuanceEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseResetIssuanceEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NewFairminterEvent extends Event {
  final NewFairminterParams params;

  NewFairminterEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory NewFairminterEvent.fromJson(Map<String, dynamic> json) =>
      _$NewFairminterEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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
  final String source;
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
    required this.burnPayment,
    required this.description,
    required this.divisible,
    required this.endBlock,
    required this.hardCap,
    required this.lockDescription,
    required this.lockQuantity,
    required this.maxMintPerTx,
    required this.mintedAssetCommissionInt,
    required this.preMinted,
    required this.premintQuantity,
    required this.price,
    required this.quantityByPrice,
    required this.softCap,
    required this.softCapDeadlineBlock,
    required this.source,
    required this.startBlock,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory NewFairminterParams.fromJson(Map<String, dynamic> json) =>
      _$NewFairminterParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseNewFairminterEvent extends VerboseEvent {
  final VerboseNewFairminterParams params;

  VerboseNewFairminterEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseNewFairminterEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewFairminterEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseNewFairminterParams extends NewFairminterParams {
  VerboseNewFairminterParams({
    required super.asset,
    super.assetLongname,
    super.assetParent,
    required super.blockIndex,
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
    required super.source,
    required super.startBlock,
    required super.status,
    required super.txHash,
    required super.txIndex,
  });

  factory VerboseNewFairminterParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewFairminterParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NewFairmintEvent extends Event {
  final NewFairmintParams params;

  NewFairmintEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory NewFairmintEvent.fromJson(Map<String, dynamic> json) =>
      _$NewFairmintEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class NewFairmintParams {
  final String? asset;
  final int? blockIndex;
  final int? commission;
  final int? earnQuantity;
  final String? fairminterTxHash;
  final int? paidQuantity;
  final String source;
  final String? status;
  final String? txHash;
  final int? txIndex;
  final int? blockTime;

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
    this.blockTime,
  });

  factory NewFairmintParams.fromJson(Map<String, dynamic> json) =>
      _$NewFairmintParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseNewFairmintEvent extends VerboseEvent {
  final VerboseNewFairmintParams params;

  VerboseNewFairmintEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseNewFairmintEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewFairmintEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseNewFairmintParams extends NewFairmintParams {
  final AssetInfoModel? assetInfo;

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
    required this.assetInfo,
  });

  factory VerboseNewFairmintParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewFairmintParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory OpenDispenserParams.fromJson(Map<String, dynamic> json) =>
      _$OpenDispenserParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOpenDispenserEvent extends VerboseEvent {
  final VerboseOpenDispenserParams params;

  VerboseOpenDispenserEvent({
    required super.eventIndex,
    required super.event,
    required String super.txHash,
    super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseOpenDispenserEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOpenDispenserEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOpenDispenserParams extends OpenDispenserParams {
  final String giveQuantityNormalized;
  final String giveRemainingNormalized;
  final String escrowQuantityNormalized;
  final String satoshirateNormalized;

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
  });

  factory VerboseOpenDispenserParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOpenDispenserParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OpenOrderEvent extends Event {
  final OpenOrderParams params;

  OpenOrderEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory OpenOrderEvent.fromJson(Map<String, dynamic> json) =>
      _$OpenOrderEventFromJson(json);

  Map<String, dynamic> toJson() => _$OpenOrderEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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
  });

  factory OpenOrderParams.fromJson(Map<String, dynamic> json) =>
      _$OpenOrderParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenOrderParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOpenOrderEvent extends VerboseEvent {
  final VerboseOpenOrderParams params;

  VerboseOpenOrderEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseOpenOrderEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOpenOrderEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseOpenOrderEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOpenOrderParams extends OpenOrderParams {
  final String giveQuantityNormalized;
  final String getQuantityNormalized;
  final String getRemainingNormalized;
  final String giveRemainingNormalized;
  final String feeProvidedNormalized;
  final String feeRequiredNormalized;
  final String feeRequiredRemainingNormalized;
  final String feeProvidedRemainingNormalized;
  final AssetInfoModel giveAssetInfo;
  final AssetInfoModel getAssetInfo;

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
    required this.giveQuantityNormalized,
    required this.getQuantityNormalized,
    required this.getRemainingNormalized,
    required this.giveRemainingNormalized,
    required this.feeProvidedNormalized,
    required this.feeRequiredNormalized,
    required this.feeRequiredRemainingNormalized,
    required this.feeProvidedRemainingNormalized,
    required this.giveAssetInfo,
    required this.getAssetInfo,
  });

  factory VerboseOpenOrderParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOpenOrderParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseOpenOrderParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderMatchEvent extends Event {
  final OrderMatchParams params;

  const OrderMatchEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory OrderMatchEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderMatchEventFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMatchEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory OrderMatchParams.fromJson(Map<String, dynamic> json) =>
      _$OrderMatchParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderMatchParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderMatchEvent extends VerboseEvent {
  final VerboseOrderMatchParams params;

  VerboseOrderMatchEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseOrderMatchEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderMatchEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseOrderMatchEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderMatchParams extends OrderMatchParams {
  final String forwardQuantityNormalized;
  final String backwardQuantityNormalized;
  final String feePaidNormalized;
  final AssetInfoModel forwardAssetInfo;
  final AssetInfoModel backwardAssetInfo;

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
    required this.forwardAssetInfo,
    required this.backwardAssetInfo,
  });

  factory VerboseOrderMatchParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderMatchParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseOrderMatchParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderUpdateEvent extends Event {
  final OrderUpdateParams params;

  const OrderUpdateEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory OrderUpdateEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderUpdateEventFromJson(json);

  Map<String, dynamic> toJson() => _$OrderUpdateEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory OrderUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$OrderUpdateParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderUpdateParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderUpdateEvent extends VerboseEvent {
  // final VerboseOrderUpdateParams params;

  VerboseOrderUpdateEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    // required this.params,
  });

  factory VerboseOrderUpdateEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderUpdateEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseOrderUpdateEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderUpdateParams extends OrderUpdateParams {
  final String feeProvidedRemainingNormalized;
  final String feeRequiredRemainingNormalized;
  final String getRemainingNormalized;
  final String giveRemainingNormalized;

  VerboseOrderUpdateParams({
    required super.feeProvidedRemaining,
    required super.feeRequiredRemaining,
    required super.getRemaining,
    required super.giveRemaining,
    required super.status,
    required super.txHash,
    required this.feeProvidedRemainingNormalized,
    required this.feeRequiredRemainingNormalized,
    required this.getRemainingNormalized,
    required this.giveRemainingNormalized,
  });

  factory VerboseOrderUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderUpdateParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseOrderUpdateParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderFilledEvent extends Event {
  final OrderFilledParams params;

  const OrderFilledEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory OrderFilledEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderFilledEventFromJson(json);

  Map<String, dynamic> toJson() => _$OrderFilledEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDestructionEvent extends Event {
  final AssetDestructionParams params;

  AssetDestructionEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory AssetDestructionEvent.fromJson(Map<String, dynamic> json) =>
      _$AssetDestructionEventFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDestructionEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDestructionParams {
  final String asset;
  final int blockIndex;
  final int quantity;
  final String source;
  final String status;
  final String tag;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  AssetDestructionParams({
    required this.asset,
    required this.blockIndex,
    required this.quantity,
    required this.source,
    required this.status,
    required this.tag,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory AssetDestructionParams.fromJson(Map<String, dynamic> json) =>
      _$AssetDestructionParamsFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDestructionParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetDestructionEvent extends VerboseEvent {
  final VerboseAssetDestructionParams params;

  VerboseAssetDestructionEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseAssetDestructionEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetDestructionEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseAssetDestructionEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetDestructionParams extends AssetDestructionParams {
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  VerboseAssetDestructionParams({
    required super.asset,
    required super.blockIndex,
    required super.quantity,
    required super.source,
    required super.status,
    required super.tag,
    required super.txHash,
    required super.txIndex,
    super.blockTime,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseAssetDestructionParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetDestructionParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseAssetDestructionParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDividendEvent extends Event {
  final AssetDividendParams params;

  AssetDividendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory AssetDividendEvent.fromJson(Map<String, dynamic> json) =>
      _$AssetDividendEventFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDividendEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDividendParams {
  final String asset;
  final int blockIndex;
  final String dividendAsset;
  final int feePaid;
  final int quantityPerUnit;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  AssetDividendParams({
    required this.asset,
    required this.blockIndex,
    required this.dividendAsset,
    required this.feePaid,
    required this.quantityPerUnit,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory AssetDividendParams.fromJson(Map<String, dynamic> json) =>
      _$AssetDividendParamsFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDividendParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetDividendEvent extends VerboseEvent {
  final VerboseAssetDividendParams params;

  VerboseAssetDividendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseAssetDividendEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetDividendEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseAssetDividendEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetDividendParams extends AssetDividendParams {
  final AssetInfoModel assetInfo;
  final DividendAssetInfoModel dividendAssetInfo;
  final String quantityPerUnitNormalized;
  final String feePaidNormalized;

  VerboseAssetDividendParams({
    required super.asset,
    required super.blockIndex,
    required super.dividendAsset,
    required super.feePaid,
    required super.quantityPerUnit,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    super.blockTime,
    required this.assetInfo,
    required this.dividendAssetInfo,
    required this.quantityPerUnitNormalized,
    required this.feePaidNormalized,
  });

  factory VerboseAssetDividendParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetDividendParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseAssetDividendParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SweepEvent extends Event {
  final SweepParams params;

  SweepEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory SweepEvent.fromJson(Map<String, dynamic> json) =>
      _$SweepEventFromJson(json);

  Map<String, dynamic> toJson() => _$SweepEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SweepParams {
  final int blockIndex;
  final int feePaid;
  final String destination;
  final int flags;
  final String? memo;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  SweepParams({
    required this.blockIndex,
    required this.feePaid,
    required this.destination,
    required this.flags,
    this.memo,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory SweepParams.fromJson(Map<String, dynamic> json) =>
      _$SweepParamsFromJson(json);

  Map<String, dynamic> toJson() => _$SweepParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseSweepEvent extends VerboseEvent {
  final VerboseSweepParams params;

  VerboseSweepEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseSweepEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseSweepEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseSweepEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseSweepParams extends SweepParams {
  final String feePaidNormalized;

  VerboseSweepParams({
    required super.blockIndex,
    required super.feePaid,
    required super.destination,
    required super.flags,
    required super.memo,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required this.feePaidNormalized,
  });

  factory VerboseSweepParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseSweepParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseSweepParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BurnEvent extends Event {
  final BurnParams params;

  BurnEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory BurnEvent.fromJson(Map<String, dynamic> json) =>
      _$BurnEventFromJson(json);

  Map<String, dynamic> toJson() => _$BurnEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BurnParams {
  final int blockIndex;
  final int burned;
  final int earned;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  BurnParams({
    required this.blockIndex,
    required this.burned,
    required this.earned,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory BurnParams.fromJson(Map<String, dynamic> json) =>
      _$BurnParamsFromJson(json);

  Map<String, dynamic> toJson() => _$BurnParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MoveToUtxoEvent extends Event {
  final MoveToUtxoParams params;

  MoveToUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory MoveToUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$MoveToUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$MoveToUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseBurnEvent extends VerboseEvent {
  final VerboseBurnParams params;

  VerboseBurnEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseBurnEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseBurnEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseBurnEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseBurnParams extends BurnParams {
  final String burnedNormalized;
  final String earnedNormalized;

  VerboseBurnParams({
    required super.blockIndex,
    required super.burned,
    required super.earned,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required this.burnedNormalized,
    required this.earnedNormalized,
  });

  factory VerboseBurnParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseBurnParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseBurnParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MoveToUtxoParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int msgIndex;
  final int quantity;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  MoveToUtxoParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.msgIndex,
    required this.quantity,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    this.blockTime,
  });

  factory MoveToUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$MoveToUtxoParamsFromJson(json);

  Map<String, dynamic> toJson() => _$MoveToUtxoParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseMoveToUtxoEvent extends VerboseEvent {
  final VerboseMoveToUtxoParams params;

  VerboseMoveToUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseMoveToUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseMoveToUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseMoveToUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseMoveToUtxoParams extends MoveToUtxoParams {
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  VerboseMoveToUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.msgIndex,
    required super.quantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required super.blockTime,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseMoveToUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseMoveToUtxoParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseMoveToUtxoParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DetachFromUtxoEvent extends Event {
  final DetachFromUtxoParams params;

  DetachFromUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory DetachFromUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$DetachFromUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$DetachFromUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DetachFromUtxoParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int feePaid;
  final int msgIndex;
  final int quantity;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;

  DetachFromUtxoParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.feePaid,
    required this.msgIndex,
    required this.quantity,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
  });

  factory DetachFromUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$DetachFromUtxoParamsFromJson(json);

  Map<String, dynamic> toJson() => _$DetachFromUtxoParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDetachFromUtxoEvent extends VerboseEvent {
  final VerboseDetachFromUtxoParams params;

  VerboseDetachFromUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseDetachFromUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseDetachFromUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseDetachFromUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDetachFromUtxoParams extends DetachFromUtxoParams {
  final AssetInfoModel assetInfo;
  final String quantityNormalized;
  final String feePaidNormalized;

  VerboseDetachFromUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.feePaid,
    required super.msgIndex,
    required super.quantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required this.assetInfo,
    required this.quantityNormalized,
    required this.feePaidNormalized,
  });

  factory VerboseDetachFromUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseDetachFromUtxoParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseDetachFromUtxoParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachToUtxoEvent extends Event {
  final AttachToUtxoParams params;

  AttachToUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory AttachToUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$AttachToUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$AttachToUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachToUtxoParams {
  final String asset;
  final int blockIndex;
  final String destination;
  final int feePaid;
  final int msgIndex;
  final int quantity;
  final String source;
  final String status;
  final String txHash;
  final int txIndex;
  final int? blockTime;

  AttachToUtxoParams({
    required this.asset,
    required this.blockIndex,
    required this.destination,
    required this.feePaid,
    required this.msgIndex,
    required this.quantity,
    required this.source,
    required this.status,
    required this.txHash,
    required this.txIndex,
    required this.blockTime,
  });

  factory AttachToUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$AttachToUtxoParamsFromJson(json);

  Map<String, dynamic> toJson() => _$AttachToUtxoParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderFilledParams {
  final String status;
  final String txHash;

  OrderFilledParams({
    required this.status,
    required this.txHash,
  });

  factory OrderFilledParams.fromJson(Map<String, dynamic> json) =>
      _$OrderFilledParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderFilledParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderFilledEvent extends VerboseEvent {
  final VerboseOrderFilledParams params;

  VerboseOrderFilledEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseOrderFilledEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderFilledEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseOrderFilledEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderFilledParams extends OrderFilledParams {
  VerboseOrderFilledParams({
    required super.status,
    required super.txHash,
  });

  factory VerboseOrderFilledParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderFilledParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseOrderFilledParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CancelOrderEvent extends Event {
  final CancelOrderParams params;

  const CancelOrderEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory CancelOrderEvent.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderEventFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory CancelOrderParams.fromJson(Map<String, dynamic> json) =>
      _$CancelOrderParamsFromJson(json);

  Map<String, dynamic> toJson() => _$CancelOrderParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseCancelOrderEvent extends VerboseEvent {
  final VerboseCancelOrderParams params;

  VerboseCancelOrderEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseCancelOrderEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseCancelOrderEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseCancelOrderEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseCancelOrderParams extends CancelOrderParams {
  VerboseCancelOrderParams({
    required super.blockIndex,
    required super.offerHash,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
  });

  factory VerboseCancelOrderParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseCancelOrderParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseCancelOrderParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderExpirationEvent extends Event {
  final OrderExpirationParams params;

  const OrderExpirationEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required this.params,
  });

  factory OrderExpirationEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderExpirationEventFromJson(json);

  Map<String, dynamic> toJson() => _$OrderExpirationEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory OrderExpirationParams.fromJson(Map<String, dynamic> json) =>
      _$OrderExpirationParamsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderExpirationParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderExpirationEvent extends VerboseEvent {
  final VerboseOrderExpirationParams params;

  VerboseOrderExpirationEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseOrderExpirationEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderExpirationEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseOrderExpirationEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseOrderExpirationParams extends OrderExpirationParams {
  VerboseOrderExpirationParams({
    required super.blockIndex,
    required super.orderHash,
    required super.source,
    required super.blockTime,
  });

  factory VerboseOrderExpirationParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseOrderExpirationParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseOrderExpirationParamsToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAttachToUtxoEvent extends VerboseEvent {
  final VerboseAttachToUtxoParams params;

  VerboseAttachToUtxoEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseAttachToUtxoEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseAttachToUtxoEventFromJson(json);

  Map<String, dynamic> toJson() => _$VerboseAttachToUtxoEventToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAttachToUtxoParams extends AttachToUtxoParams {
  final AssetInfoModel assetInfo;
  final String quantityNormalized;
  final String feePaidNormalized;
  VerboseAttachToUtxoParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.feePaid,
    required super.msgIndex,
    required super.quantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    required super.blockTime,
    required this.assetInfo,
    required this.quantityNormalized,
    required this.feePaidNormalized,
  });

  factory VerboseAttachToUtxoParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseAttachToUtxoParamsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$VerboseAttachToUtxoParamsToJson(this);
}

// {
//     "event_index": 17758284,
//     "event": "REFILL_DISPENSER",
//     "params": {
//         "asset": "A4630460187535670455",
//         "block_index": 863842,
//         "destination": "bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp",
//         "dispense_quantity": 1,
//         "dispenser_tx_hash": "609ac3187dd8ba65d484f945784cd3056f1c087aae766e773818d75b51e0e78b",
//         "source": "bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp",
//         "tx_hash": "1dc0aa271c66b66a7f5a7222cbb950aeefebec1c4bcbae58f64beeefff2117d2",
//         "tx_index": 2756307,
//         "block_time": 1727894737,
//         "asset_info": {
//             "asset_longname": null,
//             "description": "",
//             "issuer": "bc1q0eapk4tyqa7r2vcta6z6v2mgnqcux3kfkmurzp",
//             "divisible": true,
//             "locked": false
//         },
//         "dispense_quantity_normalized": "0.00000001"
//     },
//     "tx_hash": "1dc0aa271c66b66a7f5a7222cbb950aeefebec1c4bcbae58f64beeefff2117d2",
//     "block_index": 863842,
//     "block_time": 1727894737
// },

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenserUpdateEvent extends Event {
  final DispenserUpdateParams params;

  DispenserUpdateEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    super.blockIndex,
    required this.params,
  });

  factory DispenserUpdateEvent.fromJson(Map<String, dynamic> json) =>
      _$DispenserUpdateEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenserUpdateParams {
  final String asset;
  final int? closeBlockIndex;
  final String? lastStatusTxHash; // closing dispenser w delay
  final String? lastStatusTxSource;
  final String source;
  final int status;
  final String? txHash;
  final int? giveRemaining; // refill or closing dispenser
  final int? dispenseCount; // refill dispenser

  DispenserUpdateParams({
    required this.asset,
    required this.closeBlockIndex,
    this.lastStatusTxHash,
    this.lastStatusTxSource,
    required this.source,
    required this.status,
    required this.txHash,
    this.giveRemaining,
    this.dispenseCount,
  });

  factory DispenserUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$DispenserUpdateParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDispenserUpdateEvent extends VerboseEvent {
  final VerboseDispenserUpdateParams params;

  VerboseDispenserUpdateEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseDispenserUpdateEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseDispenserUpdateEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDispenserUpdateParams extends DispenserUpdateParams {
  final AssetInfoModel assetInfo;

  VerboseDispenserUpdateParams({
    required super.asset,
    required super.closeBlockIndex,
    required super.lastStatusTxHash,
    required super.lastStatusTxSource,
    required super.source,
    required super.status,
    required super.txHash,
    required this.assetInfo,
  });

  factory VerboseDispenserUpdateParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseDispenserUpdateParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
@JsonSerializable(fieldRename: FieldRename.snake)
class RefillDispenserEvent extends Event {
  final RefillDispenserParams params;

  RefillDispenserEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    super.blockIndex,
    required this.params,
  });

  factory RefillDispenserEvent.fromJson(Map<String, dynamic> json) =>
      _$RefillDispenserEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory RefillDispenserParams.fromJson(Map<String, dynamic> json) =>
      _$RefillDispenserParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseRefillDispenserEvent extends VerboseEvent {
  final VerboseRefillDispenserParams params;

  VerboseRefillDispenserEvent({
    required super.eventIndex,
    required super.event,
    required String super.txHash,
    super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseRefillDispenserEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseRefillDispenserEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseRefillDispenserParams extends RefillDispenserParams {
  final String dispenseQuantityNormalized;
  final AssetInfoModel assetInfo;

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
    required this.assetInfo,
  });

  factory VerboseRefillDispenserParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseRefillDispenserParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory DispenseParams.fromJson(Map<String, dynamic> json) =>
      _$DispenseParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory VerboseDispenseParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseDispenseParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenseEvent extends Event {
  final DispenseParams params;

  DispenseEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.params,
  });

  factory DispenseEvent.fromJson(Map<String, dynamic> json) =>
      _$DispenseEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDispenseEvent extends VerboseEvent {
  final VerboseDispenseParams params;
  VerboseDispenseEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    // required super.confirmed,
    required this.params,
  });

  factory VerboseDispenseEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseDispenseEventFromJson(json);
}

//
//  "event_index": 5348402,
//   "event": "ASSET_ISSUANCE",
//   "params": {
//     "asset": "A12445442962327434604",
//     "asset_longname": null,
//     "block_index": 2867711,
//     "call_date": 0,
//     "call_price": 0,
//     "callable": false,
//     "description": "",
//     "divisible": true,
//     "fee_paid": 0,
//     "issuer": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//     "locked": false,
//     "quantity": 10,
//     "reset": false,
//     "source": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//     "status": "valid",
//     "transfer": false,
//     "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//     "tx_index": 37585,
//     "block_time": 1720808130,
//     "quantity_normalized": "0.00000010",
//     "fee_paid_normalized": "0.00000000"
//   },
//   "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//   "block_index": 2867711,
//   "confirmed": true,
//   "block_time": 1720808130
// }

// {
//       "event_index": 5348402,
//       "event": "ASSET_ISSUANCE",
//       "params": {
//         "asset": "A12445442962327434604",
//         "asset_longname": null,
//         "block_index": 2867711,
//         "call_date": 0,
//         "call_price": 0,
//         "callable": false,
//         "description": "",
//         "divisible": true,
//         "fee_paid": 0,
//         "issuer": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//         "locked": false,
//         "quantity": 10,
//         "reset": false,
//         "source": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//         "status": "valid",
//         "transfer": false,
//         "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//         "tx_index": 37585
//       },
//       "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//       "block_index": 2867711,
//       "confirmed": true
//     },

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseEnhancedSendParams extends EnhancedSendParams {
  final int? blockTime;
  final AssetInfoModel assetInfo;
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
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseEnhancedSendParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseEnhancedSendParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseCreditParams extends CreditParams {
  final int? blockTime;
  final AssetInfoModel? assetInfo;
  final String? quantityNormalized;

  VerboseCreditParams({
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.callingFunction,
    required super.event,
    required super.quantity,
    required super.txIndex,
    required this.blockTime,
    this.assetInfo,
    this.quantityNormalized,
  });

  factory VerboseCreditParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseCreditParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDebitParams extends DebitParams {
  final int? blockTime;
  final AssetInfoModel? assetInfo;
  final String? quantityNormalized;

  VerboseDebitParams({
    required super.action,
    required super.address,
    required super.asset,
    required super.blockIndex,
    required super.event,
    required super.quantity,
    required super.txIndex,
    required this.blockTime,
    this.assetInfo,
    this.quantityNormalized,
  });

  factory VerboseDebitParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseDebitParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory VerboseNewTransactionParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewTransactionParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseEvent extends Event {
  final int? blockTime;

  VerboseEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required this.blockTime,
  });

  factory VerboseEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['event'] as String;
    switch (eventType) {
      case 'ENHANCED_SEND':
        return VerboseEnhancedSendEvent.fromJson(json);
      case 'MPMA_SEND':
        return VerboseMpmaSendEvent.fromJson(json);
      case 'CREDIT':
        return VerboseCreditEvent.fromJson(json);
      case 'DEBIT':
        return VerboseDebitEvent.fromJson(json);
      case 'NEW_TRANSACTION':
        return VerboseNewTransactionEvent.fromJson(json);
      case 'ASSET_ISSUANCE':
        return VerboseAssetIssuanceEvent.fromJson(json);
      case 'DISPENSE':
        return VerboseDispenseEvent.fromJson(json);
      case 'OPEN_DISPENSER':
        return VerboseOpenDispenserEvent.fromJson(json);
      case 'REFILL_DISPENSER':
        return VerboseRefillDispenserEvent.fromJson(json);
      case 'DISPENSER_UPDATE':
        return VerboseDispenserUpdateEvent.fromJson(json);
      case 'RESET_ISSUANCE':
        return VerboseResetIssuanceEvent.fromJson(json);
      case "ASSET_CREATION":
        return VerboseAssetIssuanceEvent.fromJson(json);
      case 'NEW_FAIRMINT':
        return VerboseNewFairmintEvent.fromJson(json);
      case 'NEW_FAIRMINTER':
        return VerboseNewFairminterEvent.fromJson(json);
      case "OPEN_ORDER":
        return VerboseOpenOrderEvent.fromJson(json);
      case "ORDER_MATCH":
        return VerboseOrderMatchEvent.fromJson(json);
      case "ORDER_UPDATE":
        return VerboseOrderUpdateEvent.fromJson(json);
      case "CANCEL_ORDER":
        return VerboseCancelOrderEvent.fromJson(json);
      case "ORDER_EXPIRATION":
        return VerboseOrderExpirationEvent.fromJson(json);
      case "ORDER_FILLED":
        return VerboseOrderFilledEvent.fromJson(json);
      case "ATTACH_TO_UTXO":
        return VerboseAttachToUtxoEvent.fromJson(json);
      case "DETACH_FROM_UTXO":
        return VerboseDetachFromUtxoEvent.fromJson(json);
      case "UTXO_MOVE":
        return VerboseMoveToUtxoEvent.fromJson(json);
      case "ASSET_DESTRUCTION":
        return VerboseAssetDestructionEvent.fromJson(json);
      case "ASSET_DIVIDEND":
        return VerboseAssetDividendEvent.fromJson(json);
      case "SWEEP":
        return VerboseSweepEvent.fromJson(json);
      case "BURN":
        return VerboseBurnEvent.fromJson(json);
      default:
        return _$VerboseEventFromJson(json);
    }
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseEnhancedSendEvent extends VerboseEvent {
  final VerboseEnhancedSendParams params;

  VerboseEnhancedSendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });

  factory VerboseEnhancedSendEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseEnhancedSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseMpmaSendEvent extends VerboseEvent {
  final VerboseMpmaSendParams params;

  VerboseMpmaSendEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.blockTime,
    required this.params,
  });

  factory VerboseMpmaSendEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseMpmaSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseMpmaSendParams extends MpmaSendEventParams {
  final int? blockTime;
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  VerboseMpmaSendParams({
    required super.asset,
    required super.blockIndex,
    required super.destination,
    required super.memo,
    required super.msgIndex,
    required super.quantity,
    required super.source,
    required super.status,
    required super.txHash,
    required super.txIndex,
    this.blockTime,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseMpmaSendParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseMpmaSendParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseCreditEvent extends VerboseEvent {
  final VerboseCreditParams params;

  VerboseCreditEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });

  factory VerboseCreditEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseCreditEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDebitEvent extends VerboseEvent {
  final VerboseDebitParams params;

  VerboseDebitEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });

  factory VerboseDebitEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseDebitEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseNewTransactionEvent extends VerboseEvent {
  final VerboseNewTransactionParams params;

  VerboseNewTransactionEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    // required super.confirmed,
    required super.blockTime,
    required this.params,
  });

  factory VerboseNewTransactionEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewTransactionEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EventCount {
  final String event;
  final int eventCount;

  const EventCount({
    required this.event,
    required this.eventCount,
  });

  factory EventCount.fromJson(Map<String, dynamic> json) =>
      _$EventCountFromJson(json);
}

// {
//                "block_index": 840464,
//                "address": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
//                "asset": "UNNEGOTIABLE",
//                "quantity": 1,
//                "calling_function": "issuance",
//                "event": "876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5",
//                "tx_index": 2726605,
//                "asset_info": {
//                    "asset_longname": null,
//                    "description": "https://zawqddvy75sz6dwqllsrupumldqwi26kk3amlz4fqci7hrsuqcfq.arweave.net/yC0Bjrj_ZZ8O0FrlGj6MWOFka8pWwMXnhYCR88ZUgIs/UNNEG.json",
//                    "issuer": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
//                    "divisible": 0,
//                    "locked": 1
//                },
//                "quantity_normalized": "1"
//            }

@JsonSerializable(fieldRename: FieldRename.snake)
class Asset {
  final String asset;
  final String assetLongname;
  final String description;
  final String? issuer;
  final bool divisible;
  final bool locked;
  const Asset({
    required this.asset,
    required this.assetLongname,
    required this.description,
    required this.divisible,
    required this.locked,
    this.issuer, // TODO: validate shape
  });
  factory Asset.fromJson(Map<String, dynamic> json) => _$AssetFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetVerbose {
  final String asset;
  final String? assetLongname;
  final String? description;
  final String? issuer;
  final String? owner;
  final bool? divisible;
  final bool? locked;
  final int? supply;
  final bool? confirmed;
  final String? supplyNormalized;

  const AssetVerbose({
    required this.asset,
    this.assetLongname,
    this.description,
    this.divisible,
    this.locked,
    this.issuer,
    this.owner,
    this.supply,
    this.confirmed,
    this.supplyNormalized,
  });
  factory AssetVerbose.fromJson(Map<String, dynamic> json) =>
      _$AssetVerboseFromJson(json);
}

// @JsonSerializable(fieldRename: FieldRename.snake)
// class AssetInfo {
//   final String? assetLongname;
//   final String description;
//   final bool divisible;
//   const AssetInfo({
//     required this.assetLongname,
//     required this.description,
//     required this.divisible,
//   });
//   factory AssetInfo.fromJson(Map<String, dynamic> json) =>
//       _$AssetInfoFromJson(json);
// }

@JsonSerializable(fieldRename: FieldRename.snake)
class Credit {
  final String blockIndex;
  final String address;
  final String asset;
  final int quantity;
  final String callingFunction;
  final String event;
  final int txIndex;
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  const Credit({
    required this.blockIndex,
    required this.address,
    required this.asset,
    required this.quantity,
    required this.callingFunction,
    required this.event,
    required this.txIndex,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Credit.fromJson(Map<String, dynamic> json) => _$CreditFromJson(json);
}

// {
//                 "block_index": 840464,
//                 "address": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
//                 "asset": "XCP",
//                 "quantity": 50000000,
//                 "action": "issuance fee",
//                 "event": "876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5",
//                 "tx_index": 2726605,
//                 "asset_info": {
//                     "divisible": true,
//                     "asset_longname": "Counterparty",
//                     "description": "The Counterparty protocol native currency",
//                     "locked": true
//                 },
//                 "quantity_normalized": "0.5"
//             }

@JsonSerializable(fieldRename: FieldRename.snake)
class Debit {
  final int blockIndex;
  final String address;
  final String asset;
  final int quantity;
  final String action;
  final String event;
  final int txIndex;
  final AssetInfoModel assetInfo;
  final String quantityNormalized;
  const Debit({
    required this.blockIndex,
    required this.address,
    required this.asset,
    required this.quantity,
    required this.action,
    required this.event,
    required this.txIndex,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Debit.fromJson(Map<String, dynamic> json) => _$DebitFromJson(json);
}

// {
//               "type": "order",
//               "object_id": "533d5c0ecd8ca9c2946d3298cc5e570eee55b62b887dd85c95de6de4fdc7f441"
//           },

@JsonSerializable(fieldRename: FieldRename.snake)
class Expiration {
  final String type;
  final String objectId;
  const Expiration({
    required this.type,
    required this.objectId,
  });
  factory Expiration.fromJson(Map<String, dynamic> json) =>
      _$ExpirationFromJson(json);
}

// {
//               "tx_index": 2725738,
//               "tx_hash": "793af9129c7368f974c3ea0c87ad38131f0d82d19fbaf1adf8aaf2e657ec42b8",
//               "block_index": 839746,
//               "source": "1E6tyJ2zCyX74XgEK8t9iNMjxjNVLCGR1u",
//               "offer_hash": "04b258ac37f73e3b9a8575110320d67c752e1baace0f516da75845f388911735",
//               "status": "valid"
//           },
@JsonSerializable(fieldRename: FieldRename.snake)
class Cancel {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String offerHash;
  final String status;

  const Cancel({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.offerHash,
    required this.status,
  });

  factory Cancel.fromJson(Map<String, dynamic> json) => _$CancelFromJson(json);
}

// i  {
//                 "tx_index": 2726496,
//                 "tx_hash": "f5609facc8dac6cdf70b15c514ea15a9acc24a9bd86dcac2b845d5740fbcc50b",
//                 "block_index": 839988,
//                 "source": "1FpLAtreZjTVCMcj1pq1AHWuqcs3n7obMm",
//                 "asset": "COBBEE",
//                 "quantity": 50000,
//                 "tag": "",
//                 "status": "valid",
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "https://easyasset.art/j/m4dl0x/COBBE.json",
//                     "issuer": "1P3KQWLsTPXVWimiF2Q6WSES5vbJE8be5i",
//                     "divisible": 0,
//                     "locked": 0
//                 },
//                 "quantity_normalized": "50000"
//             }
@JsonSerializable(fieldRename: FieldRename.snake)
class Destruction {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String asset;
  final int quantity;
  final String tag;
  final String status;
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  const Destruction({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.asset,
    required this.quantity,
    required this.tag,
    required this.status,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Destruction.fromJson(Map<String, dynamic> json) =>
      _$DestructionFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Issuance {
  final int txIndex;
  final String txHash;
  final int msgIndex;
  final int blockIndex;
  final String asset;
  final int quantity;
  final int divisible;
  final String source;
  final String issuer;
  final int transfer;
  final int callable;
  final int callDate;
  final double callPrice;
  final String description;
  final int feePaid;
  final int locked;
  final String status;
  final String? assetLongname;
  final int reset;

  const Issuance({
    required this.txIndex,
    required this.txHash,
    required this.msgIndex,
    required this.blockIndex,
    required this.asset,
    required this.quantity,
    required this.divisible,
    required this.source,
    required this.issuer,
    required this.transfer,
    required this.callable,
    required this.callDate,
    required this.callPrice,
    required this.description,
    required this.feePaid,
    required this.locked,
    required this.status,
    this.assetLongname,
    required this.reset,
  });

  factory Issuance.fromJson(Map<String, dynamic> json) =>
      _$IssuanceFromJson(json);
}

@JsonSerializable()
class ComposeIssuance {
  final String rawtransaction;
  final ComposeIssuanceParams params;
  final String name;

  const ComposeIssuance({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });

  factory ComposeIssuance.fromJson(Map<String, dynamic> json) =>
      _$ComposeIssuanceFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeIssuanceParams {
  final String source;
  final String asset;
  final int quantity;
  final bool divisible;
  final bool lock;
  final bool reset;
  final String? description;
  final String? transferDestination;

  ComposeIssuanceParams({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.divisible,
    required this.lock,
    required this.reset,
    this.description,
    this.transferDestination,
  });

  factory ComposeIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$ComposeIssuanceParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeIssuanceVerbose extends ComposeIssuance {
  @override
  final ComposeIssuanceVerboseParams params;
  final int btcFee;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  ComposeIssuanceVerbose({
    required super.rawtransaction,
    required super.name,
    required this.params,
    required this.btcFee,
    required this.signedTxEstimatedSize,
  }) : super(params: params);

  factory ComposeIssuanceVerbose.fromJson(Map<String, dynamic> json) =>
      _$ComposeIssuanceVerboseFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeIssuanceVerboseParams extends ComposeIssuanceParams {
  final String quantityNormalized;

  ComposeIssuanceVerboseParams({
    required super.source,
    required super.asset,
    required super.quantity,
    required super.divisible,
    required super.lock,
    required super.reset,
    super.description,
    super.transferDestination,
    required this.quantityNormalized,
  });

  factory ComposeIssuanceVerboseParams.fromJson(Map<String, dynamic> json) =>
      _$ComposeIssuanceVerboseParamsFromJson(json);
}

@JsonSerializable()
class ComposeDispenser {
  final String rawtransaction;
  final ComposeDispenserParams params;
  final String name;

  const ComposeDispenser({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });

  factory ComposeDispenser.fromJson(Map<String, dynamic> json) =>
      _$ComposeDispenserFromJson(json);
}

// Params class for ComposeDispenser
@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenserParams {
  final String source;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final int status;
  final String? openAddress;
  final String? oracleAddress;
  final AssetInfoModel assetInfo;
  final String giveQuantityNormalized;
  final String escrowQuantityNormalized;

  ComposeDispenserParams({
    required this.source,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    this.openAddress,
    this.oracleAddress,
    required this.assetInfo,
    required this.giveQuantityNormalized,
    required this.escrowQuantityNormalized,
  });

  factory ComposeDispenserParams.fromJson(Map<String, dynamic> json) =>
      _$ComposeDispenserParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenserVerbose extends ComposeDispenser {
  @override
  final ComposeDispenserVerboseParams params;
  final int btcIn;
  final int btcOut;
  final int? btcChange;
  final int btcFee;
  final String data;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;
  ComposeDispenserVerbose({
    required super.rawtransaction,
    required super.name,
    required this.params,
    required this.btcIn,
    required this.btcOut,
    required this.btcChange,
    required this.btcFee,
    required this.data,
    required this.signedTxEstimatedSize,
  }) : super(params: params);

  factory ComposeDispenserVerbose.fromJson(Map<String, dynamic> json) =>
      _$ComposeDispenserVerboseFromJson(json);
}

// Verbose params class for ComposeDispenserVerbose
@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeDispenserVerboseParams extends ComposeDispenserParams {
  // final UnpackedData unpackedData;

  ComposeDispenserVerboseParams({
    required super.source,
    required super.asset,
    required super.giveQuantity,
    required super.escrowQuantity,
    required super.mainchainrate,
    required super.status,
    required super.assetInfo,
    required super.giveQuantityNormalized,
    required super.escrowQuantityNormalized,
    // required this.unpackedData,
  });

  factory ComposeDispenserVerboseParams.fromJson(Map<String, dynamic> json) =>
      _$ComposeDispenserVerboseParamsFromJson(json);
}

// Send
// {
//                 "tx_index": 2726604,
//                 "tx_hash": "b4bbb14c99dd260eb634243e5c595e1b7213459979857a32850de84989bb71ec",
//                 "block_index": 840459,
//                 "source": "13Hnmhs5gy2yXKVBx4wSM5HCBdKnaSBZJH",
//                 "destination": "1LfT83WAxbN9qKhtrXxcQA6xgdhfZk21Hz",
//                 "asset": "GAMESOFTRUMP",
//                 "quantity": 1,
//                 "status": "valid",
//                 "msg_index": 0,
//                 "memo": null,
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "",
//                     "issuer": "1JJP986hdU9Qy9b49rafM9FoXdbz1Mgbjo",
//                     "divisible": 0,
//                     "locked": 0
//                 },
//                 "quantity_normalized": "1"
//             }

@JsonSerializable(fieldRename: FieldRename.snake)
class Send {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final String asset;
  final int quantity;
  final String status;
  final int msgIndex;
  final String? memo;
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  const Send({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
    required this.status,
    required this.msgIndex,
    this.memo,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory Send.fromJson(Map<String, dynamic> json) => _$SendFromJson(json);
}

// Dispense
// {
//                 "tx_index": 2726580,
//                 "dispense_index": 0,
//                 "tx_hash": "e7f0f2c9bef7a492b714a5952ec61b283be344419c5bc33f405f9af41ebfa48b",
//                 "block_index": 840322,
//                 "source": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                 "destination": "bc1qzcdkhnexpjc8wvkyrpyrsn0f5xzcpu877mjmgj",
//                 "asset": "FLOCK",
//                 "dispense_quantity": 90000000000,
//                 "dispenser_tx_hash": "753787004d6e93e71f6e0aa1e0932cc74457d12276d53856424b2e4088cc542a",
//                 "dispenser": {
//                     "tx_index": 2536311,
//                     "block_index": 840322,
//                     "source": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                     "give_quantity": 10000000000,
//                     "escrow_quantity": 250000000000,
//                     "satoshirate": 330000,
//                     "status": 0,
//                     "give_remaining": 140000000000,
//                     "oracle_address": null,
//                     "last_status_tx_hash": null,
//                     "origin": "bc1qq735dv8peps2ayr3qwwwdwylq4ddwcgrpyg9r2",
//                     "dispense_count": 2,
//                     "give_quantity_normalized": "100",
//                     "give_remaining_normalized": "1400",
//                     "escrow_quantity_normalized": "2500"
//                 },
//                 "asset_info": {
//                     "asset_longname": null,
//                     "description": "",
//                     "issuer": "18VNeRv8vL528HF7ruKwxycrfNEeoqmHpa",
//                     "divisible": 1,
//                     "locked": 1
//                 }
//             }

@JsonSerializable(fieldRename: FieldRename.snake)
class Dispenser {
  final int txIndex;
  final int blockIndex;
  final String source;
  final int giveQuantity;
  final int escrowQuantity;
  final int satoshirate;
  final int status;
  final int giveRemaining;
  final String asset;
  final String? oracleAddress;
  final String? lastStatusTxHash;
  final String origin;
  final int dispenseCount;
  final String? giveQuantityNormalized;
  final String? giveRemainingNormalized;
  final String? escrowQuantityNormalized;

  const Dispenser({
    required this.txIndex,
    required this.blockIndex,
    required this.source,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.satoshirate,
    required this.status,
    required this.giveRemaining,
    required this.oracleAddress,
    required this.lastStatusTxHash,
    required this.origin,
    required this.asset,
    required this.dispenseCount,
    required this.giveQuantityNormalized,
    required this.giveRemainingNormalized,
    required this.escrowQuantityNormalized,
  });

  factory Dispenser.fromJson(Map<String, dynamic> json) =>
      _$DispenserFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Dispense {
  final int txIndex;
  final int dispenseIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final String asset;
  final int dispenseQuantity;
  final String dispenserTxHash;
  final Dispenser dispenser;
  final AssetInfoModel assetInfo;

  const Dispense({
    required this.txIndex,
    required this.dispenseIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.asset,
    required this.dispenseQuantity,
    required this.dispenserTxHash,
    required this.dispenser,
    required this.assetInfo,
  });

  factory Dispense.fromJson(Map<String, dynamic> json) =>
      _$DispenseFromJson(json);
}

// Sweep
// {
//                 "tx_index": 2720536,
//                 "tx_hash": "9309a4c0aed426e281a52e5d48acadd1464999269a5e75cf2293edd0277d743d",
//                 "block_index": 836519,
//                 "source": "1DMVnJuqBobXA9xYioabBsR4mN8bvVtCAW",
//                 "destination": "1HC2q92SfH1ZHzS4CrDwp6KAipV4FqUL4T",
//                 "flags": 3,
//                 "status": "valid",
//                 "memo": null,
//                 "fee_paid": 1400000
//             },
@JsonSerializable(fieldRename: FieldRename.snake)
class Sweep {
  final int txIndex;
  final String txHash;
  final int blockIndex;
  final String source;
  final String destination;
  final int flags;
  final String status;
  final String? memo;
  final int feePaid;

  const Sweep({
    required this.txIndex,
    required this.txHash,
    required this.blockIndex,
    required this.source,
    required this.destination,
    required this.flags,
    required this.status,
    this.memo,
    required this.feePaid,
  });

  factory Sweep.fromJson(Map<String, dynamic> json) => _$SweepFromJson(json);
}

// {
//             "rawtransaction": "01000000017004c1186a4a6a11708e1739839488180dbb6dbf4a9bf52228faa5b3173cdb05000000001976a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188acffffffff020000000000000000306a2e0d1e454cefefcbe167ffa672ce93608ec55d2594e5d1946a774e4e944f50dfb46943bffd3b68866791f7f496f8c270060406000000001976a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188ac00000000",
//             "params": {
//                 "source": "1CounterpartyXXXXXXXXXXXXXXXUWLpVr",
//                 "destination": "1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev",
//                 "asset": "XCP",
//                 "quantity": 1000,
//                 "memo": null,
//                 "memo_is_hex": false,
//                 "use_enhanced_send": true
//             },
//             "name": "send"
//         }

@JsonSerializable(fieldRename: FieldRename.snake)
class SendTxParams {
  final String source;
  final String destination;
  final String asset;
  final int quantity;
  final String? memo;
  final bool memoIsHex;
  final bool useEnhancedSend;
  const SendTxParams({
    required this.source,
    required this.destination,
    required this.asset,
    required this.quantity,
    this.memo,
    required this.memoIsHex,
    required this.useEnhancedSend,
  });
  factory SendTxParams.fromJson(Map<String, dynamic> json) =>
      _$SendTxParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SendTx {
  final String rawtransaction;
  final SendTxParams params;
  final String name;

  const SendTx({
    required this.rawtransaction,
    required this.params,
    required this.name,
  });

  factory SendTx.fromJson(Map<String, dynamic> json) => _$SendTxFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SendTxParamsVerbose extends SendTxParams {
  final AssetInfoModel assetInfo;
  final String quantityNormalized;

  const SendTxParamsVerbose({
    required super.source,
    required super.destination,
    required super.asset,
    required super.quantity,
    super.memo,
    required super.memoIsHex,
    required super.useEnhancedSend,
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory SendTxParamsVerbose.fromJson(Map<String, dynamic> json) =>
      _$SendTxParamsVerboseFromJson(json);

  // @override
  // Map<String, dynamic> toJson() => _$SendTxParamsVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SendTxVerbose extends SendTx {
  @override
  final SendTxParamsVerbose params;
  final int btcFee;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;

  const SendTxVerbose({
    required this.params,
    required super.rawtransaction,
    required this.btcFee,
    required super.name,
    required this.signedTxEstimatedSize,
  }) : super(params: params);

  factory SendTxVerbose.fromJson(Map<String, dynamic> json) =>
      _$SendTxVerboseFromJson(json);

  // @override
  // Map<String, dynamic> toJson() => _$SendTxVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ComposeMpmaSend {
  final String name;
  final String data;
  final String rawtransaction;
  final int btcIn;
  final int btcOut;
  final int btcFee;
  final int? btcChange;
  final SignedTxEstimatedSizeModel signedTxEstimatedSize;
  final MpmaSendParams params;

  const ComposeMpmaSend({
    required this.name,
    required this.data,
    required this.rawtransaction,
    required this.btcIn,
    required this.btcOut,
    required this.btcFee,
    this.btcChange,
    required this.params,
    required this.signedTxEstimatedSize,
  });

  factory ComposeMpmaSend.fromJson(Map<String, dynamic> json) =>
      _$ComposeMpmaSendFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendParams {
  final String source;
  final List<dynamic> assetDestQuantList;
  final String? memo;
  final bool? memoIsHex;
  final bool? skipValidation;

  const MpmaSendParams({
    required this.source,
    required this.assetDestQuantList,
    this.memo,
    this.memoIsHex,
    this.skipValidation,
  });

  factory MpmaSendParams.fromJson(Map<String, dynamic> json) =>
      _$MpmaSendParamsFromJson(json);
}

// @JsonSerializable(fieldRename: FieldRename.snake)
// class Unpack {
//   final String messageType;
//   final int messageTypeId;
//   final Map<String, dynamic> messageData;
//
//   const Unpack({
//     required this.messageType,
//     required this.messageTypeId,
//     required this.messageData,
//   });
//
//   factory Unpack.fromJson(Map<String, dynamic> json) => _$UnpackFromJson(json);
//
//   Map<String, dynamic> toJson() => _$UnpackToJson(this);
// }

class TransactionUnpacked {
  final String messageType;

  const TransactionUnpacked({required this.messageType});

  factory TransactionUnpacked.fromJson(Map<String, dynamic> json) {
    final messageType = json["message_type"];
    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendUnpacked.fromJson(json);
      case "issuance":
        return IssuanceUnpacked.fromJson(json);
      case "dispenser":
        return DispenserUnpacked.fromJson(json);
      default:
        return TransactionUnpacked(
          messageType: json["message_type"],
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "message_type": messageType,
    };
  }
}

class EnhancedSendUnpacked extends TransactionUnpacked {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;
  EnhancedSendUnpacked(
      {required this.asset,
      required this.quantity,
      required this.address,
      required this.memo})
      : super(
          messageType: "enhanced_send",
        );

  factory EnhancedSendUnpacked.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return EnhancedSendUnpacked(
        asset: messageData["asset"],
        quantity: messageData["quantity"],
        address: messageData["address"],
        memo: messageData["memo"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "enhanced_send",
      "message_data": {
        "asset": asset,
        "quantity": quantity,
        "address": address,
        "memo": memo,
      }
    };
  }
}

class DispenserUnpacked extends TransactionUnpacked {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final String status;

  DispenserUnpacked({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
  }) : super(messageType: "dispenser");

  factory DispenserUnpacked.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];
    return DispenserUnpacked(
      asset: messageData["asset"],
      giveQuantity: messageData["give_quantity"],
      escrowQuantity: messageData["escrow_quantity"],
      mainchainrate: messageData["mainchainrate"],
      status: messageData["status"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "dispenser",
      "message_data": {
        "asset": asset,
        "give_quantity": giveQuantity,
        "escrow_quantity": escrowQuantity,
        "mainchainrate": mainchainrate,
        "status": status,
      }
    };
  }
}

class TransactionUnpackedVerbose extends TransactionUnpacked {
  const TransactionUnpackedVerbose({required super.messageType});

  factory TransactionUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageType = json["message_type"];
    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedVerbose.fromJson(json);
      case "mpma_send":
        return MpmaSendUnpackedVerbose.fromJson(json);
      case "issuance":
        return IssuanceUnpackedVerbose.fromJson(json);
      case "dispenser":
        return DispenserUnpackedVerbose.fromJson(json);
      case "dispense":
        return DispenseUnpackedVerbose.fromJson(json);
      case "fairmint":
        return FairmintUnpackedVerbose.fromJson(json);
      case "fairminter":
        return FairminterUnpackedVerbose.fromJson(json);
      case "order":
        return OrderUnpackedVerbose.fromJson(json);
      case "cancel":
        return CancelUnpackedVerbose.fromJson(json);
      case "attach":
        return AttachUnpackedVerbose.fromJson(json);
      case "detach":
        return DetachUnpackedVerbose.fromJson(json);
      case null:
        return MoveToUtxoUnpackedVerbose.fromJson(json);
      case "destroy":
        return AssetDestructionUnpackedVerbose.fromJson(json);
      case "dividend":
        return AssetDividendUnpackedVerbose.fromJson(json);
      case "sweep":
        return SweepUnpackedVerbose.fromJson(json);
      default:
        return TransactionUnpackedVerbose(
          messageType: json["message_type"],
        );
    }
  }
}

class EnhancedSendUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;
  // final AssetInfo assetInfo;
  final String quantityNormalized;

  EnhancedSendUnpackedVerbose({
    required super.messageType,
    required this.asset,
    required this.quantity,
    required this.address,
    this.memo,
    // required this.assetInfo,
    required this.quantityNormalized,
  });

  factory EnhancedSendUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return EnhancedSendUnpackedVerbose(
        messageType: json["message_type"],
        asset: messageData["asset"],
        quantity: messageData["quantity"],
        address: messageData["address"],
        memo: messageData["memo"],
        // assetInfo: AssetInfo.fromJson(messageData["asset_info"]),
        quantityNormalized: messageData["quantity_normalized"]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "enhanced_send",
      "message_data": {
        "asset": asset,
        "quantity": quantity,
        "address": address,
        "memo": memo,
        // "asset_info": assetInfo.toJson(),
        "quantity_normalized": quantityNormalized,
      }
    };
  }
}

class DispenserUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final String status;
  final String giveQuantityNormalized;
  final String escrowQuantityNormalized;
  // final String mainchainrateNormalized;

  DispenserUnpackedVerbose({
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.status,
    required this.giveQuantityNormalized,
    required this.escrowQuantityNormalized,
    // required this.mainchainrateNormalized,
  }) : super(messageType: "dispenser");

  factory DispenserUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];
    return DispenserUnpackedVerbose(
      asset: messageData["asset"],
      giveQuantity: messageData["give_quantity"],
      escrowQuantity: messageData["escrow_quantity"],
      mainchainrate: messageData["mainchainrate"],
      status: messageData["status"],
      giveQuantityNormalized: messageData["give_quantity_normalized"],
      escrowQuantityNormalized: messageData["escrow_quantity_normalized"],
      // mainchainrateNormalized: messageData["mainchainrate_normalized"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "dispenser",
      "message_data": {
        "asset": asset,
        "give_quantity": giveQuantity,
        "escrow_quantity": escrowQuantity,
        "mainchainrate": mainchainrate,
        "status": status,
        "give_quantity_normalized": giveQuantityNormalized,
        "escrow_quantity_normalized": escrowQuantityNormalized,
        // "mainchainrate_normalized": mainchainrateNormalized,
      }
    };
  }
}

class DispenseUnpackedVerbose extends TransactionUnpackedVerbose {
  // final String mainchainrateNormalized;

  DispenseUnpackedVerbose() : super(messageType: "dispense");

  factory DispenseUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    return DispenseUnpackedVerbose();
  }

  @override
  Map<String, dynamic> toJson() {
    return {"message_type": "dispense", "message_data": {}};
  }
}

//
// "result": {
//     "source": "178etygrwEeeyQso9we85rUqYZbkiqzL4A",
//     "destination": "",
//     "btc_amount": 0,
//     "fee": 56565,
//     "data": "16010b9142801429a60000000000000001000000554e4e45474f544941424c45205745204d555354204245434f4d4520554e4e45474f544941424c4520574520415245",
//     "unpacked_data": {
//         "message_type": "issuance",
//         "message_type_id": 22,
//         "message_data": {
//             "asset_id": 75313533584419238,
//             "asset": "UNNEGOTIABLE",
//             "subasset_longname": null,
//             "quantity": 1,
//             "divisible": false,
//             "lock": false,
//             "reset": false,
//             "callable": false,jjjjjjjjjjjjjjjjjjjjjjjjjj
//             "call_date": 0,
//             "call_price": 0.0,
//             "description": "UNNEGOTIABLE WE MUST BECOME UNNEGOTIABLE WE ARE",
//             "status": "valid"
//         }
//     }
// }
@JsonSerializable(fieldRename: FieldRename.snake)
class Info {
  final String source;
  final String? destination;
  final int? btcAmount;
  final int? fee;
  final String data;
  final Map<String, dynamic>? decodedTx;
  // final TransactionUnpacked? unpackedData;

  const Info({
    required this.source,
    required this.destination,
    required this.btcAmount,
    required this.fee,
    required this.data,
    required this.decodedTx,
    // required this.unpackedData,
  });

  factory Info.fromJson(Map<String, dynamic> json) {
    final base = _$InfoFromJson(json);

    final unpackedData = json["unpacked_data"];

    if (unpackedData == null) {
      return base;
    }

    final messageType = unpackedData["message_type"];

    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendInfo.fromJson(json);
      case "issuance":
        return IssuanceInfo.fromJson(json);
      default:
        return base;
    }
  }

  // TODO: this doesnt actually show all the send data
  Map<String, dynamic> toJson() => _$InfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnhancedSendInfoUnpackedData {
  final String asset;
  final int quantity;
  final String address;
  final String? memo;

  const EnhancedSendInfoUnpackedData({
    required this.asset,
    required this.quantity,
    required this.address,
    this.memo,
  });

  factory EnhancedSendInfoUnpackedData.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendInfoUnpackedDataFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnhancedSendInfo extends Info {
  final EnhancedSendUnpacked unpackedData;

  EnhancedSendInfo({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required this.unpackedData,
  });

  factory EnhancedSendInfo.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IssuanceUnpacked extends TransactionUnpacked {
  final int assetId;
  final String asset;
  final String? subassetLongname;
  final int quantity;
  final bool divisible;
  final bool lock;
  final bool reset;
  final bool callable;
  final int callDate;
  final double callPrice;
  final String description;
  final String status;
  const IssuanceUnpacked({
    required this.assetId,
    required this.asset,
    this.subassetLongname,
    required this.quantity,
    required this.divisible,
    required this.lock,
    required this.reset,
    required this.callable,
    required this.callDate,
    required this.callPrice,
    required this.description,
    required this.status,
  }) : super(messageType: "issuance");

  factory IssuanceUnpacked.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return IssuanceUnpacked(
      assetId: messageData["asset_id"],
      asset: messageData["asset"],
      subassetLongname: messageData["subasset_longname"],
      quantity: messageData["quantity"],
      divisible: messageData["divisible"],
      lock: messageData["lock"],
      reset: messageData["reset"],
      callable: messageData["callable"],
      callDate: messageData["call_date"],
      callPrice: messageData["call_price"],
      description: messageData["description"],
      status: messageData["status"],
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IssuanceInfo extends Info {
  final IssuanceUnpacked unpackedData;
  IssuanceInfo({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    // super.unpackedData,
    required this.unpackedData,
  });
  factory IssuanceInfo.fromJson(Map<String, dynamic> json) =>
      _$IssuanceInfoFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class InfoVerbose extends Info {
  final String? btcAmountNormalized;

  const InfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    // super.unpackedData,
    required this.btcAmountNormalized,
  });

  factory InfoVerbose.fromJson(Map<String, dynamic> json) {
    final base = _$InfoVerboseFromJson(json);

    final unpackedData = json["unpacked_data"];

    if (unpackedData == null &&
        base.decodedTx != null &&
        base.decodedTx!["vin"].length > 1) {
      return MoveToUtxoInfoVerbose.fromJson(json);
    }

    final messageType = unpackedData["message_type"];

    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendInfoVerbose.fromJson(json);
      case "mpma_send":
        return MpmaSendInfoVerbose.fromJson(json);
      case "issuance":
        return IssuanceInfoVerbose.fromJson(json);
      case "dispenser":
        return DispenserInfoVerbose.fromJson(json);
      case "dispense":
        return DispenseInfoVerbose.fromJson(json);
      case "fairmint":
        return FairmintInfoVerbose.fromJson(json);
      case "fairminter":
        return FairminterInfoVerbose.fromJson(json);
      case "order":
        return OrderInfoVerbose.fromJson(json);
      case "cancel":
        return CancelInfoVerbose.fromJson(json);
      case "attach":
        return AttachInfoVerbose.fromJson(json);
      case "detach":
        return DetachInfoVerbose.fromJson(json);
      case null: // move to utxo is the only transaction type that does not have a message_type
        return MoveToUtxoInfoVerbose.fromJson(json);
      case "destroy":
        return AssetDestructionInfoVerbose.fromJson(json);
      case "dividend":
        return AssetDividendInfoVerbose.fromJson(json);
      case "sweep":
        return SweepInfoVerbose.fromJson(json);
      default:
        return base;
    }
  }

  @override
  Map<String, dynamic> toJson() => _$InfoVerboseToJson(this);
}

// @JsonSerializable(fieldRename: FieldRename.snake)
// class EnhancedSendInfoUnpackedDataVerbose extends EnhancedSendInfoUnpackedData {
//   final AssetInfo assetInfo;
//   final String quantityNormalized;
//
//   const EnhancedSendInfoUnpackedDataVerbose({
//     required super.asset,
//     required super.quantity,
//     required super.address,
//     super.memo,
//     required this.assetInfo,
//     required this.quantityNormalized,
//   });
//
//   factory EnhancedSendInfoUnpackedDataVerbose.fromJson(
//           Map<String, dynamic> json) =>
//       _$EnhancedSendInfoUnpackedDataVerboseFromJson(json);
// }

@JsonSerializable(fieldRename: FieldRename.snake)
class EnhancedSendInfoVerbose extends InfoVerbose {
  final EnhancedSendUnpackedVerbose unpackedData;

  const EnhancedSendInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory EnhancedSendInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EnhancedSendInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendInfoVerbose extends InfoVerbose {
  final MpmaSendUnpackedVerbose unpackedData;
  const MpmaSendInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory MpmaSendInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$MpmaSendInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MpmaSendInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendUnpackedVerbose extends TransactionUnpackedVerbose {
  final List<MpmaSendDestination> messageData;

  const MpmaSendUnpackedVerbose({
    required this.messageData,
  }) : super(messageType: "mpma_send");

  factory MpmaSendUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageDataList = (json["message_data"] as List)
        .map((data) => MpmaSendDestination.fromJson(data))
        .toList();

    return MpmaSendUnpackedVerbose(
      messageData: messageDataList,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        "message_type": "mpma_send",
        "message_data": messageData.map((d) => d.toJson()).toList(),
      };
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MpmaSendDestination {
  final String asset;
  final String destination;
  final int quantity;
  final String? memo;
  final bool? memoIsHex;
  final String? quantityNormalized;

  const MpmaSendDestination({
    required this.asset,
    required this.destination,
    required this.quantity,
    this.memo,
    this.memoIsHex,
    this.quantityNormalized,
  });

  factory MpmaSendDestination.fromJson(Map<String, dynamic> json) =>
      _$MpmaSendDestinationFromJson(json);

  Map<String, dynamic> toJson() => _$MpmaSendDestinationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IssuanceUnpackedVerbose extends TransactionUnpackedVerbose {
  final int assetId;
  final String asset;
  final String? subassetLongname;
  final int quantity;
  final bool divisible;
  final bool lock;
  final bool reset;
  final bool callable;
  final int callDate;
  final double callPrice;
  final String description;
  final String status;

  final String quantityNormalized;

  const IssuanceUnpackedVerbose(
      {required this.assetId,
      required this.asset,
      this.subassetLongname,
      required this.quantity,
      required this.divisible,
      required this.lock,
      required this.reset,
      required this.callable,
      required this.callDate,
      required this.callPrice,
      required this.description,
      required this.status,
      required this.quantityNormalized})
      : super(messageType: "issuance");

  factory IssuanceUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return IssuanceUnpackedVerbose(
        assetId: messageData["asset_id"],
        asset: messageData["asset"],
        subassetLongname: messageData["subasset_longname"],
        quantity: messageData["quantity"],
        divisible: messageData["divisible"],
        lock: messageData["lock"],
        reset: messageData["reset"],
        callable: messageData["callable"],
        callDate: messageData["call_date"],
        callPrice: messageData["call_price"],
        description: messageData["description"],
        status: messageData["status"],
        quantityNormalized: messageData["quantity_normalized"]);
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class IssuanceInfoVerbose extends InfoVerbose {
  final IssuanceUnpackedVerbose unpackedData;
  const IssuanceInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });
  factory IssuanceInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$IssuanceInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$IssuanceInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FairmintUnpackedVerbose extends TransactionUnpackedVerbose {
  final String? asset;
  final int? price;

  const FairmintUnpackedVerbose({
    required this.asset,
    required this.price,
  }) : super(messageType: "fairmint");

  factory FairmintUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return FairmintUnpackedVerbose(
      asset: messageData["asset"],
      price: messageData["quantity"],
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FairmintInfoVerbose extends InfoVerbose {
  final FairmintUnpackedVerbose unpackedData;
  const FairmintInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });
  factory FairmintInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$FairmintInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FairmintInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FairminterUnpackedVerbose extends TransactionUnpackedVerbose {
  final String? asset;

  const FairminterUnpackedVerbose({
    required this.asset,
  }) : super(messageType: "fairminter");

  factory FairminterUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return FairminterUnpackedVerbose(
      asset: messageData["asset"],
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class FairminterInfoVerbose extends InfoVerbose {
  final FairminterUnpackedVerbose unpackedData;
  const FairminterInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });
  factory FairminterInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$FairminterInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$FairminterInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenserInfoVerbose extends InfoVerbose {
  final DispenserUnpackedVerbose unpackedData;

  const DispenserInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory DispenserInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$DispenserInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DispenserInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DispenseInfoVerbose extends InfoVerbose {
  final DispenseUnpackedVerbose unpackedData;

  const DispenseInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory DispenseInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$DispenseInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DispenseInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderUnpackedVerbose extends TransactionUnpackedVerbose {
  final String giveAsset;
  final int giveQuantity;
  final String getAsset;
  final int getQuantity;
  final int expiration;
  final int feeRequired;
  final String status;
  final String giveQuantityNormalized;
  final String getQuantityNormalized;
  final String feeRequiredNormalized;
  // final AssetInfoModel giveAssetInfo;
  // final AssetInfoModel getAssetInfo;

  const OrderUnpackedVerbose({
    required this.giveAsset,
    required this.giveQuantity,
    required this.getAsset,
    required this.getQuantity,
    required this.expiration,
    required this.feeRequired,
    required this.status,
    required this.giveQuantityNormalized,
    required this.getQuantityNormalized,
    required this.feeRequiredNormalized,
    // required this.giveAssetInfo,
    // required this.getAssetInfo,
  }) : super(messageType: "order");

  factory OrderUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return OrderUnpackedVerbose(
      giveAsset: messageData["give_asset"],
      giveQuantity: messageData["give_quantity"],
      getAsset: messageData["get_asset"],
      getQuantity: messageData["get_quantity"],
      expiration: messageData["expiration"],
      feeRequired: messageData["fee_required"],
      status: messageData["status"],
      giveQuantityNormalized: messageData["give_quantity_normalized"],
      getQuantityNormalized: messageData["get_quantity_normalized"],
      feeRequiredNormalized: messageData["fee_required_normalized"],
      // giveAssetInfo: AssetInfoModel.fromJson(messageData["give_asset_info"]),
      // getAssetInfo: AssetInfoModel.fromJson(messageData["get_asset_info"]),
    );
  }

  @override
  Map<String, dynamic> toJson() => _$OrderUnpackedVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class OrderInfoVerbose extends InfoVerbose {
  final OrderUnpackedVerbose unpackedData;
  const OrderInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    super.decodedTx,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory OrderInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$OrderInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$OrderInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CancelInfoVerbose extends InfoVerbose {
  final CancelUnpackedVerbose unpackedData;

  const CancelInfoVerbose({
    required super.source,
    super.destination,
    super.btcAmount,
    super.fee,
    required super.data,
    required super.btcAmountNormalized,
    super.decodedTx,
    required this.unpackedData,
  });
  factory CancelInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$CancelInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$CancelInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CancelUnpackedVerbose extends TransactionUnpackedVerbose {
  final String offerHash;
  final String status;
  const CancelUnpackedVerbose({
    required this.offerHash,
    required this.status,
  }) : super(messageType: "cancel");

  factory CancelUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return CancelUnpackedVerbose(
      offerHash: messageData["offer_hash"],
      status: messageData["status"],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$CancelUnpackedVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachInfoVerbose extends InfoVerbose {
  final AttachUnpackedVerbose unpackedData;
  const AttachInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });
  factory AttachInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$AttachInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AttachInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttachUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final String quantityNormalized;
  final String? destinationVout;

  const AttachUnpackedVerbose({
    required this.asset,
    required this.quantityNormalized,
    this.destinationVout,
  }) : super(messageType: "attach");

  factory AttachUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return AttachUnpackedVerbose(
      asset: messageData["asset"],
      quantityNormalized: messageData["quantity_normalized"],
      destinationVout: messageData["destination_vout"],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$AttachUnpackedVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DetachInfoVerbose extends InfoVerbose {
  final DetachUnpackedVerbose unpackedData;
  const DetachInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });
  factory DetachInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$DetachInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$DetachInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class DetachUnpackedVerbose extends TransactionUnpackedVerbose {
  final String destination;

  const DetachUnpackedVerbose({
    required this.destination,
  }) : super(messageType: "detach");

  factory DetachUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];

    return DetachUnpackedVerbose(
      destination: messageData["destination"],
    );
  }

  @override
  Map<String, dynamic> toJson() => _$DetachUnpackedVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MoveToUtxoInfoVerbose extends InfoVerbose {
  const MoveToUtxoInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
  });

  factory MoveToUtxoInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$MoveToUtxoInfoVerboseFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$MoveToUtxoInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class MoveToUtxoUnpackedVerbose extends TransactionUnpackedVerbose {
  const MoveToUtxoUnpackedVerbose() : super(messageType: 'move_to_utxo');

  factory MoveToUtxoUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    return const MoveToUtxoUnpackedVerbose();
  }

  @override
  Map<String, dynamic> toJson() => _$MoveToUtxoUnpackedVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDestructionInfoVerbose extends InfoVerbose {
  final AssetDestructionUnpackedVerbose unpackedData;
  const AssetDestructionInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory AssetDestructionInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$AssetDestructionInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AssetDestructionInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDestructionUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final String quantityNormalized;
  final String tag;
  final int quantity;
  final AssetInfoModel? assetInfo;

  const AssetDestructionUnpackedVerbose({
    required this.asset,
    required this.quantityNormalized,
    required this.tag,
    required this.quantity,
    this.assetInfo,
  }) : super(messageType: "destroy");
  factory AssetDestructionUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];
    return AssetDestructionUnpackedVerbose(
      asset: messageData["asset"],
      quantityNormalized: messageData["quantity_normalized"],
      tag: messageData["tag"],
      quantity: messageData["quantity"],
      assetInfo: messageData["asset_info"] != null
          ? AssetInfoModel.fromJson(messageData["asset_info"])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "destroy",
      "message_data": {
        "asset": asset,
        "quantity_normalized": quantityNormalized,
        "tag": tag,
        "quantity": quantity,
        "asset_info": assetInfo?.toJson(),
      }
    };
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDividendInfoVerbose extends InfoVerbose {
  final AssetDividendUnpackedVerbose unpackedData;
  const AssetDividendInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory AssetDividendInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$AssetDividendInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AssetDividendInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetDividendUnpackedVerbose extends TransactionUnpackedVerbose {
  final String asset;
  final int quantityPerUnit;
  final String dividendAsset;
  final String status;
  const AssetDividendUnpackedVerbose({
    required this.asset,
    required this.quantityPerUnit,
    required this.dividendAsset,
    required this.status,
  }) : super(messageType: "dividend");

  factory AssetDividendUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];
    return AssetDividendUnpackedVerbose(
      asset: messageData["asset"],
      quantityPerUnit: messageData["quantity_per_unit"],
      dividendAsset: messageData["dividend_asset"],
      status: messageData["status"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "dividend",
      "message_data": {
        "asset": asset,
        "quantity_per_unit": quantityPerUnit,
        "dividend_asset": dividendAsset,
        "status": status,
      }
    };
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SweepInfoVerbose extends InfoVerbose {
  final SweepUnpackedVerbose unpackedData;
  const SweepInfoVerbose({
    required super.data,
    required super.source,
    required super.destination,
    required super.btcAmount,
    required super.fee,
    required super.btcAmountNormalized,
    required this.unpackedData,
  });

  factory SweepInfoVerbose.fromJson(Map<String, dynamic> json) =>
      _$SweepInfoVerboseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SweepInfoVerboseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SweepUnpackedVerbose extends TransactionUnpackedVerbose {
  final String destination;
  final int flags;
  final String memo;
  const SweepUnpackedVerbose({
    required this.destination,
    required this.flags,
    required this.memo,
  }) : super(messageType: "sweep");

  factory SweepUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageData = json["message_data"];
    return SweepUnpackedVerbose(
      destination: messageData["destination"],
      flags: messageData["flags"],
      memo: messageData["memo"],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "message_type": "sweep",
      "message_data": {
        "destination": destination,
        "flags": flags,
        "memo": memo,
      }
    };
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class UTXO {
  final int vout;
  final int height;
  final int value;
  final int confirmations;
  final double amount;
  final String txid;
  final String? address;

  const UTXO({
    required this.vout,
    required this.height,
    required this.value,
    required this.confirmations,
    required this.amount,
    required this.txid,
    this.address,
  });

  factory UTXO.fromJson(Map<String, dynamic> json) => _$UTXOFromJson(json);
}

@RestApi()
abstract class V2Api {
  factory V2Api(Dio dio, {String baseUrl}) = _V2Api;

  @GET("/bitcoin/estimatesmartfee")
  Future<Response<int>> estimateSmartFee(
      @Query("conf_target") int confirmationTarget);

  @POST("/bitcoin/transactions")
  Future<Response<String>> createTransaction(
    @Query("signedhex") String signedhex,
  );

  @GET("/bitcoin/transactions/decode")
  Future<Response<DecodedTxModel>> decodeTransaction(
    @Query("rawtx") String rawtx,
  );
  //     Get Balances by address
  @GET("/addresses/{address}/balances")
  Future<Response<List<Balance>>> getBalancesByAddress(
    @Path("address") String address,
    @Query("verbose") bool verbose, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/{address}/balances?verbose=true")
  Future<Response<List<BalanceVerbose>>> getBalancesByAddressVerbose(
    @Path("address") String address, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/balances")
  Future<Response<List<MultiAddressBalance>>> getBalancesByAddresses(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/balances?verbose=true")
  Future<Response<List<MultiAddressBalanceVerbose>>>
      getBalancesByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("asset") String? asset,
    @Query("type") String? type,
  ]);

  @GET("/utxos/{utxo}/balances?verbose=true")
  Future<Response<List<BalanceVerbose>>> getBalancesByUTXO(
    @Path("utxo") String utxo, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
  ]);
  // Counterparty API Root
  // Blocks
  //     Get Blocks
  @GET("/blocks")
  Future<Response<List<Block>>> getBlocks(
    @Query("limit") int limit,
    @Query("last") int last,
    @Query("verbose") bool verbose,
  );

  @GET("/blocks/last")
  Future<Response<Block>> getLastBlock();
  //     Get Block
  @GET("/blocks/{block_index}")
  Future<Response<Block>> getBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Transactions By Block
  @GET("/blocks/{block_index}/transactions")
  Future<Response<List<Transaction>>> getTransactionsByAddressByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Events By Block
  @GET("/blocks/{block_index}/events")
  Future<Response<List<Event>>> getEventsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Event Counts By Block
  @GET("/blocks/{block_index}/events/counts")
  Future<Response<List<EventCount>>> getEventCountsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Events By Block And Event
  @GET("/blocks/{block_index}/events/{event}")
  Future<Response<List<Event>>> getEventsByBlockAndEvent(
    @Path("block_index") int blockIndex,
    @Path("event") String event,
    @Query("verbose") bool verbose,
  );
  //     Get Credits By Block
  @GET("/blocks/{block_index}/credits")
  Future<Response<List<Credit>>> getCreditsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Debits By Block
  @GET("/blocks/{block_index}/debits")
  Future<Response<List<Debit>>> getDebitsByBlock(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Expirations
  @GET("/blocks/{block_index}/expirations")
  Future<Response<List<Expiration>>> getExpirations(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
  //     Get Cancels
  @GET("/blocks/{block_index}/cancels")
  Future<Response<List<Cancel>>> getCancels(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );
//     Get Destructions
//       {
//         "path": "/v2/blocks/<int:block_index>/destructions",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 839988)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the destructions of a block"
//       },

  @GET("/blocks/{block_index}/destructions")
  Future<Response<List<Destruction>>> getDestructions(
    @Path("block_index") int blockIndex,
    @Query("verbose") bool verbose,
  );

  //     Get Issuances By Block
  //     Get Sends By Block
  //     Get Dispenses By Block
  //     Get Sweeps By Block
  // Transactions
  //     Info

  @GET("/transactions/info")
  Future<Response<Info>> getTransactionInfo(
    @Query("rawtransaction") String rawtransaction, [
    @Query("block_index") int? blockIndex,
    @Query("verbose") bool? verbose,
  ]);

  @GET("/transactions/info?verbose=true")
  Future<Response<InfoVerbose>> getTransactionInfoVerbose(
    @Query("rawtransaction") String rawtransaction, [
    @Query("block_index") int? blockIndex,
    @Query("verbose") bool? verbose,
  ]);

  //     Unpack
// https://api.counterparty.io/transactions/unpack{?datahex}{&block_index}{&verbose}

  @GET("/transactions/unpack")
  Future<Response<TransactionUnpacked>> unpackTransaction(
    @Query("datahex") String datahex, [
    @Query("block_index") int? blockIndex,
    @Query("verbose") bool? verbose,
  ]);

  @GET("/transactions/unpack?verbose=true")
  Future<Response<TransactionUnpackedVerbose>> unpackTransactionVerbose(
    @Query("datahex") String datahex, [
    @Query("block_index") int? blockIndex,
    @Query("verbose") bool? verbose,
  ]);

  //     Get Transaction By Hash
  // Addresses
  //     Get Address Balances
  //     Get Balance By Address And Asset
  //     Get Credits By Address
  //     Get Debits By Address
  //     Get Bet By Feed
  //     Get Broadcasts By Source
  //     Get Burns By Address
  //     Get Send By Address
  //     Get Receive By Address
  //     Get Send By Address And Asset
  //     Get Receive By Address And Asset
  //     Get Dispensers By Address

  @GET("/addresses/{address}/dispensers")
  Future<Response<List<DispenserModel>>> getDispensersByAddress(
    @Path("address") String address, [
    @Query("verbose") bool? verbose,
    @Query("status") String? status,
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  //     Get Dispensers By Address And Asset
  //     Get Sweeps By Address
  // Compose
  //     Compose Be
  //     Compose Broadcast
  //     Compose BTCPay
  //     Compose Burn
  //     Compose Cancel
  //     Compose Destroy
  //     Compose Dispenser
  //     Compose Dividend
  //     Compose Issuance
  //     Compose MPMA
  //     Compose Order
  //     Compose Send

// GET
// https://api.counterparty.io/addresses/{address}/compose/send{?destination}{&asset}{&quantity}{&memo}{&memo_is_hex}{&use_enhanced_send}{&encoding}{&sat_per_vbyte}{&regular_dust_size}{&multisig_dust_size}{&pubkey}{&allow_unconfirmed_inputs}{&fee}{&fee_provided}{&unspent_tx_hash}{&dust_return_pubkey}{&disable_utxo_locks}{&extended_tx_info}{&p2sh_pretx_txid}{&segwit}{&verbose}

  @GET("/addresses/{address}/compose/send")
  Future<Response<SendTx>> composeSend(
    @Path("address") String address,
    @Query("destination") String destination,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("fee") int? fee,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
  ]);

  @GET("/addresses/{address}/compose/send?verbose=true")
  Future<Response<SendTxVerbose>> composeSendVerbose(
    @Path("address") String address,
    @Query("destination") String destination,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("validate") bool? validate,
  ]);

  @GET("/addresses/{address}/compose/mpma?verbose=true")
  Future<Response<ComposeMpmaSend>> composeMpmaSend(
    @Path("address") String address,
    @Query("destinations") String? destinations,
    @Query("assets") String? assets,
    @Query("quantities") String? quantities, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/sends")
  Future<Response<List<Send>>> getSendsByAddress(
    @Path("address") String address, [
    @Query("verbose") bool? verbose,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/{address}/issuances")
  Future<Response<List<Issuance>>> getIssuancesByAddress(
    @Path("address") String address, [
    @Query("verbose") bool? verbose,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/{address}/compose/issuance")
  Future<Response<ComposeIssuance>> composeIssuance(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("transfer_destination") String? transferDestination,
    @Query("divisible") bool? divisible,
    @Query("lock") bool? lock,
    @Query("reset") bool? reset,
    @Query("description") String? description,
    @Query("unconfirmed") bool? unconfirmed,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
  ]);

  @GET("/addresses/{address}/compose/issuance?verbose=true")
  Future<Response<ComposeIssuanceVerbose>> composeIssuanceVerbose(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("transfer_destination") String? transferDestination,
    @Query("divisible") bool? divisible,
    @Query("lock") bool? lock,
    @Query("reset") bool? reset,
    @Query("description") String? description,
    @Query("unconfirmed") bool? unconfirmed,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/orders?verbose=true")
  Future<Response<List<OrderVerbose>>> getOrdersByAddressVerbose(
    @Path("address") String address, [
    @Query("status") String? status,
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  @GET("/fairminters?verbose=true")
  Future<Response<List<FairminterModel>>> getAllFairminters([
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  @GET("/addresses/{address}/fairminters?verbose=true")
  Future<Response<List<FairminterModel>>> getFairmintersByAddress(
    @Path("address") String address, [
    @Query("status") String? status,
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  @GET("/assets/{asset}/fairminters?verbose=true")
  Future<Response<List<FairminterModel>>> getFairmintersByAsset(
    @Path("asset") String asset, [
    @Query("status") String? status,
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  @GET("/addresses/{address}/compose/fairmint?verbose=true")
  Future<Response<ComposeFairmintVerboseModel>> composeFairmintVerbose(
    @Path("address") String address,
    @Query("asset") String asset, [
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/fairminter?verbose=true")
  Future<Response<ComposeFairminterVerboseModel>> composeFairminterVerbose(
    @Path("address") String address,
    @Query("asset") String asset, [
    @Query("asset_parent") String? assetParent,
    @Query("divisible") bool? divisible,
    @Query("max_mint_per_tx") int? maxMintPerTx,
    @Query("hard_cap") int? hardCap,
    @Query("start_block") int? startBlock,
    @Query("end_block") int? endBlock,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("lock_quantity") bool? lockQuantity,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/dispenser?verbose=true")
  Future<Response<ComposeDispenserVerbose>> composeDispenserVerbose(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("give_quantity") int giveQuantity,
    @Query("escrow_quantity") int escrowQuantity,
    @Query("mainchainrate") int mainchainrate,
    @Query("status") int status, [
    @Query("open_address") String? openAddress,
    @Query("oracle_address") String? oracleAddress,
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("exact_fee") int? exactFee,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("unconfirmed") bool? unconfirmed,
    @Query("validate") bool? validate,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/order?verbose=true")
  Future<Response<ComposeOrderResponseModel>> composeOrder(
    @Path("address") String address,
    @Query("give_asset") String giveAsset,
    @Query("give_quantity") int giveQuantity,
    @Query("get_asset") String getAsset,
    @Query("get_quantity") int getQuantity,
    @Query("expiration") int expiration,
    @Query("fee_required") int feeRequired, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/addresses/{address}/compose/cancel?verbose=true")
  Future<Response<ComposeCancelResponseModel>> composeCancel(
    @Path("address") String address,
    @Query("offer_hash") String giveAsset, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/addresses/{address}/dispensers")
  Future<Response<List<Dispenser>>> getDispenserByAddress(
    @Path("address") String address, [
    @Query("status") String? status,
    @Query("limit") int? limit,
    @Query("cursor") CursorModel? cursor,
  ]);

  @GET("/addresses/{address}/compose/dispense?verbose=true")
  Future<Response<ComposeDispenseResponseModel>> composeDispense(
    @Path("address") String address,
    @Query("dispenser") String dispenser,
    @Query("quantity") int quantity, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/addresses/{address}/transactions")
  Future<Response<List<Transaction>>> getTransactionsByAddress(
    @Path("address") String address, [
    @Query("verbose") bool? verbose,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/{address}/assets/owned")
  Future<Response<List<Asset>>> getValidAssetsByOwner(
    @Path("address") String address, [
    @Query("named") String? named,
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  @GET("/addresses/{address}/assets/owned?verbose=true")
  Future<Response<List<AssetVerbose>>> getValidAssetsByOwnerVerbose(
    @Path("address") String address, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("offset") int? offset,
  ]);

  // @Verbose()
  @GET("/addresses/transactions?verbose=true")
  Future<Response<List<TransactionVerbose>>> getTransactionsByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/events")
  Future<Response<List<Event>>> getEventsByAddresses(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("event_name") String? eventName,
  ]);

  // @Verbose()
  @GET("/addresses/events?verbose=true")
  Future<Response<List<VerboseEvent>>> getEventsByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("event_name") String? eventName,
  ]);

  @GET("/addresses/mempool?verbose=true")
  Future<Response<List<VerboseEvent>>> getMempoolEventsByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") CursorModel? cursor,
    @Query("limit") int? limit,
    @Query("event_name") String? eventName,
  ]);

  @GET("/addresses/{address}/compose/dividend/estimatexcpfees")
  Future<Response<int>> estimateDividendXcpFees(
      @Path("address") String address, @Query("asset") String asset);

  @GET("/addresses/{address}/compose/sweep/estimatexcpfees")
  Future<Response<int>> estimateSweepXcpFees(@Path("address") String address);

  @GET("/addresses/{address}/compose/attach/estimatexcpfees")
  Future<Response<int>> estimateAttachXcpFees(@Path("address") String address);

  @GET("/addresses/{address}/compose/attach?verbose=true")
  Future<Response<ComposeAttachUtxoResponseModel>> composeAttachUtxo(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("destination_vout") String? destinationVout,
    @Query("skip_validation") bool? skipValidation,
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/utxos/{utxo}/compose/detach?verbose=true")
  Future<Response<ComposeDetachUtxoResponseModel>> composeDetachUtxo(
    @Path("utxo") String utxo, [
    @Query("destination") String? destination,
    @Query("skip_validation") bool? skipValidation,
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/utxos/{utxo}/compose/movetoutxo?verbose=true")
  Future<Response<ComposeMoveToUtxoResponseModel>> composeMoveToUtxo(
    @Path("utxo") String utxo, [
    @Query("destination") String? destination,
    @Query("skip_validation") bool? skipValidation,
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);
  @GET("/bitcoin/addresses/{address}/utxos")
  Future<Response<List<UTXO>>> getUnspentUTXOs(
    @Path("address") String address, [
    @Query("unconfirmed") bool? unconfirmed,
    @Query("unspent_tx_hash") String? unspentTxHash,
    @Query("verbose") bool? verbose,
  ]);

  @GET("/bitcoin/addresses/utxos")
  Future<Response<List<UTXO>>> getUnspentUTXOsByAddresses(
    @Query("addresses") String addresses, [
    @Query("unconfirmed") bool? unconfirmed,
    @Query("verbose") bool? verbose,
    @Query("limit") int? limit,
    @Query("cursor") CursorModel? cursor,
  ]);

  @GET("/assets/{asset}")
  Future<Response<Asset>> getAsset(@Path("asset") String asset);

  @GET("/assets/{asset}?verbose=true")
  Future<Response<AssetVerbose>> getAssetVerbose(
    @Path("asset") String asset, [
    @DioOptions() Options? options,
  ]);

  @GET("/addresses/{address}/balances/{asset}?verbose=true")
  Future<Response<List<BalanceVerbose>>> getBalancesForAddressAndAssetVerbose(
    @Path("address") String address,
    @Path("asset") String asset,
  );
  @GET("/")
  Future<Response<NodeInfoModel>> getNodeInfo();

  @GET("/addresses/{address}/compose/destroy?verbose=true")
  Future<Response<ComposeDestroyResponseModel>> composeDestroy(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("quantity") int quantity,
    @Query("tag") String tag, [
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/dividend?verbose=true")
  Future<Response<ComposeDividendResponseModel>> composeDividend(
    @Path("address") String address,
    @Query("asset") String asset,
    @Query("quantity_per_unit") int quantityPerUnit,
    @Query("dividend_asset") String dividendAsset, [
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/sweep?verbose=true")
  Future<Response<ComposeSweepResponseModel>> composeSweep(
    @Path("address") String address,
    @Query("destination") String destination,
    @Query("flags") int flags,
    @Query("memo") String memo, [
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
  ]);

  @GET("/addresses/{address}/compose/burn?verbose=true")
  Future<Response<ComposeBurnResponseModel>> composeBurn(
    @Path("address") String address,
    @Query("quantity") int quantity, [
    @Query("sat_per_vbyte") num? satPerVbyte,
    @Query("inputs_set") String? inputsSet,
    @Query("exclude_utxos_with_balances") bool? excludeUtxosWithBalances,
    @Query("disable_utxo_locks") bool? disableUtxoLocks,
    @Query("unconfirmed") bool? unconfirmed,
  ]);
}
