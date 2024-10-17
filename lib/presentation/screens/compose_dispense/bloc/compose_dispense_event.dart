import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ComposeDispenseEvent extends ComposeBaseEvent {}

class DispenserAddressChanged extends ComposeDispenseEvent {
  String address;
  DispenserAddressChanged({required this.address});
}
