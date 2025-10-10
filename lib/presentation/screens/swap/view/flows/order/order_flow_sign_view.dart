import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/psbt_type.dart';
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/asset_quantity.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/repositories/fee_estimates_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/format.dart';
import "./order_flow_sign_bloc.dart";
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/domain/entities/remote_data.dart';

class OrderFlowSignActions {
  final Function onSubmitClicked;
  final VoidCallback onCloseSignModalClicked;
  final Function(FeeOption option) onFeeOptionChanged;

  const OrderFlowSignActions({
    required this.onSubmitClicked,
    required this.onFeeOptionChanged,
    required this.onCloseSignModalClicked,
  });
}

class OrderFlowSignProvider extends StatelessWidget {
  final FeeEstimatesRespository _feeEstimatesRepository;
  final AddressV2 address;
  final String giveAsset;
  final String getAsset;
  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;

  final Widget Function(
    OrderFlowSignActions actions,
    OrderReviewFormModel state,
  ) child;

  OrderFlowSignProvider({
    super.key,
    required this.address,
    required this.giveAsset,
    required this.getAsset,
    required this.giveQuantity,
    required this.getQuantity,
    required this.child,
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
            onFailure: (error) => Center(
                  child: Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            onInitial: () => const SizedBox.shrink(),
            onLoading: () => const Center(child: CircularProgressIndicator()),
            onRefreshing: (_) => const Center(
                child: CircularProgressIndicator()), // should not happen
            onSuccess: (feeEstimates) => BlocProvider(
                create: (
                  context,
                ) =>
                    OrderComposeFormBloc(
                      giveAsset: giveAsset,
                      giveQuantity: giveQuantity,
                      getAsset: getAsset,
                      getQuantity: getQuantity,
                      feeEstimates: feeEstimates,
                      httpConfig: session.httpConfig,
                      sourceAddress: address.address,
                    ),
                child: BlocBuilder<OrderComposeFormBloc, OrderReviewFormModel>(
                  builder: (context, state) {
                    return child(
                      OrderFlowSignActions(
                        onSubmitClicked: () {
                          context
                              .read<OrderComposeFormBloc>()
                              .add(const SubmitClicked());
                        },
                        onFeeOptionChanged: (option) => context
                            .read<OrderComposeFormBloc>()
                            .add(FeeOptionChanged(option)),
                        onCloseSignModalClicked: () {
                          context
                              .read<OrderComposeFormBloc>()
                              .add(const CloseSignModalClicked());
                        },
                      ),
                      state,
                    );
                  },
                ))));
  }
}

class OrderFlowSignView extends StatefulWidget {
  final OrderFlowSignActions actions;
  final OrderReviewFormModel state;

  const OrderFlowSignView({
    super.key,
    required this.actions,
    required this.state,
  });

  @override
  State<OrderFlowSignView> createState() => _OrderFlowSignViewState();
}

