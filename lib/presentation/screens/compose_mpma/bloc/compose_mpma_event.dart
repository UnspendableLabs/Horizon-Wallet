import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

class EntryDestinationUpdated extends ComposeBaseEvent {
  final String destination;
  final int entryIndex;

  EntryDestinationUpdated({
    required this.destination,
    required this.entryIndex,
  });
}

class EntryAssetUpdated extends ComposeBaseEvent {
  final String asset;
  final int entryIndex;

  EntryAssetUpdated({
    required this.asset,
    required this.entryIndex,
  });
}

class EntryQuantityUpdated extends ComposeBaseEvent {
  final String quantity;
  final int entryIndex;

  EntryQuantityUpdated({
    required this.quantity,
    required this.entryIndex,
  });
}

class EntrySendMaxToggled extends ComposeBaseEvent {
  final bool value;
  final int entryIndex;

  EntrySendMaxToggled({
    required this.value,
    required this.entryIndex,
  });
}

class NewEntryAdded extends ComposeBaseEvent {}

class EntryRemoved extends ComposeBaseEvent {
  final int entryIndex;

  EntryRemoved({
    required this.entryIndex,
  });
}
