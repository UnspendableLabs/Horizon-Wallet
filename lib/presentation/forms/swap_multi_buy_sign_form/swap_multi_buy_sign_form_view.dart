import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:formz/formz.dart';
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
import 'package:horizon/presentation/common/link.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';

import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import "./bloc/swap_multi_buy_sign_bloc.dart";

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/fee_option.dart';

import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';

class SwapMultiBuySignFormActions {
  final VoidCallback onSubmitClicked;
  final VoidCallback onCloseSignPsbtModalClicked;
  final Function(FeeOption feeOptin) onFeeOptionChanged;
  final Function(String signedPsbtHex) onSignatureCompleted;
  final Function(bool detach) onDetachAssetsAfterSwapChanged;

  SwapMultiBuySignFormActions({
    required this.onCloseSignPsbtModalClicked,
    required this.onSubmitClicked,
    required this.onFeeOptionChanged,
    required this.onSignatureCompleted,
    required this.onDetachAssetsAfterSwapChanged,
  });
}

class SwapMultiBuySignFormProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AtomicSwap> atomicSwaps;
  final String assetName;
  final FeeEstimatesRespository _feeEstimatesRepository;
  final AddressV2 address;
  final BigInt royaltyAmount;
  final String? royaltyAddress;

  final Widget Function(
    SwapMultiBuySignFormActions actions,
    SwapMultiBuySignFormModel state,
  ) child;

  SwapMultiBuySignFormProvider({
    super.key,
    required this.child,
    required this.httpConfig,
    required this.atomicSwaps,
    required this.assetName,
    required this.address,
    required this.royaltyAmount,
    required this.royaltyAddress,
    FeeEstimatesRespository? feeEstimatesRepository,
  }) : _feeEstimatesRepository =
            feeEstimatesRepository ?? GetIt.I<FeeEstimatesRespository>();
  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return RemoteDataTaskEitherBuilder<String, FeeEstimates>(
        task: _feeEstimatesRepository.getFeeEstimates(
            httpConfig: session.httpConfig),
        builder: (context, state, refresh) => state.fold(
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => const Center(child: CircularProgressIndicator()),
            onRefreshing: (_) => const Center(
                child: CircularProgressIndicator()), // should not happen
            onSuccess: (feeEstimates) => BlocProvider(
                  create: (context) => SwapMultiBuySignFormBloc(
                      royaltyAmount: royaltyAmount,
                      royaltyAddress: royaltyAddress,
                      httpConfig: session.httpConfig,
                      address: address,
                      feeEstimates: feeEstimates,
                      atomicSwaps: atomicSwaps),
                  child: BlocBuilder<SwapMultiBuySignFormBloc,
                      SwapMultiBuySignFormModel>(builder: (context, state) {
                    return child(
                        SwapMultiBuySignFormActions(
                            onDetachAssetsAfterSwapChanged: (value) => context
                                .read<SwapMultiBuySignFormBloc>()
                                .add(DetachAssetsAfterSwapChanged(value)),
                            onCloseSignPsbtModalClicked: () => context
                                .read<SwapMultiBuySignFormBloc>()
                                .add(const CloseSignPsbtModalClicked()),
                            onFeeOptionChanged: (option) => context
                                .read<SwapMultiBuySignFormBloc>()
                                .add(FeeOptionChanged(option)),
                            onSubmitClicked: () => context
                                .read<SwapMultiBuySignFormBloc>()
                                .add(SubmitClicked()),
                            onSignatureCompleted: (signedPsbtHex) => context
                                .read<SwapMultiBuySignFormBloc>()
                                .add(SignatureCompleted(
                                    signedPsbtHex: signedPsbtHex))),
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

class CreateMultiBuyPsbtSignHandler extends StatelessWidget {
  final Function(String signedPsbtHex) onSuccess;
  final VoidCallback onClose;
  final String address;

  const CreateMultiBuyPsbtSignHandler(
      {super.key,
      required this.onSuccess,
      required this.onClose,
      required this.address});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<SwapMultiBuySignFormBloc, SwapMultiBuySignFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignPsbtModal) {
            final result = await WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                pageListBuilder: (bottomSheetContext) => [
                      WoltModalSheetPage(
                          trailingNavBarWidget: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: AppIcons.closeIcon(
                              context: context,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          hasTopBarLayer: false,
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.psbtWithArgs.fold(
                            () => const SizedBox.shrink(),
                            (psbtWithArgs) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                      httpConfig: session.httpConfig,
                                      addresses: session.addressIndexSet.list,
                                      passwordRequired: settings
                                          .requirePasswordForCryptoOperations,
                                      unsignedPsbt: psbtWithArgs.psbtHex,
                                      signInputs: {
                                        address: psbtWithArgs.inputsToSign
                                      },
                                      sighashTypes: [
                                        0x01 // SIGHASH_ALL
                                      ],
                                    ),
                                child: SignPsbtForm(
                                  key: Key(psbtWithArgs.psbtHex),
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  onSuccess: (signedPsbtHex) {
                                    onSuccess(signedPsbtHex);

                                    //  chat if hit this condition, i don't
                                    // want to call onCLose() below
                                    Navigator.of(context).pop("signed");
                                  },
                                )),
                          )),
                      WoltModalSheetPage(
                          trailingNavBarWidget: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: AppIcons.closeIcon(
                              context: context,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          hasTopBarLayer: false,
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.psbtWithArgs.fold(
                            () => const SizedBox.shrink(),
                            (psbtWithArgs) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                      httpConfig: session.httpConfig,
                                      addresses: session.addressIndexSet.list,
                                      passwordRequired: settings
                                          .requirePasswordForCryptoOperations,
                                      unsignedPsbt: psbtWithArgs.psbtHex,
                                      signInputs: {
                                        address: psbtWithArgs.inputsToSign
                                      },
                                      sighashTypes: [
                                        0x01 // SIGHASH_ALL
                                      ],
                                    ),
                                child: SignPsbtForm(
                                  key: Key(psbtWithArgs.psbtHex),
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  onSuccess: (signedPsbtHex) {
                                    onSuccess(signedPsbtHex);
                                    Navigator.of(context).pop("signed");
                                  },
                                )),
                          ))
                    ]);

            if (result != "signed") {
              onClose();
            }

            // show wolt modal but only if it's not already displayed
          }
        },
        child: const SizedBox.shrink());
  }
}

