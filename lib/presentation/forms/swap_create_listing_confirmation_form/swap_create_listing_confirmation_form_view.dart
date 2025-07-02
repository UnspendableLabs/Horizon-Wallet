import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import "./bloc/swap_create_listing_confirmation_form_bloc.dart";
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';

class SwapOnChainFeeSignHandler extends StatelessWidget {
  final Function(String signedPsbtHex) onSuccess;
  final VoidCallback onClose;
  final String address;

  const SwapOnChainFeeSignHandler(
      {super.key,
      required this.onSuccess,
      required this.onClose,
      required this.address});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<SwapCreateListingFormBloc, SwapCreateListingFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignPsbtModal) {
            final result = await WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                // pageContentDecorator: (child) {
                //   return BlocProvider.value(
                //
                //       value: context.read<CreatePsbtFormBloc>(), child: child);
                // },
                pageListBuilder: (bottomSheetContext) => [
                      WoltModalSheetPage(
                          trailingNavBarWidget: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Cancel",
                                style: Theme.of(context).textTheme.labelLarge),
                          ),
                          hasTopBarLayer: false,
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.onChainPayment.fold(
                            onInitial: () => const SizedBox.shrink(),
                            onLoading: () => const Center(
                                child: CircularProgressIndicator()),
                            onRefreshing: (_) => const Center(
                                child: CircularProgressIndicator()),
                            onFailure: (error) => Center(
                              child: Text(
                                error.toString(),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            onSuccess: (onChainPayment) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                      httpConfig: session.httpConfig,
                                      addresses: session.addresses,
                                      passwordRequired: settings
                                          .requirePasswordForCryptoOperations,
                                      unsignedPsbt: onChainPayment.psbt,
                                      signInputs: {
                                        address: onChainPayment.inputsToSign
                                      },
                                      sighashTypes: [
                                        0x01 // all
                                      ],
                                    ),
                                child: SignPsbtForm(
                                  key: Key(onChainPayment.psbt),
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  onSuccess: (signedPsbtHex) {
                                    onSuccess(signedPsbtHex);
                                    Navigator.of(context).pop();
                                  },
                                )),
                          ))
                    ]);

            onClose();

            // show wolt modal but only if it's not already displayed
          }
        },
        child: const SizedBox.shrink());
  }
}

class SwapCreateListingFormActions {
  final Function(FeeOption value) onFeeOptionSelected;
  final VoidCallback onSubmitClicked;
  final VoidCallback onCloseSignPsbtModalClicked;
  final Function(String signedPsbtHex) onSignatureCompleted;

  const SwapCreateListingFormActions({
    required this.onFeeOptionSelected,
    required this.onSubmitClicked,
    required this.onCloseSignPsbtModalClicked,
    required this.onSignatureCompleted,
  });
}

class SwapCreateListingFormProvider extends StatelessWidget {
  final AddressV2 address;

  final String giveAsset;
  final int giveQuantity;
  final String giveQuantityNormalized;
  final BigInt btcPrice;

  final FeeEstimatesRespository _feeEstimatesRepository;

  final Widget Function(SwapCreateListingFormActions actions,
      SwapCreateListingFormModel state) child;

  SwapCreateListingFormProvider({
    super.key,
    required this.address,
    required this.child,
    required this.giveAsset,
    required this.giveQuantity,
    required this.giveQuantityNormalized,
    required this.btcPrice,
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
                create: (context) => SwapCreateListingFormBloc(
                      address: address,
                      httpConfig: session.httpConfig,
                      feeEstimates: feeEstimates,
                      giveAsset: giveAsset,
                      giveQuantity: giveQuantity,
                      giveQuantityNormalized: giveQuantityNormalized,
                      btcPrice: btcPrice,
                    ),
                child: BlocBuilder<SwapCreateListingFormBloc,
                        SwapCreateListingFormModel>(
                    builder: (context, state) => child(
                          SwapCreateListingFormActions(
                            onCloseSignPsbtModalClicked: () {
                              context.read<SwapCreateListingFormBloc>().add(
                                    const CloseSignPsbtModalClicked(),
                                  );
                            },
                            onFeeOptionSelected: (value) {
                              context.read<SwapCreateListingFormBloc>().add(
                                    FeeOptionChanged(value),
                                  );
                            },
                            onSubmitClicked: () {
                              context.read<SwapCreateListingFormBloc>().add(
                                    const SubmitClicked(),
                                  );
                            },
                            onSignatureCompleted: (signedPsbtHex) {
                              context.read<SwapCreateListingFormBloc>().add(
                                  SignatureCompleted(
                                      signedPsbtHex: signedPsbtHex));
                            },
                          ),
                          state,
                        ))),
            onFailure: (error) => Center(
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )));
  }
}

class SwapCreateListingConfirmationForm extends StatefulWidget {
  final SwapCreateListingFormActions actions;
  final SwapCreateListingFormModel state;

  const SwapCreateListingConfirmationForm(
      {required this.actions, required this.state, super.key});

  @override
  State<SwapCreateListingConfirmationForm> createState() =>
      _SwapCreateListingConfirmationFormState();
}

class _SwapCreateListingConfirmationFormState
    extends State<SwapCreateListingConfirmationForm> {
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
                    _renderProperty("Transaction Type", "Create listing"),
                    _renderProperty("Rate", widget.state.rateString),
                    _renderPropertyWidget(
                        "You'll transfer",
                        Row(
                          children: [
                            QuantityText(
                                quantity: widget.state.giveQuantityNormalized,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            appIcons.assetIcon(
                                httpConfig: session.httpConfig,
                                context: context,
                                assetName: widget.state.giveAsset,
                                width: 12,
                                height: 12),
                            const SizedBox(width: 4),
                            Text(widget.state.giveAsset,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                )),
                          ],
                        )),
                    _renderProperty("And when", "someone buys your listing"),
                    _renderPropertyWidget(
                        "You'll receive",
                        Row(
                          children: [
                            QuantityText(
                                quantity: widget.state.btcPriceNormalized,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            appIcons.assetIcon(
                                httpConfig: session.httpConfig,
                                context: context,
                                assetName: "BTC",
                                width: 12,
                                height: 12),
                            const SizedBox(width: 4),
                            Text("BTC",
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
                      selectedFeeOption: widget.state.feeOptionInput.value,
                      onFeeOptionSelected: (value) {
                        widget.actions.onFeeOptionSelected(value);
                      },
                      feeEstimates: widget.state.feeEstimates,
                    ),
                    CollapsableWidget(
                      title: "Fee Details",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _renderPropertyWidget(
                              "wip: fee psbt",
                              switch (widget.state.onChainPayment) {
                                Loading() => const Center(
                                    child: CircularProgressIndicator()),
                                Success(value: var onChainPayment) => Text(
                                    onChainPayment.psbt,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                Failure(error: var error) => Text(
                                    error.toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: customTheme?.errorColor,
                                    ),
                                  ),
                                _ => const SizedBox.shrink(),
                              }),
                        ],
                      ),
                    ),
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
