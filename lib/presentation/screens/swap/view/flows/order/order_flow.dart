import 'package:equatable/equatable.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/common/transactions/transaction_error.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';

import 'package:horizon/presentation/forms/swap_order_form/swap_order_form_view.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";
import 'package:horizon/presentation/forms/create_psbt_form/create_psbt_form_view.dart';
import 'package:horizon/presentation/forms/swap_create_listing_confirmation_form/swap_create_listing_confirmation_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import "./order_flow_sign_view.dart";
import "./order_flow_sign_bloc.dart";

class OrderModel extends Equatable {
  Option<MultiAddressBalanceEntry> giveBalance;
  Option<SubmitParams> orderParams;
  Option<String> signedPsbtHex;

  OrderModel({
    required this.giveBalance,
    required this.orderParams,
    required this.signedPsbtHex,
  });

  @override
  List<Object?> get props => [];

  OrderModel copyWith({
    // TODO: this really just needs to be address...
    Option<MultiAddressBalanceEntry>? giveBalance,
    Option<SubmitParams>? orderParams,
    Option<String>? signedPsbtHex,
  }) {
    return OrderModel(
      giveBalance: giveBalance ?? this.giveBalance,
      orderParams: orderParams ?? this.orderParams,
      signedPsbtHex: signedPsbtHex ?? this.signedPsbtHex,
    );
  }
}

class OrderFlowController extends FlowController<OrderModel> {
  OrderFlowController({required OrderModel initialState}) : super(initialState);
}

class OrderFlowView extends StatefulWidget {
  final List<AddressV2> addresses;
  final MultiAddressBalance giveBalance;
  final AssetPairFormOption receiveAsset;

  const OrderFlowView({
    super.key,
    required this.addresses,
    required this.giveBalance,
    required this.receiveAsset,
  });

  @override
  State<OrderFlowView> createState() => _OrderFlowViewState();
}

class _OrderFlowViewState extends State<OrderFlowView> {
  late OrderFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderFlowController(
        initialState: OrderModel(
            giveBalance: const Option.none(),
            orderParams: const Option.none(),
            signedPsbtHex: const Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return FlowBuilder<OrderModel>(
      controller: _controller,
      onGeneratePages: (model, _) {
        return [
          Option.of(
            MaterialPage(
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
                title: "Open Order",
                widthFactor: .4,
                body: AssetBalanceFormProvider(
                    disallowSelections: const [DisallowSelection.balanceIsUtxo],
                    multiAddressBalance: widget.giveBalance,
                    addresses: widget.addresses.map((e) => e.address).toList(),
                    httpConfig: session.httpConfig,
                    child: (actions, state) => Column(children: [
                          AssetBalanceSuccessHandler<MultiAddressBalanceEntry>(
                            mapSuccess: (state) =>
                                Either.of(state.balanceInput.value!.entry),
                            onSuccess: (value) =>
                                _controller.update((model) => model.copyWith(
                                      giveBalance: Option.of(value),
                                    )),
                          ),
                          AssetBalanceForm(
                            state: state,
                            actions: actions,
                          ),
                        ])),
              ),
            ),
          ),
          model.giveBalance.map((giveBalanceEntry) => MaterialPage(
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
                  title: "Limit Order",
                  widthFactor: .4,
                  body: SwapOrderFormProvider(
                      onSubmitClicked: (params) {
                        _controller.update((model) => model.copyWith(
                              orderParams: Option.of(params),
                            ));
                      },
                      multiAddressBalanceEntry: giveBalanceEntry,
                      address: widget.addresses.firstWhere((address) =>
                          address.address ==
                          (giveBalanceEntry.address ??
                              giveBalanceEntry.utxoAddress!)),
                      httpConfig: session.httpConfig,
                      getAsset: widget.receiveAsset.name,
                      giveAsset: widget.giveBalance.asset,
                      child: (actions, state) =>
                          SwapOrderForm(actions: actions, state: state))))),
          model.orderParams.map((params) => MaterialPage(
                child: FlowStep(
                    leading: IconButton(
                      onPressed: () {
                        _controller.update((model) =>
                            model.copyWith(orderParams: Option.none()));
                      },
                      icon: AppIcons.backArrowIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    title: "Review Transaction",
                    widthFactor: .7,
                    body: OrderFlowSignProvider(
                        address: widget.addresses.firstWhere((address) =>
                            address.address ==
                            model.giveBalance.getOrThrow().address!),
                        getQuantity: params.getQuantity,
                        giveQuantity: params.giveQuantity,
                        giveAsset: widget.giveBalance.asset,
                        getAsset: widget.receiveAsset.name,
                        child: (actions, state) => Builder(builder: (context) {
                              return Column(
                                children: [
                                  OrderSignHandler(
                                    address:
                                        model.giveBalance.getOrThrow().address!,
                                    onSuccess: (value) {
                                      _controller.update((model) =>
                                          model.copyWith(
                                              signedPsbtHex: Option.of(value)));
                                    },
                                    onClose: () {
                                      actions.onCloseSignModalClicked();
                                    },
                                  ),
                                  OrderFlowSignView(
                                    actions: actions,
                                    state: state,
                                  )
                                ],
                              );
                            }))),
              )),
          model.signedPsbtHex.map((psbtHex) => MaterialPage(
                  child: RemoteDataTaskEitherBuilder(
                      task: TaskEither<String, String>.Do(($) async {
                final finalizedTx = await $(TaskEither.fromEither(
                    GetIt.I<TransactionService>()
                        .finalizePsbtAndExtractTransactionT(
                            psbtHex: psbtHex,
                            onError: (e, _) => e.toString())));

                final hash = $(GetIt.I<BitcoindService>()
                    .sendrawtransactionT(
                        signedHex: finalizedTx,
                        httpConfig: session.httpConfig,
                        onError: (e, _) => e.toString())
                    .minimumDuration(Duration(seconds: 2)));

                return hash;
              }), builder: (context, state, retry) {
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
                                          signedPsbtHex: const Option.none(),
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
                                  Center(child: TxnSuccessAnimation()),
                              onFailure: (err) => TransactionError(
                                errorMessage: err.toString(),
                                onErrorButtonAction: retry,
                                buttonText: "Retry",
                              ),
                            )),
                        commonHeightSizedBox,
                        state.fold3(
                          onNone: () => Text(
                            "Broadcasting...",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          onFailure: (_) => SizedBox.shrink(),
                          onReplete: (hash) => Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Broadcast Success",
                                  style:
                                      Theme.of(context).textTheme.titleMedium!),
                            ],
                          ),
                        ),
                        commonHeightSizedBox,
                        commonHeightSizedBox,
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
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
                                          text: 'Transaction id: ',
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
                                              onReplete: (hash) =>
                                                  hash.replaceRange(6,
                                                      hash.length - 6, '...')),
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
                                      onReplete: (hash) => () {
                                            Clipboard.setData(
                                                ClipboardData(text: hash));
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Tx id copied to clipboard'),
                                                duration: Duration(seconds: 2),
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
                              onReplete: (hash) => () {
                                    _launchExplorer(hash, session.httpConfig);
                                  }),
                          disabled: state.fold3(
                            onNone: () => true,
                            onFailure: (_) => true,
                            onReplete: (_) => false,
                          ),
                          child: TextButtonContent(value: "View Transaction"),
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
    String txID,
    HttpConfig httpConfig,
  ) async {
    final uri = Uri.parse("${httpConfig.horizonMarket}/explorer/tx/$txID");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
