import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/event.dart';
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
  static VerboseEvent toDomain(api.VerboseEvent apiEvent) {
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
      // case 'NEW_TRANSACTION':
      //   return VerboseNewTransactionEventMapper.toDomain(
      //       apiEvent as api.VerboseNewTransactionEvent);
      default:
        return VerboseEvent(
          state: StateMapper.getVerbose(apiEvent),
          eventIndex: apiEvent.eventIndex,
          event: apiEvent.event,
          txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash!,
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

class VerboseAssetIssuanceEventMapper {
  static VerboseAssetIssuanceEvent toDomain(
      api.VerboseAssetIssuanceEvent apiEvent) {
    final x = VerboseAssetIssuanceEvent(
      state: StateMapper.getVerbose(apiEvent),
      event: "ASSET_ISSUANCE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash!,
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
      // status: apiParams.status,
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
      txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash ?? "",
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
      txHash: apiEvent.txHash!,
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
      txHash: apiEvent.txHash ?? "",
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
      txHash: apiEvent.txHash!,
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

class EventsRepositoryImpl implements EventsRepository {
  final api.V2Api api_;
  final _cache = <String, (List<VerboseEvent>, cursor_entity.Cursor?, int?)>{};

  EventsRepositoryImpl({
    required this.api_,
  });

  String _generateCacheKey(
      String address, int limit, cursor_entity.Cursor cursor) {
    return '$address|$limit|${cursor_model.CursorMapper.toData(cursor)?.toJson()}';
  }

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
    String? cacheKey;
    if (limit != null && cursor != null) {
      cacheKey = _generateCacheKey(address, limit, cursor);
    }

    if (cacheKey != null && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final addressesParam = address;

    final whitelist_ = whitelist?.join(",");

    final response = await api_.getEventsByAddressesVerbose(
        addressesParam,
        cursor_model.CursorMapper.toData(cursor),
        limit,
        unconfirmed,
        whitelist_);

    if (response.error != null) {
      throw Exception("Error getting events by addresses: ${response.error}");
    }
    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);
    List<VerboseEvent> events = response.result!.map((event) {
      return VerboseEventMapper.toDomain(event);
    }).toList();

    if (cacheKey != null) {
      _cache[cacheKey] = (events, nextCursor, response.resultCount);
    }

    return (events, nextCursor, response.resultCount);
  }

  @override
  Future<List<VerboseEvent>> getAllByAddressVerbose({
    required String address,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addresses = [address];
    final results = <List<VerboseEvent>>[];
    if (unconfirmed == true) {
      final mempoolFutures = addresses.map((address) =>
          _getAllMempoolVerboseEventsForAddress(
              address, unconfirmed, whitelist));

      final mempoolResults = await Future.wait(mempoolFutures);
      results.addAll(mempoolResults);
    }

    final futures = addresses.map((address) =>
        _getAllVerboseEventsForAddress(address, unconfirmed, whitelist));

    final eventResults = await Future.wait(futures);
    results.addAll(eventResults);

    return results.expand((events) => events).toList();
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
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addressesParam = address;

    final whitelist_ = whitelist?.join(",");

    final response = await api_.getMempoolEventsByAddressesVerbose(
        addressesParam,
        cursor_model.CursorMapper.toData(cursor),
        limit,
        unconfirmed,
        whitelist_);

    if (response.error != null) {
      throw Exception(
          "Error getting mempool events by addresses: ${response.error}");
    }
    cursor_entity.Cursor? nextCursor =
        cursor_model.CursorMapper.toDomain(response.nextCursor);
    List<VerboseEvent> events = response.result!.map((event) {
      return VerboseEventMapper.toDomain(event);
    }).toList();

    return (events, nextCursor, response.resultCount);
  }

  Future<List<VerboseEvent>> _getAllMempoolVerboseEventsForAddress(
      String address, bool? unconfirmed, List<String>? whitelist) async {
    final allEvents = <VerboseEvent>[];
    Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (events, nextCursor, _) = await getMempoolEventsByAddressVerbose(
        address: address,
        limit: 1000,
        cursor: cursor,
        unconfirmed: unconfirmed,
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
