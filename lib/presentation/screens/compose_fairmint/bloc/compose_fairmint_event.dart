import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/domain/entities/fairminter.dart';

abstract class ComposeFairmintEvent extends ComposeBaseEvent {}

class FairminterChanged extends ComposeFairmintEvent {
  Fairminter? value;
  FairminterChanged({required this.value});
}