class SwapMultiBuySignForm extends StatefulWidget {
  final SwapMultiBuySignFormActions actions;
  final SwapMultiBuySignFormModel state;

  const SwapMultiBuySignForm(
      {required this.actions, required this.state, super.key});

  @override
  State<SwapMultiBuySignForm> createState() => _SwapMultiBuySignFormState();
}

class _SwapMultiBuySignFormState extends State<SwapMultiBuySignForm> {
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
                    ...widget.state.atomicSwaps.mapIndexed((idx, current) =>
                        Padding(
                          padding: EdgeInsets.only(top: idx == 0 ? 0 : 14),
                          child: HorizonCard(
                            child: Column(children: [
                              _renderPropertyWidget(
                                  "Swap #${idx + 1}",
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Link(
                                        href:
                                            "${session.httpConfig.horizonMarket}/atomic-swaps/${current.id}",
                                        key: Key("swap-link-${current.id}"),
                                        display: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              current.id,
                                              style: const TextStyle(
                                                fontFamily: "RobotoMono",
                                                fontSize: 13,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              LucideIcons.externalLink,
                                              size: 12,
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                              _renderPropertyWidget(
                                  "Rate",
                                  Row(children: [
                                    Text(current.pricePerUnit
                                        .normalizedPretty(precision: 8))
                                  ])),
                              _renderPropertyWidget(
                                  "You'll send",
                                  Row(
                                    children: [
                                      QuantityText(
                                          quantity: current.price
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
                                      const Text("BTC"),
                                    ],
                                  )),
                              _renderPropertyWidget(
                                  "You'll receive",
                                  Row(
                                    children: [
                                      QuantityText(
                                          quantity: current.assetQuantity
                                              .normalizedPretty(precision: 8),
                                          style: const TextStyle(fontSize: 16)),
                                      const SizedBox(width: 8),
                                      appIcons.assetIcon(
                                          httpConfig: session.httpConfig,
                                          context: context,
                                          assetName: current.assetName,
                                          width: 12,
                                          height: 12),
                                      const SizedBox(width: 4),
                                      Text(current.assetName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontSize: 16,
                                          )),
                                    ],
                                  ))
                            ]),
                          ),
                        )),
                    const SizedBox(
                      height: 14,
                    ),
                    commonHeightSizedBox,

                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: customTheme?.settingsItemBackground ??
                            transparentBlack66,
                        border: Border.all(
                          color: Theme.of(context)
                                  .inputDecorationTheme
                                  .outlineBorder
                                  ?.color ??
                              transparentBlack8,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          hoverColor: transparentPurple8,
                          highlightColor: transparentPurple8,
                          onTap: () {},
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Detach assets from UTXO after swap",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: -0.2,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                  ),
                                ),
                                Switch(
                                    value: widget.state.detachAssetsAfterSwap,
                                    onChanged: (value) {
                                      widget.actions
                                          .onDetachAssetsAfterSwapChanged(
                                              value);
                                    })
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      height: 20,
                      color: transparentWhite8,
                      thickness: 1,
                    ),
                    TransactionFeeSelection(
                      selectedFeeOption: widget.state.feeOptionInput.value,
                      onFeeOptionSelected: (value) {
                        widget.actions.onFeeOptionChanged(value);
                      },
                      feeEstimates: widget.state.feeEstimates,
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
                        disabled:
                            widget.state.signatureStatus.isInProgressOrSuccess,
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
