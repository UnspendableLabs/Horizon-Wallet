import 'package:horizon/domain/entities/multi_address_balance.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";

sealed class SwapType {}

class AtomicSwapSell extends SwapType {
  final MultiAddressBalance giveBalance;
  AtomicSwapSell({required this.giveBalance});
}

class AtomicSwapBuy extends SwapType {
  final MultiAddressBalance btcBalance;
  final AssetPairFormOption receiveAsset;
  AtomicSwapBuy({required this.btcBalance, required this.receiveAsset});
}

class CounterpartyOrder extends SwapType {}
