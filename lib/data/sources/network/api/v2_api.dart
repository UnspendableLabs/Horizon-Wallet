import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
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
  final int? nextCursor;
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
  final DateTime blockTime;
  final String previousBlockHash;
  final double difficulty;
  final String ledgerHash;
  final String txlistHash;
  final String messagesHash;

  const Block(
      {required this.blockIndex,
      required this.blockTime,
      required this.blockHash,
      required this.previousBlockHash,
      required this.difficulty,
      required this.ledgerHash,
      required this.txlistHash,
      required this.messagesHash});

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
  final bool confirmed;

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
  final String address;
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
  final AssetInfo assetInfo;

  BalanceVerbose(
      {required super.address,
      required super.quantity,
      required super.asset,
      required this.assetInfo,
      required this.quantityNormalized});

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
  final String address;
  final int quantity;
  final String quantityNormalized;
  MultiBalanceVerbose(
      {required this.address,
      required this.quantity,
      required this.quantityNormalized});

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
  final AssetInfo assetInfo;
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
  final int eventIndex;
  final String event;
  final String? txHash;
  final int? blockIndex;
  final bool confirmed;

  const Event({
    required this.eventIndex,
    required this.event,
    required this.txHash,
    this.blockIndex,
    required this.confirmed,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final eventType = json['event'] as String;
    switch (eventType) {
      case 'ENHANCED_SEND':
        return EnhancedSendEvent.fromJson(json);
      case 'CREDIT':
        return CreditEvent.fromJson(json);
      case 'DEBIT':
        return DebitEvent.fromJson(json);
      case 'NEW_TRANSACTION':
        return NewTransactionEvent.fromJson(json);
      case 'ASSET_ISSUANCE':
        return AssetIssuanceEvent.fromJson(json);
      default:
        return _$EventFromJson(json);
    }
  }
}

