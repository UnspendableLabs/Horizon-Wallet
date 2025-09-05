import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:horizon/domain/entities/http_config.dart';

import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/transaction_error.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
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
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/forms/swap_multi_buy_sign_form/swap_multi_buy_sign_form_view.dart';
import 'package:horizon/domain/repositories/atomic_swap_repository.dart';
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
  final Option<String> signedPsbtHex;

  // final Option<AtomicSwapBuyVariant> atomicSwapBuyVariant;
  // final Option<SwapBuyConfirmationDetails> swapBuyConfirmationDetails;

  const AtomicSwapBuyModel(
      {required this.bitcoinBalance,
      required this.atomicSwaps,
      required this.atomicSwapsToSign,
      required this.signedPsbtHex});

  @override
  List<Object?> get props => [];

  AtomicSwapBuyModel copyWith({
    Option<MultiAddressBalanceEntry>? bitcoinBalance,
    Option<List<AtomicSwap>>? atomicSwaps,
    Option<AtomicSwapsToSign>? atomicSwapsToSign,
    Option<String>? signedPsbtHex,
  }) =>
      AtomicSwapBuyModel(
          bitcoinBalance: bitcoinBalance ?? this.bitcoinBalance,
          atomicSwaps: atomicSwaps ?? this.atomicSwaps,
          atomicSwapsToSign: atomicSwapsToSign ?? this.atomicSwapsToSign,
          signedPsbtHex: signedPsbtHex ?? this.signedPsbtHex);
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
  final AtomicSwapRepository _atomicSwapRepository;

  AtomicSwapBuyFlowView(
      {required this.receiveAsset,
      required this.addresses,
      required this.balances,
      required this.onExitFlow,
      AtomicSwapRepository? atomicSwapRepository,
      super.key})
      : _atomicSwapRepository =
            atomicSwapRepository ?? GetIt.I<AtomicSwapRepository>();

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
            atomicSwapsToSign: Option.none(),
            signedPsbtHex: Option.none()));
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
            trailing: IconButton(
              onPressed: () {
                context.go("/");
              },
              icon: AppIcons.closeIcon(
                context: context,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
              ),
            ),
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
              disallowSelections: const [],
              httpConfig: session.httpConfig,
              addresses: widget.addresses.map((e) => e.address).toList(),
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
                  trailing: IconButton(
                    onPressed: () {
                      context.go("/");
                    },
                    icon: AppIcons.closeIcon(
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
                  trailing: IconButton(
                    onPressed: () {
                      context.go("/");
                    },
                    icon: AppIcons.closeIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () {
                      _controller.update((model) =>
                          model.copyWith(atomicSwaps: const Option.none()));
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
              child: SwapMultiBuySignFormProvider(
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
                          if (state.signatureStatus.isInProgressOrSuccess) {
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
                      title: "Sign Transaction",
                      widthFactor: .9,
                      body: Column(
                        children: [
                          CreateMultiBuyPsbtSignHandler(
                              // TODO: maybe we can get rid of success action here.
                              // onSuccess: actions.onSignatureCompleted,
                              onSuccess: (signedPsbtHex) {
                                _controller.update((model) => model.copyWith(
                                    signedPsbtHex: Option.of(signedPsbtHex)));
                              },
                              onClose: () {
                                actions.onCloseSignPsbtModalClicked();
                              },
                              address: state.address.address),
                          SwapMultiBuySignForm(
                            state: state,
                            actions: actions,
                          ),
                        ],
                      ))))),
          model.signedPsbtHex.map((signedPsbtHex) => MaterialPage(
              child: RemoteDataTaskEitherBuilder(
                  task: widget._atomicSwapRepository.atomicSwapMultiBuyT(
                    httpConfig: session.httpConfig,
                    ids: model.atomicSwapsToSign
                        .getOrThrow()
                        .atomicSwaps
                        .map((e) => e.id)
                        .toList(),
                    psbtHex: signedPsbtHex,
                    buyerAddress: widget.addresses
                        .firstWhere(
                          (address) =>
                              address.address ==
                              model.bitcoinBalance.getOrThrow().address,
                        )
                        .address,
                  ),
                  builder: (context, state, retry) {
                    //TODO: move this into RemoteDataTaskEitherBuilder
                    bool disabled = switch (state) {
                      Initial() => false,
                      Loading() => true,
                      Failure() => false,
                      Success() => true,
                      Refreshing() => true,
                    };

                    return Scaffold(
                      appBar: PreferredSize(
                          preferredSize: const Size.fromHeight(72),
                          child: Container(
                            height: 46,
                            width: double.infinity,
                            padding: const EdgeInsets.only(
                                left: 12, top: 0, bottom: 0, right: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                disabled
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        onPressed: () {
                                          _controller.update(
                                            // i need to disable this button if submission
                                            // is success, but the state is lower
                                            // in the tree
                                            (model) => model.copyWith(
                                              signedPsbtHex:
                                                  const Option.none(),
                                            ),
                                          );
                                        },
                                        icon: AppIcons.backArrowIcon(
                                          context: context,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      ),
                                IconButton(
                                  onPressed: () {
                                    context.go("/");
                                  },
                                  icon: AppIcons.closeIcon(
                                    context: context,
                                    width: 24,
                                    height: 24,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      body: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: state.fold3(
                                  onNone: () => Center(
                                      child: Lottie.asset(
                                    "assets/lottie/txn_success_anim.json",
                                    width: 127,
                                    key: const ValueKey('lottie'),
                                  )),
                                  onReplete: (_) =>
                                      const Center(child: TxnSuccessAnimation()),
                                  onFailure: (err) => TransactionError(
                                    errorMessage: err.toString(),
                                    onErrorButtonAction: retry,
                                    buttonText: "Retry",
                                  ),
                                )),
                            commonHeightSizedBox,
                            state.fold3(
                              onNone: () => Text(
                                "Creating swap...",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onFailure: (_) => const SizedBox.shrink(),
                              onReplete: (hash) => Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Successfully created swap",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!),
                                ],
                              ),
                            ),
                            commonHeightSizedBox,
                            commonHeightSizedBox,
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Theme.of(context)
                                          .inputDecorationTheme
                                          .outlineBorder
                                          ?.color ??
                                      transparentBlack8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Swap id: ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.color,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: state.fold3(
                                                  onNone: () => '',
                                                  onFailure: (_) => '',
                                                  onReplete: (buy) => buy
                                                      .first.txId
                                                      .replaceRange(
                                                          6,
                                                          buy.first.txId
                                                                  .length -
                                                              6,
                                                          '...')),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.visible,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TextButton(
                                      style: Theme.of(context)
                                          .textButtonTheme
                                          .style
                                          ?.copyWith(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                              transparentPurple8,
                                            ),
                                            padding: WidgetStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 12),
                                            ),
                                          ),
                                      onPressed: state.fold3(
                                          onNone: () => () {},
                                          onFailure: (_) => () {},
                                          onReplete: (buy) => () {
                                                Clipboard.setData(ClipboardData(
                                                    text: buy.first.txId));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'txid copied to clipboard'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppIcons.copyIcon(
                                            context: context,
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'COPY',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            HorizonButton(
                              onPressed: state.fold3(
                                  onNone: () => () {},
                                  onFailure: (_) => () {},
                                  onReplete: (buy) => () {
                                        _launchExplorer(
                                            buy.first.txId, session.httpConfig);
                                      }),
                              disabled: state.fold3(
                                onNone: () => true,
                                onFailure: (_) => true,
                                onReplete: (_) => false,
                              ),
                              child:
                                  TextButtonContent(value: "View Transaction"),
                              variant: ButtonVariant.black,
                            ),
                            commonHeightSizedBox,
                            HorizonButton(
                              onPressed: state.fold3(
                                  onNone: () => () {},
                                  onFailure: (_) => () {},
                                  onReplete: (hash) => () {
                                        context.go("/");
                                      }),
                              child: TextButtonContent(value: "Close"),
                              disabled: state.fold3(
                                onNone: () => true,
                                onFailure: (_) => true,
                                onReplete: (_) => false,
                              ),
                              variant: ButtonVariant.black,
                            ),
                          ],
                        ),
                      ),
                    );
                  })))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }

  Future<void> _launchExplorer(
    String swapID,
    HttpConfig httpConfig,
  ) async {
    final uri = Uri.parse("${httpConfig.horizonMarket}/atomic-swaps/$swapID");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
