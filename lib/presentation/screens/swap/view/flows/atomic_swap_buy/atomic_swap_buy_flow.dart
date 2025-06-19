import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/extensions.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";
import "package:horizon/presentation/screens/atomic_swap/forms/swap_listing_slider.dart";

class AtomicSwapBuyModel extends Equatable {
  final Option<MultiAddressBalanceEntry> bitcoinBalance;
  // final Option<AtomicSwapBuyVariant> atomicSwapBuyVariant;
  // final Option<SwapBuyConfirmationDetails> swapBuyConfirmationDetails;

  const AtomicSwapBuyModel({required this.bitcoinBalance});

  @override
  List<Object?> get props => [];

  AtomicSwapBuyModel copyWith({
    Option<MultiAddressBalanceEntry>? bitcoinBalance,
  }) =>
      AtomicSwapBuyModel(bitcoinBalance: bitcoinBalance ?? this.bitcoinBalance);
}

class AtomicSwapBuyFlowController extends FlowController<AtomicSwapBuyModel> {
  AtomicSwapBuyFlowController({required AtomicSwapBuyModel initialState})
      : super(initialState);
}

class AtomicSwapBuyFlowView extends StatefulWidget {
  final List<AddressV2> addresses;

  final MultiAddressBalance balances;
  final AssetPairFormOption receiveAsset;

  const AtomicSwapBuyFlowView(
      {required this.receiveAsset,
      required this.addresses,
      required this.balances,
      super.key});

  @override
  State<AtomicSwapBuyFlowView> createState() => _AtomicSwapBuyFlowViewState();
}

class _AtomicSwapBuyFlowViewState extends State<AtomicSwapBuyFlowView> {
  late AtomicSwapBuyFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtomicSwapBuyFlowController(
        initialState: const AtomicSwapBuyModel(bitcoinBalance: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapBuyModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(
              child: FlowStep(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: AppIcons.backArrowIcon(
                context: context,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
              ),
            ),
            title: "Choose your BTC balance",
            widthFactor: .4,
            body: AssetBalanceFormProvider(
              multiAddressBalance: widget.balances,
              child: (actions, state) => Column(
                children: [
                  AssetBalanceSuccessHandler<MultiAddressBalanceEntry>(
                      mapSuccess: (a) => Either.fromOption(
                          Option.fromNullable(a.balanceInput.value?.entry),
                          () => "invariant"),
                      onSuccess: (option) {
                        _controller.update(
                          (model) =>
                              model.copyWith(bitcoinBalance: Option.of(option)),
                        );
                      }),
                  AssetBalanceForm(
                    state: state,
                    actions: actions,
                  ),
                ],
              ),
            ),
          ))),
          model.bitcoinBalance.map((bitcoinBalance) => MaterialPage(
                  child: FlowStep(
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: AppIcons.backArrowIcon(
                    context: context,
                    width: 24,
                    height: 24,
                    fit: BoxFit.fitHeight,
                  ),
                ),
                title: "Swap",
                widthFactor: .6,
                body: const SwapListingSlider(),
              )))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
