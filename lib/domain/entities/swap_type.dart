import 'package:horizon/domain/entities/balance_v2.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";

sealed class SwapType {}

class AtomicSwapSell extends SwapType {
  final AssetBalanceSummary giveBalance;
  AtomicSwapSell({required this.giveBalance});
}

class AtomicSwapBuy extends SwapType {
  final AssetBalanceSummary btcBalance;
  final AssetPairFormOption receiveAsset;
  AtomicSwapBuy({required this.btcBalance, required this.receiveAsset});
}

class CounterpartyOrder extends SwapType {
  final AssetBalanceSummary giveBalance;
  final AssetPairFormOption receiveAsset;

  CounterpartyOrder({required this.giveBalance, required this.receiveAsset});
}
