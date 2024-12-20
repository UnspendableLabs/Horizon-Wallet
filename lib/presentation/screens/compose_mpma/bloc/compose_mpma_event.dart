import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

class UpdateEntryDestination extends ComposeBaseEvent {
  final String destination;
  final int entryIndex;

  UpdateEntryDestination({
    required this.destination,
    required this.entryIndex,
  });
}

class UpdateEntryAsset extends ComposeBaseEvent {
  final String asset;
  final int entryIndex;

  UpdateEntryAsset({
    required this.asset,
    required this.entryIndex,
  });
}

class UpdateEntryQuantity extends ComposeBaseEvent {
  final String quantity;
  final int entryIndex;

  UpdateEntryQuantity({
    required this.quantity,
    required this.entryIndex,
  });
}

class ToggleEntrySendMax extends ComposeBaseEvent {
  final bool value;
  final int entryIndex;

  ToggleEntrySendMax({
    required this.value,
    required this.entryIndex,
  });
}

class AddNewEntry extends ComposeBaseEvent {}
