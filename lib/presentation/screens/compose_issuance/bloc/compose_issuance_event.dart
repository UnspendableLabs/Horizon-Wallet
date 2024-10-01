import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ComposeIssuanceEvent extends ComposeBaseEvent {}

class FetchBalances extends ComposeIssuanceEvent {
  String address;
  FetchBalances({required this.address});
}
