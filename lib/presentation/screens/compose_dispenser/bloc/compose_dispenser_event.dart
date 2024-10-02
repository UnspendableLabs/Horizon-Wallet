import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

abstract class ComposeDispenserEvent extends ComposeBaseEvent {}

class FetchBalances extends ComposeDispenserEvent {
  final String address;
  FetchBalances({required this.address});
}

class ChangeAsset extends ComposeDispenserEvent {
  final String asset;
  final Balance balance;
  ChangeAsset({required this.asset, required this.balance});
}
