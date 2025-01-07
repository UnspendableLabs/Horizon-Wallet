import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ReplaceByFeeEvent extends ComposeBaseEvent {}

class ReplaceByFeeRequested extends ReplaceByFeeEvent {
  final String txHash;

  ReplaceByFeeRequested(this.txHash);
}

class ConfirmationBackButtonPressed extends ReplaceByFeeEvent {}
