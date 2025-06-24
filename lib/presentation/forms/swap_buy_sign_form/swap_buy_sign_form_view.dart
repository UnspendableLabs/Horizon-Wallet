import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/atomic_swap/atomic_swap.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';

import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import "./bloc/swap_buy_sign_bloc.dart";

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_option.dart';

class SwapBuySignFormActions {
  final VoidCallback onSubmitClicked;
  final Function(FeeOption feeOptin) onFeeOptionChanged;

  SwapBuySignFormActions(
      {required this.onSubmitClicked, required this.onFeeOptionChanged});
}

class SwapBuySignFormProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AtomicSwap> atomicSwaps;
  final String assetName;
  final FeeEstimatesRespository _feeEstimatesRepository;
  final AddressV2 address;

  final Widget Function(
    SwapBuySignFormActions actions,
    SwapBuySignFormModel state,
  ) child;

  SwapBuySignFormProvider({
    super.key,
    required this.child,
    required this.httpConfig,
    required this.atomicSwaps,
    required this.assetName,
    required this.address,
    FeeEstimatesRespository? feeEstimatesRepository,
  }) : _feeEstimatesRepository =
            feeEstimatesRepository ?? GetIt.I<FeeEstimatesRespository>();
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return RemoteDataTaskEitherBuilder<String, FeeEstimates>(
        task: () => _feeEstimatesRepository.getFeeEstimates(
            httpConfig: session.httpConfig),
        builder: (context, state, refresh) => state.fold(
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => const Center(child: CircularProgressIndicator()),
            onRefreshing: (_) => const Center(
                child: CircularProgressIndicator()), // should not happen
            onSuccess: (feeEstimates) => BlocProvider(
                  create: (context) => SwapBuySignFormBloc(
                      address: address,
                      feeEstimates: feeEstimates,
                      atomicSwaps: atomicSwaps),
                  child: BlocBuilder<SwapBuySignFormBloc, SwapBuySignFormModel>(
                      builder: (context, state) {
                    return child(
                        SwapBuySignFormActions(
                            onFeeOptionChanged: (option) => context
                                .read<SwapBuySignFormBloc>()
                                .add(FeeOptionChanged(option)),
                            onSubmitClicked: () => context
                                .read<SwapBuySignFormBloc>()
                                .add(SubmitClicked())),
                        state);
                  }),
                ),
            onFailure: (error) => Center(
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )));
  }
}

class SwapBuySignForm extends StatefulWidget {
  final SwapBuySignFormActions actions;
  final SwapBuySignFormModel state;

  const SwapBuySignForm(
      {required this.actions, required this.state, super.key});

  @override
  State<SwapBuySignForm> createState() => _SwapBuySignFormState();
}

class _SwapBuySignFormState extends State<SwapBuySignForm> {
  _renderProperty(label, value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle),
          Text(value,
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  _renderPropertyWidget(label, widget) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle),
          widget,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final appIcons = AppIcons();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        commonHeightSizedBox,
        SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _renderProperty("Transaction Type", "atomic swap buy"),
                    _renderProperty("Rate", widget.state.current.rateString),
                    _renderProperty("Swap Completion", "Execute immediately"),
                    _renderPropertyWidget(
                        "You'll send",
                        Row(
                          children: [
                            QuantityText(
                                quantity: widget.state.current.atomicSwap.price
                                    .normalizedPretty(precision: 8),
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            appIcons.assetIcon(
                                httpConfig: session.httpConfig,
                                context: context,
                                assetName: "BTC",
                                width: 12,
                                height: 12),
                            const SizedBox(width: 4),
                            Text("BTC"),
                          ],
                        )),
                    _renderProperty("And when", "Transaction is confirmed"),
                    _renderPropertyWidget(
                        "You'll receive",
                        Row(
                          children: [
                            QuantityText(
                                quantity: widget
                                    .state.current.atomicSwap.assetQuantity
                                    .normalizedPretty(precision: 8),
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            appIcons.assetIcon(
                                httpConfig: session.httpConfig,
                                context: context,
                                assetName:
                                    widget.state.current.atomicSwap.assetName,
                                width: 12,
                                height: 12),
                            const SizedBox(width: 4),
                            Text(widget.state.current.atomicSwap.assetName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                )),
                          ],
                        )),
                    const SizedBox(
                      height: 14,
                    ),
                    commonHeightSizedBox,
                    const Divider(
                      height: 20,
                      color: transparentWhite8,
                      thickness: 1,
                    ),
                    TransactionFeeSelection(
                      selectedFeeOption:
                          widget.state.current.feeOptionInput.value,
                      onFeeOptionSelected: (value) {
                        widget.actions.onFeeOptionChanged(value);
                      },
                      feeEstimates: widget.state.current.feeEstimates,
                    ),
                    // CollapsableWidget(
                    //   title: "Fee Details",
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       _renderPropertyWidget(
                    //           "wip: fee psbt",
                    //           switch (widget.state.onChainPayment) {
                    //             Loading() => const Center(
                    //                 child: CircularProgressIndicator()),
                    //             Success(value: var onChainPayment) => Text(
                    //                 onChainPayment.psbt,
                    //                 style: theme.textTheme.bodySmall,
                    //               ),
                    //             Failure(error: var error) => Text(
                    //                 error.toString(),
                    //                 style: theme.textTheme.bodySmall?.copyWith(
                    //                   color: customTheme?.errorColor,
                    //                 ),
                    //               ),
                    //             _ => const SizedBox.shrink(),
                    //           }),
                    //     ],
                    //   ),
                    // ),
                    commonHeightSizedBox,
                    HorizonButton(
                        onPressed: () {
                          widget.actions.onSubmitClicked();
                        },
                        child: TextButtonContent(value: "Sign and Submit")),
                    commonHeightSizedBox,
                  ],
                )))
      ],
    );
  }
}
