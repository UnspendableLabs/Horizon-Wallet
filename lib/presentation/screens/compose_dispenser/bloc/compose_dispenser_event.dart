import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';

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
  final String originalAddress;
  final bool divisible;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final bool sendExtraBtcToDispenser;

  ConfirmTransactionOnNewAddress({
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.sendExtraBtcToDispenser,
  });
}
