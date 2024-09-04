import 'package:horizon/data/models/cursor.dart' as cursor_model;
import 'package:horizon/domain/entities/cursor.dart' as cursor_entity;
import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/cursor.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/repositories/events_repository.dart';

class StateMapper {
  static EventState get(api.Event apiEvent) {
    return apiEvent.blockIndex != null
        ? EventStateConfirmed(blockHeight: apiEvent.blockIndex!)
        : EventStateMempool();
  }

  static EventState getVerbose(api.VerboseEvent apiEvent) {
    return apiEvent.blockIndex != null
        ? EventStateConfirmed(
            blockHeight: apiEvent.blockIndex!, blockTime: apiEvent.blockTime)
        : EventStateMempool();
  }
}

class EventMapper {
  static Event toDomain(api.Event apiEvent) {
    switch (apiEvent.event) {
      case 'ENHANCED_SEND':
        return EnhancedSendEventMapper.toDomain(
            apiEvent as api.EnhancedSendEvent);
      case 'CREDIT':
        return CreditEventMapper.toDomain(apiEvent as api.CreditEvent);
      case 'DEBIT':
        return DebitEventMapper.toDomain(apiEvent as api.DebitEvent);
      case 'ASSET_ISSUANCE':
        return AssetIssuanceEventMapper.toDomain(
            apiEvent as api.AssetIssuanceEvent);
      case "DISPENSE":
        return DispenseEventMapper.toDomain(apiEvent as api.DispenseEvent);

      // case 'NEW_TRANSACTION':
      //   return NewTransactionEventMapper.toDomain( apiEvent as api.NewTransactionEvent);
      // case 'ASSET_ISSUANCE': return AssetIssuanceEventMapper.toDomain(apiEvent as api.AssetIssuanceEvent);
      default:
        // Return a generic Event for unknown types

        return Event(
          state: StateMapper.get(apiEvent),
          eventIndex: apiEvent.eventIndex,
          event: apiEvent.event,
          txHash:
              apiEvent.txHash!, // all of the events we care about have tx hash,
          blockIndex: apiEvent.blockIndex,
          // confirmed: apiEvent.confirmed,
        );
    }
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

      // case 'ASSET_ISSUANCE':
      //   return VerboseAssetIssuanceEventMapper.toDomain(
      //       apiEvent as api.VerboseAssetIssuanceEvent);
      case 'ASSET_ISSUANCE':
        return VerboseAssetIssuanceEventMapper.toDomain(
            apiEvent as api.VerboseAssetIssuanceEvent);
      case 'DISPENSE': // case 'ASSET_ISSUANCE': return VerboseAssetIssuanceEventMapper.toDomain(
      //       apiEvent as api.VerboseAssetIssuanceEvent);
      // case 'NEW_TRANSACTION':
      //   return VerboseNewTransactionEventMapper.toDomain(
      //       apiEvent as api.VerboseNewTransactionEvent);
      // case 'ASSET_ISSUANCE':
      //   return VerboseAssetIssuanceEventMapper.toDomain(apiEvent as ApiVerboseAssetIssuanceEvent);
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

class EnhancedSendEventMapper {
  static EnhancedSendEvent toDomain(api.EnhancedSendEvent apiEvent) {
    return EnhancedSendEvent(
      state: StateMapper.get(apiEvent),
      event: "ENHANCED_SEND",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      params: EnhancedSendParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class EnhancedSendParamsMapper {
  static EnhancedSendParams toDomain(api.EnhancedSendParams apiParams) {
    return EnhancedSendParams(
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      destination: apiParams.destination,
      memo: apiParams.memo,
      quantity: apiParams.quantity,
      source: apiParams.source,
      status: apiParams.status,
      txHash: apiParams.txHash,
      txIndex: apiParams.txIndex,
    );
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

class CreditEventMapper {
  static CreditEvent toDomain(api.CreditEvent apiEvent) {
    return CreditEvent(
      state: StateMapper.get(apiEvent),
      event: "CREDIT",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      params: CreditParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class CreditParamsMapper {
  static CreditParams toDomain(api.CreditParams apiParams) {
    return CreditParams(
      address: apiParams.address,
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      callingFunction: apiParams.callingFunction,
      event: apiParams.event,
      quantity: apiParams.quantity,
      txIndex: apiParams.txIndex,
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

class DebitEventMapper {
  static DebitEvent toDomain(api.DebitEvent apiEvent) {
    return DebitEvent(
      state: StateMapper.get(apiEvent),
      event: "DEBIT",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      params: DebitParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class DebitParamsMapper {
  static DebitParams toDomain(api.DebitParams apiParams) {
    return DebitParams(
      action: apiParams.action,
      address: apiParams.address,
      asset: apiParams.asset,
      blockIndex: apiParams.blockIndex,
      event: apiParams.event,
      quantity: apiParams.quantity,
      txIndex: apiParams.txIndex,
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

class AssetIssuanceEventMapper {
  static AssetIssuanceEvent toDomain(api.AssetIssuanceEvent apiEvent) {
    return AssetIssuanceEvent(
      state: StateMapper.get(apiEvent),
      event: "ASSET_ISSUANCE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      params: AssetIssuanceParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class AssetIssuanceParamsMapper {
  static AssetIssuanceParams toDomain(api.AssetIssuanceParams apiParams) {
    return AssetIssuanceParams(
      asset: apiParams.asset,
      assetLongname: apiParams.assetLongname,
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
      // transfer: apiParams.transfer,
      // txHash: apiParams.txHash,
      // txIndex: apiParams.txIndex,
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

class VerboseAssetIssuanceParamsMapper {
  static VerboseAssetIssuanceParams toDomain(
      api.VerboseAssetIssuanceParams apiParams) {
    return VerboseAssetIssuanceParams(
      asset: apiParams.asset,
      assetLongname: apiParams.assetLongname,
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
      // transfer: apiParams.transfer,
      // txHash: apiParams.txHash,
      // txIndex: apiParams.txIndex,
      blockTime: apiParams.blockTime,
      quantityNormalized: apiParams.quantityNormalized,
      feePaidNormalized: apiParams.feePaidNormalized,
    );
  }
}

class DispenseEventMapper {
  static DispenseEvent toDomain(api.DispenseEvent apiEvent) {
    return DispenseEvent(
      state: StateMapper.get(apiEvent),
      event: "DISPENSE",
      eventIndex: apiEvent.eventIndex,
      txHash: apiEvent.txHash!,
      blockIndex: apiEvent.blockIndex,
      // confirmed: apiEvent.confirmed,
      params: DispenseParamsMapper.toDomain(apiEvent.params),
    );
  }
}

class DispenseParamsMapper {
  static DispenseParams toDomain(api.DispenseParams apiParams) {
    return DispenseParams(
        asset: apiParams.asset,
        blockIndex: apiParams.blockIndex,
        btcAmount: apiParams.btcAmount,
        destination: apiParams.destination,
        dispenseIndex: apiParams.dispenseIndex,
        dispenseQuantity: apiParams.dispenseQuantity,
        dispenserTxHash: apiParams.dispenserTxHash,
        source: apiParams.source,
        txHash: apiParams.txHash,
        txIndex: apiParams.txIndex);
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

class EventsRepositoryImpl implements EventsRepository {
  final api.V2Api api_;

  EventsRepositoryImpl({
    required this.api_,
  });

  @override
  Future<(List<Event>, cursor_entity.Cursor? nextCursor, int? resultCount)>
      getByAddresses({
    required List<String> addresses,
    cursor_entity.Cursor? cursor,
    int? limit,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addressesParam = addresses.join(',');

    final whitelist_ = whitelist?.join(",");

    final response = await api_.getEventsByAddresses(
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

    List<Event> events = response.result!.map((event) {
      return EventMapper.toDomain(event);
    }).toList();

    return (events, nextCursor, response.resultCount);
  }

  @override
  Future<List<Event>> getAllByAddresses({
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final futures = addresses.map(
        (address) => _getAllEventsForAddress(address, unconfirmed, whitelist));

    final results = await Future.wait(futures);

    return results.expand((events) => events).toList();
  }

  @override
  Future<
      (
        List<VerboseEvent>,
        cursor_entity.Cursor? nextCursor,
        int? resultCount
      )> getByAddressesVerbose({
    required List<String> addresses,
    cursor_entity.Cursor? cursor,
    int? limit,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addressesParam = addresses.join(',');

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

    return (events, nextCursor, response.resultCount);
  }

  @override
  Future<List<VerboseEvent>> getAllByAddressesVerbose({
    required List<String> addresses,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final futures = addresses.map((address) =>
        _getAllVerboseEventsForAddress(address, unconfirmed, whitelist));

    final results = await Future.wait(futures);

    return results.expand((events) => events).toList();
  }

  Future<List<Event>> _getAllEventsForAddress(
      String address, bool? unconfirmed, List<String>? whitelist) async {
    final allEvents = <Event>[];
    Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (events, nextCursor, _) = await getByAddresses(
        addresses: [address],
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

  Future<List<VerboseEvent>> _getAllVerboseEventsForAddress(
      String address, bool? unconfirmed, List<String>? whitelist) async {
    final allEvents = <VerboseEvent>[];
    Cursor? cursor;
    bool hasMore = true;

    while (hasMore) {
      final (events, nextCursor, _) = await getByAddressesVerbose(
        addresses: [address],
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
}
