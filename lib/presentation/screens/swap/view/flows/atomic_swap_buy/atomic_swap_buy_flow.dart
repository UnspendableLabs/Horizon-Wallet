import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/extensions.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";
import 'package:horizon/presentation/forms/swap_slider_form/swap_slider_form_view.dart';
import 'package:horizon/presentation/forms/swap_presign_form/swap_presign_form_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/forms/swap_buy_sign_form/bloc/swap_buy_sign_bloc.dart';
import 'package:horizon/presentation/forms/swap_buy_sign_form/swap_buy_sign_form_view.dart';
// CHAT this compnent is oveflowing.

import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class SwapSuccessStep extends StatefulWidget {
  const SwapSuccessStep({super.key});

  @override
  State<SwapSuccessStep> createState() => _SwapSuccessStepState();
}

class _SwapSuccessStepState extends State<SwapSuccessStep> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(
            height: 218,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TxnSuccessAnimation(),
              ],
            ),
          ),
          Text(
            "Swap Successful",
            style: theme.textTheme.titleMedium,
          ),
          commonHeightSizedBox,
          Text(
            "2 listings successfully fulfilled",
            style: theme.inputDecorationTheme.hintStyle,
          ),
        ],
      ),
    );
  }
}

class AtomicSwapsToSign {
  final List<AtomicSwap> atomicSwaps;
  final String assetName;
  const AtomicSwapsToSign({required this.atomicSwaps, required this.assetName});
}

class AtomicSwapBuyModel extends Equatable {
  final Option<MultiAddressBalanceEntry> bitcoinBalance;
  final Option<List<AtomicSwap>> atomicSwaps;
  final Option<AtomicSwapsToSign> atomicSwapsToSign;

  // final Option<AtomicSwapBuyVariant> atomicSwapBuyVariant;
  // final Option<SwapBuyConfirmationDetails> swapBuyConfirmationDetails;

  const AtomicSwapBuyModel(
      {required this.bitcoinBalance,
      required this.atomicSwaps,
      required this.atomicSwapsToSign});

  @override
  List<Object?> get props => [];

  AtomicSwapBuyModel copyWith({
    Option<MultiAddressBalanceEntry>? bitcoinBalance,
    Option<List<AtomicSwap>>? atomicSwaps,
    Option<AtomicSwapsToSign>? atomicSwapsToSign,
  }) =>
      AtomicSwapBuyModel(
          bitcoinBalance: bitcoinBalance ?? this.bitcoinBalance,
          atomicSwaps: atomicSwaps ?? this.atomicSwaps,
          atomicSwapsToSign: atomicSwapsToSign ?? this.atomicSwapsToSign);
}

class AtomicSwapBuyFlowController extends FlowController<AtomicSwapBuyModel> {
  AtomicSwapBuyFlowController({required AtomicSwapBuyModel initialState})
      : super(initialState);
}

class AtomicSwapBuyFlowView extends StatefulWidget {
  final List<AddressV2> addresses;

  final MultiAddressBalance balances;
  final AssetPairFormOption receiveAsset;

  final VoidCallback onExitFlow;

  const AtomicSwapBuyFlowView(
      {required this.receiveAsset,
      required this.addresses,
      required this.balances,
      required this.onExitFlow,
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
        initialState: const AtomicSwapBuyModel(
            bitcoinBalance: Option.none(),
            atomicSwaps: Option.none(),
            atomicSwapsToSign: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

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
                  body: SwapSliderFormProvider(
                      httpConfig: session.httpConfig,
                      assetName: widget.receiveAsset.name,
                      bitcoinBalance: bitcoinBalance,
                      child: (actions, state) => Column(
                            children: [
                              SwapFormSuccessHandler(onSuccess: (swaps) {
                                _controller.update((model) => model.copyWith(
                                    atomicSwaps: Option.of(swaps)));
                              }),
                              SwapSliderForm(actions: actions, state: state),
                            ],
                          ))))),
          model.atomicSwaps.map((atomicSwaps) => MaterialPage(
              child: FlowStep(
                  leading: IconButton(
                    onPressed: () {
                      _controller.update((model) =>
                          model.copyWith(atomicSwaps: Option.none()));
                    },
                    icon: AppIcons.backArrowIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  title: "Review Swap",
                  widthFactor: .7,
                  body: SwapPresignFormProvider(
                    assetName: widget.receiveAsset.name,
                    httpConfig: session.httpConfig,
                    atomicSwaps: atomicSwaps,
                    child: (actions, state) => Column(
                      children: [
                        SwapPresignSuccessHandler(onSuccess: (swaps) {
                          _controller.update((model) => model.copyWith(
                              atomicSwapsToSign: Option.of(AtomicSwapsToSign(
                                  atomicSwaps: swaps,
                                  assetName: widget.receiveAsset.name))));
                        }),
                        SwapPresignForm(
                          state: state,
                          actions: actions,
                        ),
                      ],
                    ),
                  )))),
          model.atomicSwapsToSign.map((atomciSwapsToSign) => MaterialPage(
              child: SwapBuySignFormProvider(
                  address: widget.addresses.firstWhere(
                    (address) =>
                        address.address ==
                        model.bitcoinBalance.getOrThrow().address,
                  ),
                  httpConfig: session.httpConfig,
                  atomicSwaps: atomciSwapsToSign.atomicSwaps,
                  assetName: atomciSwapsToSign.assetName,
                  child: (actions, state) => FlowStep(
                      leading: IconButton(
                        onPressed: () {
                          if (state.current.signatureStatus
                                  .isInProgressOrSuccess ||
                              state.current.broadcastStatus
                                  .isInProgressOrSuccess) {
                            return;
                          }

                          widget.onExitFlow();
                        },
                        icon: AppIcons.closeIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                      title:
                          "Sign Transaction ( ${state.swapIndex + 1} / ${state.atomicSwaps.length} )",
                      widthFactor: .9,
                      body: Column(
                        children: [
                          CreateBuyPsbtSignHandler(
                              onSuccess: actions.onSignatureCompleted,
                              onClose: () {
                                actions.onCloseSignPsbtModalClicked();
                              },
                              address: state.current.address.address),
                          SwapBuySignForm(
                            key: Key(
                                "swap_buy_sign_form_${state.current.atomicSwap.id}"),
                            state: state,
                            actions: actions,
                          ),
                        ],
                      )))))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