class _OrderFlowSignViewState extends State<OrderFlowSignView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final appIcons = AppIcons();

    return Column(
      children: [
        Row(
          children: [
            _renderProperty("Transaction Type", "Open Limit Order"),
          ],
        ),
        _renderPropertyWidget(
            "Sell",
            Row(
              children: [
                QuantityText(
                    quantity:
                        widget.state.giveQuantity.normalized(precision: 8),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                appIcons.assetIcon(
                    httpConfig: session.httpConfig,
                    context: context,
                    assetName: widget.state.giveAsset,
                    width: 12,
                    height: 12),
                const SizedBox(width: 4),
                Text(widget.state.giveAsset),
              ],
            )),
        _renderPropertyWidget(
            "Buy",
            Row(
              children: [
                QuantityText(
                    quantity: widget.state.getQuantity.normalized(precision: 8),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                appIcons.assetIcon(
                    httpConfig: session.httpConfig,
                    context: context,
                    assetName: widget.state.getAsset,
                    width: 12,
                    height: 12),
                const SizedBox(width: 4),
                Text(widget.state.getAsset),
              ],
            )),
        _renderPropertyWidget(
            "Price",
            Row(
              children: [
                QuantityText(
                    quantity: widget.state.price.normalized(precision: 8),
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                appIcons.assetIcon(
                    httpConfig: session.httpConfig,
                    context: context,
                    assetName: widget.state.getAsset,
                    width: 12,
                    height: 12),
                const SizedBox(width: 4),
                Text(truncateAssetName(widget.state.getAsset)),
                const SizedBox(width: 4),
                const Text("/"),
                const SizedBox(width: 4),
                Text(truncateAssetName(widget.state.giveAsset)),
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
            widget.actions.onFeeOptionChanged(value);
          },
          feeEstimates: widget.state.feeEstimates,
        ),
        commonHeightSizedBox,
        HorizonButton(
            disabled: widget.state.signatureStatus.isInProgressOrSuccess,
            onPressed: () {
              widget.actions.onSubmitClicked();
            },
            child: TextButtonContent(value: "Sign and Submit")),
        commonHeightSizedBox,
        widget.state.error.fold(
            () => const SizedBox.shrink(),
            (error) => Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(color: red1),
                ))
      ],
    );
  }

  Padding _renderPropertyWidget(label, widget) {
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

  Padding _renderProperty(label, value) {
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
}

class OrderSignHandler extends StatelessWidget {
  final String giveAsset;
  final String getAsset;
  final AssetQuantity giveQuantity;
  final AssetQuantity getQuantity;

  final Function(String signedPsbtHex) onSuccess;
  final VoidCallback onClose;
  final String address;

  const OrderSignHandler(
      {super.key,
      required this.onSuccess,
      required this.onClose,
      required this.address,
      required this.giveAsset,
      required this.getAsset,
      required this.giveQuantity,
      required this.getQuantity});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<OrderComposeFormBloc, OrderReviewFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignPsbtModal) {
            final result = await WoltModalSheet.show(
                context: context,
                modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
                pageListBuilder: (bottomSheetContext) => [
                      // WoltModalSheetPage(
                      //     trailingNavBarWidget: TextButton(
                      //       onPressed: () {
                      //         Navigator.of(context).pop();
                      //       },
                      //       child: AppIcons.closeIcon(
                      //         context: context,
                      //         width: 24,
                      //         height: 24,
                      //       ),
                      //     ),
                      //     hasTopBarLayer: false,
                      //     // pageTitle: Text("Sign PSBT",
                      //     //     style: Theme.of(context).textTheme.headlineSmall),
                      //     child: state.composeResponse.fold(
                      //       () => const SizedBox.shrink(),
                      //       (composeResponse) => BlocProvider(
                      //           create: (context) => SignPsbtBloc(
                      //                 httpConfig: session.httpConfig,
                      //                 addresses: session.addresses,
                      //                 passwordRequired: settings
                      //                     .requirePasswordForCryptoOperations,
                      //                 unsignedPsbt: composeResponse.psbtHex,
                      //                 signInputs: {
                      //                   address: composeResponse.inputsToSign
                      //                 },
                      //                 sighashTypes: [
                      //                   0x01 // SIGHASH_ALL
                      //                 ],
                      //               ),
                      //           child: SignPsbtForm(
                      //             key: Key(composeResponse.psbtHex),
                      //             passwordRequired: settings
                      //                 .requirePasswordForCryptoOperations,
                      //             onSuccess: (signedPsbtHex) {
                      //               onSuccess(signedPsbtHex);
                      //
                      //               //  chat if hit this condition, i don't
                      //               // want to call onCLose() below
                      //               Navigator.of(context).pop("signed");
                      //             },
                      //           )),
                      //     )),
                      WoltModalSheetPage(
                          isTopBarLayerAlwaysVisible: true,
                          topBarTitle: Text("Review Transaction",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(color: Colors.white)),
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
                          hasTopBarLayer: true,
                          // pageTitle: Text("Sign PSBT",
                          //     style: Theme.of(context).textTheme.headlineSmall),
                          child: state.composeResponse.fold(
                            () => const SizedBox.shrink(),
                            (composeResponse) => BlocProvider(
                                create: (context) => SignPsbtBloc(
                                      psbtType: OrderPsbt(
                                          giveAsset: giveAsset,
                                          getAsset: getAsset,
                                          giveQuantity: giveQuantity,
                                          getQuantity: getQuantity),
                                      embeddedWitnessData: true,
                                      httpConfig: session.httpConfig,
                                      addresses: session.addressIndexSet.list,
                                      passwordRequired: settings
                                          .requirePasswordForCryptoOperations,
                                      unsignedPsbt: composeResponse.psbtHex,
                                      signInputs: {
                                        address: List.generate(
                                            composeResponse.numInputs(),
                                            (index) => index)
                                      },
                                      sighashTypes: [
                                        0x01 // SIGHASH_ALL
                                      ],
                                    ),
                                child: SignPsbtForm(
                                  psbtType: OrderPsbt(
                                      giveAsset: giveAsset,
                                      getAsset: getAsset,
                                      giveQuantity: giveQuantity,
                                      getQuantity: getQuantity),
                                  key: Key(composeResponse.psbt),
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
