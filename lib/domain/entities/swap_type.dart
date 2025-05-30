import 'package:horizon/domain/entities/multi_address_balance.dart';


sealed class SwapType {}

class AtomicSwapSell extends SwapType {
  final MultiAddressBalance giveBalance;
  AtomicSwapSell({required this.giveBalance});
}

class AtomicSwapBuy extends SwapType {}

class CounterpartyOrder extends SwapType {}
