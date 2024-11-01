import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser/bloc/compose_dispenser_bloc.dart';

abstract class ComposeDispenserEvent extends ComposeBaseEvent {}

class ChangeAsset extends ComposeDispenserEvent {
  final String asset;
  final Balance balance;
  ChangeAsset({required this.asset, required this.balance});
}

class ChangeGiveQuantity extends ComposeDispenserEvent {
  final String value;
  ChangeGiveQuantity({required this.value});
}

class ChangeEscrowQuantity extends ComposeDispenserEvent {
  final String value;
  ChangeEscrowQuantity({required this.value});
}

class ChooseWorkFlow extends ComposeDispenserEvent {
  final bool isCreateNewAddress;
  ChooseWorkFlow({required this.isCreateNewAddress});
}

class ConfirmTransactionOnNewAddress extends ComposeDispenserEvent {
  final ComposeDispenserEventParams params;

  ConfirmTransactionOnNewAddress({
    required this.params,
  });
}

// class CollectPassword extends ComposeDispenserEvent {
//   final String password;
//   CollectPassword({required this.password});
// }

// class ConfirmCreateNewAddressFlow extends ComposeDispenserEvent {}

// class CancelCreateNewAddressFlow extends ComposeDispenserEvent {}
