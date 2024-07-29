import 'package:horizon/data/sources/network/api/v2_api.dart' as api;
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/repositories/events_repository.dart';

class StateMapper {
  static EventState get(api.Event apiEvent) {
    return apiEvent.confirmed
        ? EventStateConfirmed(blockHeight: apiEvent.blockIndex!)
        : EventStateMempool();
  }

  static EventState getVerbose(api.VerboseEvent apiEvent) {
    return apiEvent.confirmed
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
      // case 'NEW_TRANSACTION':
      //   return NewTransactionEventMapper.toDomain( apiEvent as api.NewTransactionEvent);
      // case 'ASSET_ISSUANCE': return AssetIssuanceEventMapper.toDomain(apiEvent as api.AssetIssuanceEvent);
      default:
        // Return a generic Event for unknown types

        return Event(
          state: StateMapper.get(apiEvent),
          eventIndex: apiEvent.eventIndex,
          event: apiEvent.event,
          txHash: apiEvent.txHash!, // all of the events we care about have tx hash,
          blockIndex: apiEvent.blockIndex,
          confirmed: apiEvent.confirmed,
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
      // case 'NEW_TRANSACTION':
      //   return VerboseNewTransactionEventMapper.toDomain(
      //       apiEvent as api.VerboseNewTransactionEvent);
      // case 'ASSET_ISSUANCE':
      //   return VerboseAssetIssuanceEventMapper.toDomain(apiEvent as ApiVerboseAssetIssuanceEvent);
      default:
        // Return a generic VerboseEvent for unknown types
        return VerboseEvent(
          state: StateMapper.getVerbose(apiEvent),
          eventIndex: apiEvent.eventIndex,
          event: apiEvent.event,
          txHash: apiEvent.txHash!,
          blockIndex: apiEvent.blockIndex,
          confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
      confirmed: apiEvent.confirmed,
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
  Future<(List<Event>, int? nextCursor, int? resultCount)> getByAddresses({
    required List<String> addresses,
    int? cursor,
    int? limit,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addressesParam = addresses.join(',');

    final response = await api_.getEventsByAddresses(
        addressesParam, cursor, limit, unconfirmed);

    if (response.error != null) {
      throw Exception("Error getting events by addresses: ${response.error}");
    }

    int? nextCursor = response.nextCursor;

    List<Event> events = response.result!
        .where((event) => whitelist == null || whitelist.contains(event.event))
        .map((event) {
          return EventMapper.toDomain(event);
        })
        .toList();

    return (events, nextCursor, response.resultCount);
  }

  @override
  Future<(List<VerboseEvent>, int? nextCursor, int? resultCount)>
      getByAddressesVerbose({
    required List<String> addresses,
    int? cursor,
    int? limit,
    bool? unconfirmed = false,
    List<String>? whitelist,
  }) async {
    final addressesParam = addresses.join(',');

    final response = await api_.getEventsByAddressesVerbose(
        addressesParam, cursor, limit, unconfirmed);

    if (response.error != null) {
      throw Exception("Error getting events by addresses: ${response.error}");
    } int? nextCursor = response.nextCursor;
    List<VerboseEvent> events = response.result!
        .where((event) => whitelist == null || whitelist.contains(event.event))
        .map((event) {
          return VerboseEventMapper.toDomain(event);
        })
        .toList();

    return (events, nextCursor, response.resultCount);
  }
}