// {
//    "event_index": 5348402,
//    "event": "ASSET_ISSUANCE",
//    "params": {
//      "asset": "A12445442962327434604",
//      "asset_longname": null,
//      "block_index": 2867711,
//      "call_date": 0,
//      "call_price": 0,
//      "callable": false,
//      "description": "",
//      "divisible": true,
//      "fee_paid": 0,
//      "issuer": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//      "locked": false,
//      "quantity": 10,
//      "reset": false,
//      "source": "tb1qmlykf0ej29ane2874y38c46kezr7jywrw6jqr9",
//      "status": "valid",
//      "transfer": false,
//      "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//      "tx_index": 37585
//    },
//    "tx_hash": "8da5c658e8de942ca8352d318d5e9c41b7e9233d508fe3d38036376c99930067",
//    "block_index": 2867711,
//    "confirmed": true
//  },

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
    required super.confirmed,
    required this.params,
  });

  factory EnhancedSendEvent.fromJson(Map<String, dynamic> json) =>
      _$EnhancedSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreditEvent extends Event {
  final CreditParams params;

  CreditEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.confirmed,
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
    required super.confirmed,
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
    required super.confirmed,
    required this.params,
  });

  factory NewTransactionEvent.fromJson(Map<String, dynamic> json) =>
      _$NewTransactionEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetIssuanceParams {
  final String asset;
  final String? assetLongname;
  // final int blockIndex;
  // final int callDate;
  // final int callPrice;
  // final bool callable;
  // final String description;
  // final bool divisible;
  // final int feePaid;
  // final String issuer;
  // final bool locked;
  final int quantity;
  // final bool reset;
  final String source;
  // final String status;
  // final bool transfer;
  // final String txHash;
  // final int txIndex;

  AssetIssuanceParams({
    required this.asset,
    this.assetLongname,
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
    // required this.status,
    // required this.transfer,
    // required this.txHash,
    // required this.txIndex,
  });

  factory AssetIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$AssetIssuanceParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseAssetIssuanceParams extends AssetIssuanceParams {
  final int blockTime;
  // final AssetInfo assetInfo;
  final String quantityNormalized;
  final String feePaidNormalized;

  VerboseAssetIssuanceParams({
    required super.asset,
    super.assetLongname, // required super.blockIndex, required super.callDate, required super.callPrice, required super.callable, required super.description,
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
    // required this.assetInfo,
    required this.quantityNormalized,
    required this.feePaidNormalized,
  });

  factory VerboseAssetIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetIssuanceParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AssetIssuanceEvent extends Event {
  final AssetIssuanceParams params;

  AssetIssuanceEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.confirmed,
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
    required super.confirmed,
    required this.params,
  });

  factory VerboseAssetIssuanceEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseAssetIssuanceEventFromJson(json);
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
  final int blockTime;
  final AssetInfo assetInfo;
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
  final int blockTime;
  final AssetInfo assetInfo;
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
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseCreditParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseCreditParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseDebitParams extends DebitParams {
  final int blockTime;
  final AssetInfo assetInfo;
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
    required this.assetInfo,
    required this.quantityNormalized,
  });

  factory VerboseDebitParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseDebitParamsFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory VerboseNewTransactionParams.fromJson(Map<String, dynamic> json) =>
      _$VerboseNewTransactionParamsFromJson(json);
}

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class AssetInfo {
  final bool divisible;
  final String? assetLongname;
  final String description;
  final bool locked;
  final String? issuer;

  AssetInfo({
    required this.divisible,
    this.assetLongname,
    required this.description,
    required this.locked,
    this.issuer,
  });

  factory AssetInfo.fromJson(Map<String, dynamic> json) =>
      _$AssetInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AssetInfoToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseEvent extends Event {
  final int blockTime;

  VerboseEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.confirmed,
    required this.blockTime,
  });

  factory VerboseEvent.fromJson(Map<String, dynamic> json) {
    final eventType = json['event'] as String;
    switch (eventType) {
      case 'ENHANCED_SEND':
        return VerboseEnhancedSendEvent.fromJson(json);
      case 'CREDIT':
        return VerboseCreditEvent.fromJson(json);
      case 'DEBIT':
        return VerboseDebitEvent.fromJson(json);
      case 'NEW_TRANSACTION':
        return VerboseNewTransactionEvent.fromJson(json);
      case 'ASSET_ISSUANCE':
        return VerboseAssetIssuanceEvent.fromJson(json);
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
    required super.confirmed,
    required super.blockTime,
    required this.params,
  });

  factory VerboseEnhancedSendEvent.fromJson(Map<String, dynamic> json) =>
      _$VerboseEnhancedSendEventFromJson(json);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VerboseCreditEvent extends VerboseEvent {
  final VerboseCreditParams params;

  VerboseCreditEvent({
    required super.eventIndex,
    required super.event,
    required super.txHash,
    required super.blockIndex,
    required super.confirmed,
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
    required super.confirmed,
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
    required super.confirmed,
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
  final AssetInfo assetInfo;
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
  final AssetInfo assetInfo;
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
  final AssetInfo assetInfo;
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

@JsonSerializable()
class ComposeIssuanceParams {
  final String source;
  final String asset;
  final int quantity;
  final bool divisible;
  final bool lock;
  final String? description;
  final String? transferDestination;

  ComposeIssuanceParams({
    required this.source,
    required this.asset,
    required this.quantity,
    required this.divisible,
    required this.lock,
    this.description,
    this.transferDestination,
  });

  factory ComposeIssuanceParams.fromJson(Map<String, dynamic> json) =>
      _$ComposeIssuanceParamsFromJson(json);
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
  final AssetInfo assetInfo;
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
  final int satoshiRate;
  final int status;
  final int giveRemaining;
  final String? oracleAddress;
  final String? lastStatusTxHash;
  final String origin;
  final int dispenseCount;
  final String giveQuantityNormalized;
  final String giveRemainingNormalized;
  final String escrowQuantityNormalized;

  const Dispenser({
    required this.txIndex,
    required this.blockIndex,
    required this.source,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.satoshiRate,
    required this.status,
    required this.giveRemaining,
    required this.oracleAddress,
    required this.lastStatusTxHash,
    required this.origin,
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
  final AssetInfo assetInfo;

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
  final AssetInfo assetInfo;
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

  const SendTxVerbose({
    required this.params,
    required super.rawtransaction,
    required super.name,
  }) : super(params: params);

  factory SendTxVerbose.fromJson(Map<String, dynamic> json) =>
      _$SendTxVerboseFromJson(json);

  // @override
  // Map<String, dynamic> toJson() => _$SendTxVerboseToJson(this);
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

class TransactionUnpackedVerbose extends TransactionUnpacked {
  const TransactionUnpackedVerbose({required super.messageType});

  factory TransactionUnpackedVerbose.fromJson(Map<String, dynamic> json) {
    final messageType = json["message_type"];
    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendUnpackedVerbose.fromJson(json);
      case "issuance":
        return IssuanceUnpackedVerbose.fromJson(json);
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
  final String btcAmountNormalized;

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

    if (unpackedData == null) {
      return base;
    }

    final messageType = unpackedData["message_type"];

    switch (messageType) {
      case "enhanced_send":
        return EnhancedSendInfoVerbose.fromJson(json);
      case "issuance":
        return IssuanceInfoVerbose.fromJson(json);
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
class IssuanceUnpackedVerbose extends TransactionUnpackedVerbose {
  // TODO: should eventually include normalized

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

// {
//      "vout": 6,
//      "height": 833559,
//      "value": 34611,
//      "confirmations": 7083,
//      "amount": 0.00034611,
//      "txid": "98bef616ef265dd2f6004683e908d7df97e0c5f322cdf2fb2ebea9a9131cfa79"
//  },

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

// TODO: inject baseURL ( or make dynamic)
// @RestApi(baseUrl: dotenv.env[TESTNET_URL] as String)
@RestApi(baseUrl: "https://dev.counterparty.io:14000/v2")
// @RestApi(baseUrl: "http://localhost:24000/v2")
// @RestApi(baseUrl: "http://localhost:14000/v2")
abstract class V2Api {
  factory V2Api(Dio dio, {String baseUrl}) = _V2Api;

  @POST("/bitcoin/transactions")
  Future<Response<String>> createTransaction(
    @Query("signedhex") String signedhex,
  );
  //     Get Balances by address
  @GET("/addresses/{address}/balances")
  Future<Response<List<Balance>>> getBalancesByAddress(
    @Path("address") String address,
    @Query("verbose") bool verbose, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/{address}/balances?verbose=true")
  Future<Response<List<BalanceVerbose>>> getBalancesByAddressVerbose(
    @Path("address") String address, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/balances")
  Future<Response<List<MultiAddressBalance>>> getBalancesByAddresses(
    @Query("addresses") String addresses, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
  ]);

  @GET("/addresses/balances?verbose=true")
  Future<Response<List<MultiAddressBalanceVerbose>>>
      getBalancesByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
  ]);

  // Counterparty API Root
  // Blocks
  //     Get Blocks
  @GET("/blocks")
  Future<Response<List<Block>>> getBlocks(
    @Query("limit") int limit,
    @Query("last") int last,
    @Query("verbose") bool verbose, // TODO: validate bool parsing
  );
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
    @Query("rawtransaction") String rawtransaction,
    // TODO: add these back and make optional
    // @Query("block_index") int blockIndex,
    // @Query("verbose") bool verbose,
  );

  @GET("/transactions/info?verbose=true")
  Future<Response<InfoVerbose>> getTransactionInfoVerbose(
    @Query("rawtransaction") String rawtransaction,
    // TODO: add these back and make optional
    // @Query("block_index") int blockIndex,
    // @Query("verbose") bool verbose,
  );

  //     Unpack
// https://api.counterparty.io/transactions/unpack{?datahex}{&block_index}{&verbose}

  @GET("/transactions/unpack")
  Future<Response<TransactionUnpacked>> unpackTransaction(
    @Query("datahex") String datahex,
    // TODO: add these back and make optional
    // @Query("block_index") int blockIndex,
    // @Query("verbose") bool verbose,
  );

  @GET("/transactions/unpack?verbose=true")
  Future<Response<TransactionUnpackedVerbose>> unpackTransactionVerbose(
    @Query("datahex") String datahex,
    // TODO: add these back and make optional
    // @Query("block_index") int blockIndex,
    // @Query("verbose") bool verbose,
  );

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
// https://api.counterparty.io/addresses/{address}/compose/send{?destination}{&asset}{&quantity}{&memo}{&memo_is_hex}{&use_enhanced_send}{&encoding}{&fee_per_kb}{&regular_dust_size}{&multisig_dust_size}{&pubkey}{&allow_unconfirmed_inputs}{&fee}{&fee_provided}{&unspent_tx_hash}{&dust_return_pubkey}{&disable_utxo_locks}{&extended_tx_info}{&p2sh_pretx_txid}{&segwit}{&verbose}

// TODO add all query params
  @GET("/addresses/{address}/compose/send")
  Future<Response<SendTx>> composeSend(
    @Path("address") String address,
    @Query("destination") String destination,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("fee") int? fee,
  ]);

// TODO add all query params
  @GET("/addresses/{address}/compose/send?verbose=true")
  Future<Response<SendTxVerbose>> composeSendVerbose(
    @Path("address") String address,
    @Query("destination") String destination,
    @Query("asset") String asset,
    @Query("quantity") int quantity, [
    @Query("allow_unconfirmed_inputs") bool? allowUnconfirmedInputs,
    @Query("fee") int? fee,
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
    @Query("quantity") double quantity, [
    @Query("transferDestination") String? transferDestination,
    @Query("divisible") bool? divisible,
    @Query("lock") bool? lock,
    @Query("reset") bool? reset,
    @Query("description") String? description,
    @Query("unconfirmed") bool? unconfirmed,
  ]);

  @GET("/addresses/{address}/transactions")
  Future<Response<List<Transaction>>> getTransactionsByAddress(
    @Path("address") String address, [
    @Query("verbose") bool? verbose,
    @Query("limit") int? limit,
  ]);

  // @Verbose()
  @GET("/addresses/transactions?verbose=true")
  Future<Response<List<TransactionVerbose>>> getTransactionsByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
    @Query("show_unconfirmed") bool? showUnconfirmed,
  ]);

  @GET("/addresses/events")
  Future<Response<List<Event>>> getEventsByAddresses(
    @Query("addresses") String addresses, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
    @Query("show_unconfirmed") bool? showUnconfirmed,
  ]);

  // @Verbose()
  @GET("/addresses/events?verbose=true")
  Future<Response<List<VerboseEvent>>> getEventsByAddressesVerbose(
    @Query("addresses") String addresses, [
    @Query("cursor") int? cursor,
    @Query("limit") int? limit,
    @Query("show_unconfirmed") bool? showUnconfirmed,
  ]);

  // {
  //        "result": {
  //            "rawtransaction": "01000000017004c1186a4a6a11708e1739839488180dbb6dbf4a9bf52228faa5b3173cdb05000000001976a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188acffffffff020000000000000000306a2e0d1e454cefefcbe167ffa672ce93608ec55d2594e5d1946a774e4e944f50dfb46943bffd3b68866791f7f496f8c270060406000000001976a914818895f3dc2c178629d3d2d8fa3ec4a3f817982188ac00000000",
  //            "params": {
  //                "source": "1CounterpartyXXXXXXXXXXXXXXXUWLpVr",
  //                "destination": "1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev",
  //                "asset": "XCP",
  //                "quantity": 1000,
  //                "memo": null,
  //                "memo_is_hex": false,
  //                "use_enhanced_send": true
  //            },
  //            "name": "send"
  //        }
  //    }

  // @GET("/addresses/{address}/compose/send")
  // Future<Res
  //
  //     Compose Sweep
  // Assets
  //     Get Valid Assets
  //     Get Asset Info
  //     Get Asset Balances
  //     Get Balance By Address And Asset
  //     Get Orders By Asset
  //     Get Credits By Asset
  //     Get Debits By Asset
  //     Get Dividends
  //     Get Issuances By Asset
  //     Get Sends By Asset
  //     Get Dispensers By Asset
  //     Get Dispensers By Address And Asset
  //     Get Asset Holders
  // Orders
  //     Get Order
  //     Get Order Matches By Order
  //     Get BTCPays By Order
  //     Get Orders By Two Assets
  // Bets
  //     Get Bet
  //     Get Bet Matches By Bet
  //     Get Resolutions By Bet
  // Burns
  //     Get All Burns
  // Dispensers
  //     Get Dispenser Info By Hash
  //     Get Dispenses By Dispenser
  // Events
  //     Get All Events
  //     Get Event By Index
  //     Get All Events Counts
  //     Get Events By Name
  // Z-pages
  //     Check Server Health
  // Bitcoin
  //     Get Transactions By Address
  //     Get Oldest Transaction By Address
  //     Get Unspent Txouts
// https://api.counterparty.io/bitcoin/addresses/{address}/utxos{?unconfirmed}{&unspent_tx_hash}{&verbose}
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
    @Query("cursor") int? cursor,
  ]);

  //     PubKeyHash To Pubkey
  //  Counterparty API Root
  // Blocks
  //     Get Blocks
  //     Get Block
  //     Get Transactions By Block
  //     Get Events By Block
  //     Get Event Counts By Block
  //     Get Events By Block And Event
  //     Get Credits By Block
  //     Get Debits By Block
  //     Get Expirations
  //     Get Cancels
  //     Get Destructions
  //     Get Issuances By Block
  //     Get Sends By Block
  //     Get Dispenses By Block
  //     Get Sweeps By Block
  // Transactions
  //     Info
  //     Unpack
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
  //     Get Dispensers By Address And Asset
  //     Get Sweeps By Address
  // Compose
  //     Compose Bet
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
  //     Compose Sweep
  // Assets
  //     Get Valid Assets
  @GET("/assets/{asset}")
  Future<Response<Asset>> getAsset(@Path("asset") String asset);

  //     Get Asset Info
  //     Get Asset Balances
  //     Get Balance By Address And Asset
  //     Get Orders By Asset
  //     Get Credits By Asset
  //     Get Debits By Asset
  //     Get Dividends
  //     Get Issuances By Asset
  //     Get Sends By Asset
  //     Get Dispensers By Asset
  //     Get Dispensers By Address And Asset
  //     Get Asset Holders
  // Orders
  //     Get Order
  //     Get Order Matches By Order
  //     Get BTCPays By Order
  //     Get Orders By Two Assets
  // Bets
  //     Get Bet
  //     Get Bet Matches By Bet
  //     Get Resolutions By Bet
  // Burns
  //     Get All Burns
  // Dispensers
  //     Get Dispenser Info By Hash
  //     Get Dispenses By Dispenser
  // Events
  //     Get All Events
  //     Get Event By Index
  //     Get All Events Counts
  //     Get Events By Name
  // Z-pages
  //     Check Server Health
  // Bitcoin
  //     Get Transactions By Address
  //     Get Oldest Transaction By Address
  //     Get Unspent Txouts
  //     PubKeyHash To Pubkey
  //     Get Transaction
  //     Fee Per Kb
  // Mempool
  //     Get All Mempool Events
  //     Get Mempool Events By Name       Get Transaction
  //     Fee Per Kb
  // Mempool
  //     Get All Mempool Events
  //     Get Mempool Events By Name
  //

// {
//   "result": {
//     "server_ready": true,
//     "network": "mainnet",
//     "version": "10.1.2",
//     "backend_height": 842451,
//     "counterparty_height": 842451,
//     "routes": [
//       {
//         "path": "/v2/blocks",
//         "args": [
//           {
//             "name": "last",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "The index of the most recent block to return (e.g. 840000)"
//           },
//           {
//             "name": "limit",
//             "default": 10,
//             "required": false,
//             "type": "int",
//             "description": "The number of blocks to return (e.g. 2)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the list of the last ten blocks"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Return the information of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/transactions",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the transactions of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/events",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the events of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/events/counts",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the event counts of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/events/<event>",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "event",
//             "required": true,
//             "type": "str",
//             "description": "The event to filter by (e.g. CREDIT)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the events of a block filtered by event"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/credits",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the credits of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/debits",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the debits of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/expirations",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840356)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the expirations of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/cancels",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 839746)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the cancels of a block"
//       },
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
//       {
//         "path": "/v2/blocks/<int:block_index>/issuances",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840464)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the issuances of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/sends",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840459)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of sends to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the sends to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sends of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/dispenses",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 840322)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispenses of a block"
//       },
//       {
//         "path": "/v2/blocks/<int:block_index>/sweeps",
//         "args": [
//           {
//             "name": "block_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the block to return (e.g. 836519)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sweeps of a block"
//       },
//       {
//         "path": "/v2/transactions/info",
//         "args": [
//           {
//             "name": "rawtransaction",
//             "required": true,
//             "type": "str",
//             "description": "Raw transaction in hex format (e.g. 01000000017828697743c03aef6a3a8ba54b22bf579ffcab8161faf20e7b20c4ecd75cc986010000006b483045022100d1bd0531bb1ed2dd2cbf77d6933273e792a3dbfa84327d419169850ddd5976f502205d1ab0f7bcbf1a0cc183f0520c9aa8f711d41cb790c0c4ac39da6da4a093d798012103d3b1f711e907acb556e239f6cafb6a4f7fe40d8dd809b0e06e739c2afd73f202ffffffff0200000000000000004d6a4bf29880b93b0711524c7ef9c76835752088db8bd4113a3daf41fc45ffdc8867ebdbf26817fae377696f36790e52f51005806e9399a427172fedf348cf798ed86e548002ee96909eef0775ec3c2b0100000000001976a91443434cf159cc585fbd74daa9c4b833235b19761b88ac00000000)"
//           },
//           {
//             "name": "block_index",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "Block index mandatory for transactions before block 335000"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns Counterparty information from a raw transaction in hex format."
//       },
//       {
//         "path": "/v2/transactions/unpack",
//         "args": [
//           {
//             "name": "datahex",
//             "required": true,
//             "type": "str",
//             "description": "Data in hex format (e.g. 16010b9142801429a60000000000000001000000554e4e45474f544941424c45205745204d555354204245434f4d4520554e4e45474f544941424c4520574520415245)"
//           },
//           {
//             "name": "block_index",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "Block index of the transaction containing this data"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Unpacks Counterparty data in hex format and returns the message type and data."
//       },
//       {
//         "path": "/v2/transactions/<tx_hash>",
//         "args": [
//           {
//             "name": "tx_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction (e.g. 876a6cfbd4aa22ba4fa85c2e1953a1c66649468a43a961ad16ea4d5329e3e4c5)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns a transaction by its hash."
//       },
//       {
//         "path": "/v2/addresses/<address>/balances",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the balances of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/balances/<asset>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the balance of an address and asset"
//       },
//       {
//         "path": "/v2/addresses/<address>/credits",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of credits to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the credits to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the credits of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/debits",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. bc1q7787j6msqczs58asdtetchl3zwe8ruj57p9r9y)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of debits to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the debits to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the debits of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/bets",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address of the feed (e.g. 1QKEpuxEmdp428KEBSDZAKL46noSXWJBkk)"
//           },
//           {
//             "name": "status",
//             "default": "open",
//             "required": false,
//             "type": "str",
//             "description": "The status of the bet (e.g. filled)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the bets of a feed"
//       },
//       {
//         "path": "/v2/addresses/<address>/broadcasts",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1QKEpuxEmdp428KEBSDZAKL46noSXWJBkk)"
//           },
//           {
//             "name": "status",
//             "default": "valid",
//             "required": false,
//             "type": "str",
//             "description": "The status of the broadcasts to return (e.g. valid)"
//           },
//           {
//             "name": "order_by",
//             "default": "DESC",
//             "required": false,
//             "type": "str",
//             "description": "The order of the broadcasts to return (e.g. ASC)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the broadcasts of a source"
//       },
//       {
//         "path": "/v2/addresses/<address>/burns",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1HVgrYx3U258KwvBEvuG7R8ss1RN2Z9J1W)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the burns of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/sends",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1HVgrYx3U258KwvBEvuG7R8ss1RN2Z9J1W)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of sends to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the sends to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sends of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/receives",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of receives to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the receives to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the receives of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/sends/<asset>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1HVgrYx3U258KwvBEvuG7R8ss1RN2Z9J1W)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sends of an address and asset"
//       },
//       {
//         "path": "/v2/addresses/<address>/receives/<asset>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of receives to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the receives to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the receives of an address and asset"
//       },
//       {
//         "path": "/v2/addresses/<address>/dispensers",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. bc1qlzkcy8c5fa6y6xvd8zn4axnvmhndfhku3hmdpz)"
//           },
//           {
//             "name": "status",
//             "default": 0,
//             "required": false,
//             "type": "int"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispensers of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/dispensers/<asset>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. bc1qlzkcy8c5fa6y6xvd8zn4axnvmhndfhku3hmdpz)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. ERYKAHPEPU)"
//           },
//           {
//             "name": "status",
//             "default": 0,
//             "required": false,
//             "type": "int"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispensers of an address and an asset"
//       },
//       {
//         "path": "/v2/addresses/<address>/sweeps",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 18szqTVJUWwYrtRHq98Wn4DhCGGiy3jZ87)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sweeps of an address"
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/bet",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will make the bet (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "feed_address",
//             "required": true,
//             "type": "str",
//             "description": "The address that hosts the feed to be bet on (e.g. 1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev)"
//           },
//           {
//             "name": "bet_type",
//             "required": true,
//             "type": "int",
//             "description": "Bet 0 for Bullish CFD (deprecated), 1 for Bearish CFD (deprecated), 2 for Equal, 3 for NotEqual (e.g. 2)"
//           },
//           {
//             "name": "deadline",
//             "required": true,
//             "type": "int",
//             "description": "The time at which the bet should be decided/settled, in Unix time (seconds since epoch) (e.g. 3000000000)"
//           },
//           {
//             "name": "wager_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantities of XCP to wager (in satoshis, hence integer) (e.g. 1000)"
//           },
//           {
//             "name": "counterwager_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The minimum quantities of XCP to be wagered against, for the bets to match (e.g. 1000)"
//           },
//           {
//             "name": "expiration",
//             "required": true,
//             "type": "int",
//             "description": "The number of blocks after which the bet expires if it remains unmatched (e.g. 100)"
//           },
//           {
//             "name": "leverage",
//             "default": 5040,
//             "required": false,
//             "type": "int",
//             "description": "Leverage, as a fraction of 5040"
//           },
//           {
//             "name": "target_value",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "Target value for Equal/NotEqual bet (e.g. 1000)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to issue a bet against a feed."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/broadcast",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending (must have the necessary quantity of the specified asset) (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "timestamp",
//             "required": true,
//             "type": "int",
//             "description": "The timestamp of the broadcast, in Unix time (e.g. 4003903983)"
//           },
//           {
//             "name": "value",
//             "required": true,
//             "type": "float",
//             "description": "Numerical value of the broadcast (e.g. 100)"
//           },
//           {
//             "name": "fee_fraction",
//             "required": true,
//             "type": "float",
//             "description": "How much of every bet on this feed should go to its operator; a fraction of 1, (i.e. 0.05 is five percent) (e.g. 0.05)"
//           },
//           {
//             "name": "text",
//             "required": true,
//             "type": "str",
//             "description": "The textual part of the broadcast (e.g. \"Hello, world!\")"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to broadcast textual and numerical information to the network."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/btcpay",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending the payment (e.g. bc1qsteve3tfxfg9pcmvzw645sr9zy7es5rx645p6l)"
//           },
//           {
//             "name": "order_match_id",
//             "required": true,
//             "type": "str",
//             "description": "The ID of the order match to pay for (e.g. e470416a9500fb046835192da013f48e6468a07dba1bede4a0b68e666ed23c8d_4953bde3d9417b103615c2d3d4b284d4fcf7cbd820e5dd19ac0084e9ebd090b2)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to pay for a BTC order match."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/burn",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address with the BTC to burn (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantities of BTC to burn (1 BTC maximum burn per address) (e.g. 1000)"
//           },
//           {
//             "name": "overburn",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Whether to allow the burn to exceed 1 BTC for the address"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to burn a given quantity of BTC for XCP (on mainnet, possible between blocks 278310 and 283810; on testnet it is still available)."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/cancel",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that placed the order/bet to be cancelled (e.g. 15e15ua6A3FJqjMevtrWcFSzKn9k6bMQeA)"
//           },
//           {
//             "name": "offer_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the order/bet to be cancelled (e.g. 8ce3335391bf71f8f12c0573b4f85b9adc4882a9955d9f8e5ababfdd0060279a)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to cancel an open order or bet."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/destroy",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending the asset to be destroyed (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to be destroyed (e.g. XCP)"
//           },
//           {
//             "name": "quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset to be destroyed (e.g. 1000)"
//           },
//           {
//             "name": "tag",
//             "required": true,
//             "type": "str",
//             "description": "A tag for the destruction (e.g. \"bugs!\")"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to destroy a quantity of an asset."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/dispenser",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be dispensing (must have the necessary escrow_quantity of the specified asset) (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset or subasset to dispense (e.g. XCP)"
//           },
//           {
//             "name": "give_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset to dispense (e.g. 1000)"
//           },
//           {
//             "name": "escrow_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset to reserve for this dispenser (e.g. 1000)"
//           },
//           {
//             "name": "mainchainrate",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the main chain asset (BTC) per dispensed portion (e.g. 100)"
//           },
//           {
//             "name": "status",
//             "required": true,
//             "type": "int",
//             "description": "The state of the dispenser. 0 for open, 1 for open using open_address, 10 for closed (e.g. 0)"
//           },
//           {
//             "name": "open_address",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "The address that you would like to open the dispenser on"
//           },
//           {
//             "name": "oracle_address",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "The address that you would like to use as a price oracle for this dispenser"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Opens or closes a dispenser for a given asset at a given rate of main chain asset (BTC). Escrowed quantity on open must be equal or greater than give_quantity. It is suggested that you escrow multiples of give_quantity to ease dispenser operation."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/dividend",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be issuing the dividend (must have the ownership of the asset which the dividend is being issued on) (e.g. 1GQhaWqejcGJ4GhQar7SjcCfadxvf5DNBD)"
//           },
//           {
//             "name": "quantity_per_unit",
//             "required": true,
//             "type": "int",
//             "description": "The amount of dividend_asset rewarded (e.g. 1)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset or subasset that the dividends are being rewarded on (e.g. PEPECASH)"
//           },
//           {
//             "name": "dividend_asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset or subasset that the dividends are paid in (e.g. XCP)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to issue a dividend to holders of a given asset."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/issuance",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be issuing or transfering the asset (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The assets to issue or transfer. This can also be a subasset longname for new subasset issuances (e.g. XCPTEST)"
//           },
//           {
//             "name": "quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset to issue (set to 0 if transferring an asset) (e.g. 1000)"
//           },
//           {
//             "name": "transfer_destination",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "The address to receive the asset (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "divisible",
//             "default": true,
//             "required": false,
//             "type": "bool",
//             "description": "Whether this asset is divisible or not (if a transfer, this value must match the value specified when the asset was originally issued)"
//           },
//           {
//             "name": "lock",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Whether this issuance should lock supply of this asset forever"
//           },
//           {
//             "name": "reset",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Wether this issuance should reset any existing supply"
//           },
//           {
//             "name": "description",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "A textual description for the asset"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to Issue a new asset, issue more of an existing asset, lock an asset, reset existing supply, or transfer the ownership of an asset."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/mpma",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending (must have the necessary quantity of the specified asset) (e.g. 1Fv87qmdtjQDP9d4p9E5ncBQvYB4a3Rhy6)"
//           },
//           {
//             "name": "assets",
//             "required": true,
//             "type": "str",
//             "description": "comma-separated list of assets to send (e.g. BAABAABLKSHP,BADHAIRDAY,BADWOJAK)"
//           },
//           {
//             "name": "destinations",
//             "required": true,
//             "type": "str",
//             "description": "comma-separated list of addresses to send to (e.g. 1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev,1GQhaWqejcGJ4GhQar7SjcCfadxvf5DNBD,1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "quantities",
//             "required": true,
//             "type": "str",
//             "description": "comma-separated list of quantities to send (e.g. 1,2,3)"
//           },
//           {
//             "name": "memo",
//             "required": true,
//             "type": "str",
//             "description": "The Memo associated with this transaction (e.g. \"Hello, world!\")"
//           },
//           {
//             "name": "memo_is_hex",
//             "required": true,
//             "type": "bool",
//             "description": "Whether the memo field is a hexadecimal string (e.g. False)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to send multiple payments to multiple addresses."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/order",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be issuing the order request (must have the necessary quantity of the specified asset to give) (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "give_asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset that will be given in the trade (e.g. XCP)"
//           },
//           {
//             "name": "give_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset that will be given (e.g. 1000)"
//           },
//           {
//             "name": "get_asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset that will be received in the trade (e.g. PEPECASH)"
//           },
//           {
//             "name": "get_quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset that will be received (e.g. 1000)"
//           },
//           {
//             "name": "expiration",
//             "required": true,
//             "type": "int",
//             "description": "The number of blocks for which the order should be valid (e.g. 100)"
//           },
//           {
//             "name": "fee_required",
//             "required": true,
//             "type": "int",
//             "description": "The miners’ fee required to be paid by orders for them to match this one; in BTC; required only if buying BTC (may be zero, though) (e.g. 100)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to place an order on the distributed exchange."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/send",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending (must have the necessary quantity of the specified asset) (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "destination",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be receiving the asset (e.g. 1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset or subasset to send (e.g. XCP)"
//           },
//           {
//             "name": "quantity",
//             "required": true,
//             "type": "int",
//             "description": "The quantity of the asset to send (e.g. 1000)"
//           },
//           {
//             "name": "memo",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "The Memo associated with this transaction"
//           },
//           {
//             "name": "memo_is_hex",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Whether the memo field is a hexadecimal string"
//           },
//           {
//             "name": "use_enhanced_send",
//             "default": true,
//             "required": false,
//             "type": "bool",
//             "description": "If this is false, the construct a legacy transaction sending bitcoin dust"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to send a quantity of an asset to another address."
//       },
//       {
//         "path": "/v2/addresses/<address>/compose/sweep",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address that will be sending (e.g. 1CounterpartyXXXXXXXXXXXXXXXUWLpVr)"
//           },
//           {
//             "name": "destination",
//             "required": true,
//             "type": "str",
//             "description": "The address to receive the assets and/or ownerships (e.g. 1JDogZS6tQcSxwfxhv6XKKjcyicYA4Feev)"
//           },
//           {
//             "name": "flags",
//             "required": true,
//             "type": "int",
//             "description": "An OR mask of flags indicating how the sweep should be processed. Possible flags are:\n- FLAG_BALANCES: (integer) 1, specifies that all balances should be transferred.\n- FLAG_OWNERSHIP: (integer) 2, specifies that all ownerships should be transferred.\n- FLAG_BINARY_MEMO: (integer) 4, specifies that the memo is in binary/hex form.\n(e.g. 7)"
//           },
//           {
//             "name": "memo",
//             "required": true,
//             "type": "str",
//             "description": "The Memo associated with this transaction in hex format (e.g. FFFF)"
//           },
//           {
//             "name": "encoding",
//             "type": "str",
//             "default": "auto",
//             "description": "The encoding method to use",
//             "required": false
//           },
//           {
//             "name": "fee_per_kb",
//             "type": "int",
//             "default": null,
//             "description": "The fee per kilobyte of transaction data constant that the server uses when deciding on the dynamic fee to use (in satoshis)",
//             "required": false
//           },
//           {
//             "name": "regular_dust_size",
//             "type": "int",
//             "default": 546,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each non-(bare) multisig output.",
//             "required": false
//           },
//           {
//             "name": "multisig_dust_size",
//             "type": "int",
//             "default": 1000,
//             "description": "Specify (in satoshis) to override the (dust) amount of BTC used for each (bare) multisig output",
//             "required": false
//           },
//           {
//             "name": "pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The hexadecimal public key of the source address (or a list of the keys, if multi-sig). Required when using encoding parameter values of multisig or pubkeyhash.",
//             "required": false
//           },
//           {
//             "name": "allow_unconfirmed_inputs",
//             "type": "bool",
//             "default": false,
//             "description": "Set to true to allow this transaction to utilize unconfirmed UTXOs as inputs",
//             "required": false
//           },
//           {
//             "name": "fee",
//             "type": "int",
//             "default": null,
//             "description": "If you'd like to specify a custom miners' fee, specify it here (in satoshis). Leave as default for the server to automatically choose",
//             "required": false
//           },
//           {
//             "name": "fee_provided",
//             "type": "int",
//             "default": 0,
//             "description": "If you would like to specify a maximum fee (up to and including which may be used as the transaction fee), specify it here (in satoshis). This differs from fee in that this is an upper bound value, which fee is an exact value",
//             "required": false
//           },
//           {
//             "name": "unspent_tx_hash",
//             "type": "str",
//             "default": null,
//             "description": "When compiling the UTXOs to use as inputs for the transaction being created, only consider unspent outputs from this specific transaction hash. Defaults to null to consider all UTXOs for the address. Do not use this parameter if you are specifying custom_inputs",
//             "required": false
//           },
//           {
//             "name": "dust_return_pubkey",
//             "type": "str",
//             "default": null,
//             "description": "The dust return pubkey is used in multi-sig data outputs (as the only real pubkey) to make those the outputs spendable. By default, this pubkey is taken from the pubkey used in the first transaction input. However, it can be overridden here (and is required to be specified if a P2SH input is used and multisig is used as the data output encoding.) If specified, specify the public key (in hex format) where dust will be returned to so that it can be reclaimed. Only valid/useful when used with transactions that utilize multisig data encoding. Note that if this value is set to false, this instructs counterparty-server to use the default dust return pubkey configured at the node level. If this default is not set at the node level, the call will generate an exception",
//             "required": false
//           },
//           {
//             "name": "disable_utxo_locks",
//             "type": "bool",
//             "default": false,
//             "description": "By default, UTXOs utilized when creating a transaction are 'locked' for a few seconds, to prevent a case where rapidly generating create_ calls reuse UTXOs due to their spent status not being updated in bitcoind yet. Specify true for this parameter to disable this behavior, and not temporarily lock UTXOs",
//             "required": false
//           },
//           {
//             "name": "extended_tx_info",
//             "type": "bool",
//             "default": false,
//             "description": "When this is not specified or false, the create_ calls return only a hex-encoded string. If this is true, the create_ calls return a data object with the following keys: tx_hex, btc_in, btc_out, btc_change, and btc_fee",
//             "required": false
//           },
//           {
//             "name": "p2sh_pretx_txid",
//             "type": "str",
//             "default": null,
//             "description": "The previous transaction txid for a two part P2SH message. This txid must be taken from the signed transaction",
//             "required": false
//           },
//           {
//             "name": "segwit",
//             "type": "bool",
//             "default": false,
//             "description": "Use segwit",
//             "required": false
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Composes a transaction to Sends all assets and/or transfer ownerships to a destination address."
//       },
//       {
//         "path": "/v2/assets",
//         "args": [
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the assets to return (e.g. 0)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The limit of the assets to return (e.g. 5)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the valid assets"
//       },
//       {
//         "path": "/v2/assets/<asset>",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. UNNEGOTIABLE)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the asset information"
//       },
//       {
//         "path": "/v2/assets/<asset>/balances",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. UNNEGOTIABLE)"
//           },
//           {
//             "name": "exclude_zero_balances",
//             "default": true,
//             "required": false,
//             "type": "bool",
//             "description": "Whether to exclude zero balances (e.g. True)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the asset balances"
//       },
//       {
//         "path": "/v2/assets/<asset>/balances/<address>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. 1C3uGcoSGzKVgFqyZ3kM2DBq9CYttTMAVs)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the balance of an address and asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/orders",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. NEEDPEPE)"
//           },
//           {
//             "name": "status",
//             "default": "open",
//             "required": false,
//             "type": "str",
//             "description": "The status of the orders to return (e.g. filled)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the orders of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/credits",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. UNNEGOTIABLE)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of credits to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the credits to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the credits of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/debits",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of debits to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the debits to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the debits of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/dividends",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. GMONEYPEPE)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dividends of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/issuances",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. UNNEGOTIABLE)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the issuances of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/sends",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. XCP)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of sends to return (e.g. 5)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the sends to return (e.g. 0)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the sends of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/dispensers",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. ERYKAHPEPU)"
//           },
//           {
//             "name": "status",
//             "default": 0,
//             "required": false,
//             "type": "int"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispensers of an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/dispensers/<address>",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to return (e.g. bc1qlzkcy8c5fa6y6xvd8zn4axnvmhndfhku3hmdpz)"
//           },
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. ERYKAHPEPU)"
//           },
//           {
//             "name": "status",
//             "default": 0,
//             "required": false,
//             "type": "int"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispensers of an address and an asset"
//       },
//       {
//         "path": "/v2/assets/<asset>/holders",
//         "args": [
//           {
//             "name": "asset",
//             "required": true,
//             "type": "str",
//             "description": "The asset to return (e.g. ERYKAHPEPU)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the holders of an asset"
//       },
//       {
//         "path": "/v2/orders/<order_hash>",
//         "args": [
//           {
//             "name": "order_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the order (e.g. 23f68fdf934e81144cca31ce8ef69062d553c521321a039166e7ba99aede0776)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the information of an order"
//       },
//       {
//         "path": "/v2/orders/<order_hash>/matches",
//         "args": [
//           {
//             "name": "order_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the order (e.g. 5461e6f99a37a7167428b4a720a52052cd9afed43905f818f5d7d4f56abd0947)"
//           },
//           {
//             "name": "status",
//             "default": "pending",
//             "required": false,
//             "type": "str",
//             "description": "The status of the order matches to return (e.g. completed)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the order matches of an order"
//       },
//       {
//         "path": "/v2/orders/<order_hash>/btcpays",
//         "args": [
//           {
//             "name": "order_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the order (e.g. 299b5b648f54eacb839f3487232d49aea373cdd681b706d4cc0b5e0b03688db4)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the BTC pays of an order"
//       },
//       {
//         "path": "/v2/orders/<asset1>/<asset2>",
//         "args": [
//           {
//             "name": "asset1",
//             "required": true,
//             "type": "str",
//             "description": "The first asset to return (e.g. NEEDPEPE)"
//           },
//           {
//             "name": "asset2",
//             "required": true,
//             "type": "str",
//             "description": "The second asset to return (e.g. XCP)"
//           },
//           {
//             "name": "status",
//             "default": "open",
//             "required": false,
//             "type": "str",
//             "description": "The status of the orders to return (e.g. filled)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the orders to exchange two assets"
//       },
//       {
//         "path": "/v2/bets/<bet_hash>",
//         "args": [
//           {
//             "name": "bet_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the bet (e.g. 5d097b4729cb74d927b4458d365beb811a26fcee7f8712f049ecbe780eb496ed)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the information of a bet"
//       },
//       {
//         "path": "/v2/bets/<bet_hash>/matches",
//         "args": [
//           {
//             "name": "bet_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the bet (e.g. 5d097b4729cb74d927b4458d365beb811a26fcee7f8712f049ecbe780eb496ed)"
//           },
//           {
//             "name": "status",
//             "default": "pending",
//             "required": false,
//             "type": "str",
//             "description": "The status of the bet matches (e.g. expired)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the bet matches of a bet"
//       },
//       {
//         "path": "/v2/bets/<bet_hash>/resolutions",
//         "args": [
//           {
//             "name": "bet_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the transaction that created the bet (e.g. 36bbbb7dbd85054dac140a8ad8204eda2ee859545528bd2a9da69ad77c277ace)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the resolutions of a bet"
//       },
//       {
//         "path": "/v2/burns",
//         "args": [
//           {
//             "name": "status",
//             "default": "valid",
//             "required": false,
//             "type": "str",
//             "description": "The status of the burns to return (e.g. valid)"
//           },
//           {
//             "name": "offset",
//             "default": 0,
//             "required": false,
//             "type": "int",
//             "description": "The offset of the burns to return (e.g. 10)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The limit of the burns to return (e.g. 5)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the burns"
//       },
//       {
//         "path": "/v2/dispensers/<dispenser_hash>",
//         "args": [
//           {
//             "name": "dispenser_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the dispenser to return (e.g. 753787004d6e93e71f6e0aa1e0932cc74457d12276d53856424b2e4088cc542a)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispenser information by tx_hash"
//       },
//       {
//         "path": "/v2/dispensers/<dispenser_hash>/dispenses",
//         "args": [
//           {
//             "name": "dispenser_hash",
//             "required": true,
//             "type": "str",
//             "description": "The hash of the dispenser to return (e.g. 753787004d6e93e71f6e0aa1e0932cc74457d12276d53856424b2e4088cc542a)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the dispenses of a dispenser"
//       },
//       {
//         "path": "/v2/events",
//         "args": [
//           {
//             "name": "last",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "The last event index to return (e.g. 10665092)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of events to return (e.g. 5)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns all events"
//       },
//       {
//         "path": "/v2/events/<int:event_index>",
//         "args": [
//           {
//             "name": "event_index",
//             "required": true,
//             "type": "int",
//             "description": "The index of the event to return (e.g. 10665092)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the event of an index"
//       },
//       {
//         "path": "/v2/events/counts",
//         "args": [
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the event counts of all blocks"
//       },
//       {
//         "path": "/v2/events/<event>",
//         "args": [
//           {
//             "name": "event",
//             "required": true,
//             "type": "str",
//             "description": "The event to return (e.g. CREDIT)"
//           },
//           {
//             "name": "last",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "The last event index to return (e.g. 10665092)"
//           },
//           {
//             "name": "limit",
//             "default": 100,
//             "required": false,
//             "type": "int",
//             "description": "The maximum number of events to return (e.g. 5)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the events filtered by event name"
//       },
//       {
//         "path": "/v2/healthz",
//         "args": [
//           {
//             "name": "check_type",
//             "default": "heavy",
//             "required": false,
//             "type": "str",
//             "description": "Type of health check to perform. Options are 'light' and 'heavy' (e.g. light)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Health check route."
//       },
//       {
//         "path": "/v2/bitcoin/addresses/<address>/transactions",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to search for (e.g. 14TjwxgnuqgB4HcDcSZk2m7WKwcGVYxRjS)"
//           },
//           {
//             "name": "unconfirmed",
//             "default": true,
//             "required": false,
//             "type": "bool",
//             "description": "Include unconfirmed transactions (e.g. True)"
//           },
//           {
//             "name": "only_tx_hashes",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Return only the tx hashes (e.g. True)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns all transactions involving a given address"
//       },
//       {
//         "path": "/v2/bitcoin/addresses/<address>/transactions/oldest",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to search for. (e.g. 14TjwxgnuqgB4HcDcSZk2m7WKwcGVYxRjS)"
//           },
//           {
//             "name": "block_index",
//             "default": null,
//             "required": false,
//             "type": "int",
//             "description": "The block index to search from."
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Get the oldest transaction for an address."
//       },
//       {
//         "path": "/v2/bitcoin/addresses/<address>/utxos",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "The address to search for (e.g. 14TjwxgnuqgB4HcDcSZk2m7WKwcGVYxRjS)"
//           },
//           {
//             "name": "unconfirmed",
//             "default": false,
//             "required": false,
//             "type": "bool",
//             "description": "Include unconfirmed transactions"
//           },
//           {
//             "name": "unspent_tx_hash",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "Filter by unspent_tx_hash"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns a list of unspent outputs for a specific address"
//       },
//       {
//         "path": "/v2/bitcoin/addresses/<address>/pubkey",
//         "args": [
//           {
//             "name": "address",
//             "required": true,
//             "type": "str",
//             "description": "Address to get pubkey for. (e.g. 14TjwxgnuqgB4HcDcSZk2m7WKwcGVYxRjS)"
//           },
//           {
//             "name": "provided_pubkeys",
//             "default": null,
//             "required": false,
//             "type": "str",
//             "description": "Comma separated list of provided pubkeys."
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Get pubkey for an address."
//       },
//       {
//         "path": "/v2/bitcoin/transactions/<tx_hash>",
//         "args": [
//           {
//             "name": "tx_hash",
//             "required": true,
//             "type": "str",
//             "description": "The transaction hash (e.g. 3190047bf2320bdcd0fade655ae49be309519d151330aa478573815229cc0018)"
//           },
//           {
//             "name": "format",
//             "default": "json",
//             "required": false,
//             "type": "str",
//             "description": "Whether to return JSON output or raw hex (e.g. hex)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Get a transaction from the blockchain"
//       },
//       {
//         "path": "/v2/bitcoin/estimatesmartfee",
//         "args": [
//           {
//             "name": "conf_target",
//             "default": 3,
//             "required": false,
//             "type": "int",
//             "description": "Confirmation target in blocks (1 - 1008) (e.g. 2)"
//           },
//           {
//             "name": "mode",
//             "default": "CONSERVATIVE",
//             "required": false,
//             "type": "str",
//             "description": "The fee estimate mode. (e.g. CONSERVATIVE)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Get the fee per kilobyte for a transaction to be confirmed in `conf_target` blocks."
//       },
//       {
//         "path": "/v2/mempool/events",
//         "args": [
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns all mempool events"
//       },
//       {
//         "path": "/v2/mempool/events/<event>",
//         "args": [
//           {
//             "name": "event",
//             "required": true,
//             "type": "str",
//             "description": "The event to return (e.g. OPEN_ORDER)"
//           },
//           {
//             "name": "verbose",
//             "type": "bool",
//             "default": "false",
//             "description": "Include asset and dispenser info and normalized quantities in the response.",
//             "required": false
//           }
//         ],
//         "description": "Returns the mempool events filtered by event name"
//       },
//       {
//         "path": "/",
//         "args": [
//           {
//             "name": "subpath",
//             "default": "",
//             "required": false,
//             "type": "str",
//             "description": "The path to redirect to (e.g. healthz)"
//           }
//         ],
//         "description": "Redirect to the API v1."
//       },
//       {
//         "path": "/v1/<path:subpath>",
//         "args": [
//           {
//             "name": "subpath",
//             "default": "",
//             "required": false,
//             "type": "str",
//             "description": "The path to redirect to (e.g. healthz)"
//           }
//         ],
//         "description": "Redirect to the API v1."
//       },
//       {
//         "path": "/api/<path:subpath>",
//         "args": [
//           {
//             "name": "subpath",
//             "default": "",
//             "required": false,
//             "type": "str",
//             "description": "The path to redirect to (e.g. healthz)"
//           }
//         ],
//         "description": "Redirect to the API v1."
//       },
//       {
//         "path": "/rpc/<path:subpath>",
//         "args": [
//           {
//             "name": "subpath",
//             "default": "",
//             "required": false,
//             "type": "str",
//             "description": "The path to redirect to (e.g. healthz)"
//           }
//         ],
//         "description": "Redirect to the API v1."
//       },
//       {
//         "path": "/<path:subpath>",
//         "args": [
//           {
//             "name": "subpath",
//             "default": "",
//             "required": false,
//             "type": "str",
//             "description": "The path to redirect to (e.g. healthz)"
//           }
//         ],
//         "description": "Redirect to the API v1."
//       }
//     ]
//   }
// }
//
}
