import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_review_form_bloc.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/forms/sign_psbt/bloc/sign_psbt_bloc.dart';
import 'package:horizon/presentation/forms/sign_psbt/view/sign_psbt_form.dart';

class SendFormReviewActions {
  final Function onSubmit;
  const SendFormReviewActions({required this.onSubmit});
}

class SendReviewFormProvider extends StatelessWidget {
  final List<SendEntryFormModel> sendEntries;
  final ComposeSendUnion composeResponse;
  final Widget Function(
      SendFormReviewActions actions, SendReviewFormModel state) child;

  const SendReviewFormProvider(
      {super.key,
      required this.sendEntries,
      required this.composeResponse,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendReviewFormBloc(
          sendEntries: sendEntries, composeResponse: composeResponse),
      child: BlocBuilder<SendReviewFormBloc, SendReviewFormModel>(
        builder: (context, state) => child(SendFormReviewActions(
          onSubmit: () {
            context.read<SendReviewFormBloc>().add(SignAndSubmitClicked());
          },
        ), state),
      ),
    );
  }
}

class SendReviewSignHandler extends StatelessWidget {
  final VoidCallback onClose;
  final String address;

  const SendReviewSignHandler(
      {super.key, required this.onClose, required this.address});

  @override
  Widget build(context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();

    return BlocListener<SendReviewFormBloc, SendReviewFormModel>(
        listener: (context, state) async {
          final settings = GetIt.I<SettingsRepository>();

          if (state.showSignTransactionModal) {
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
                        child: BlocProvider(
                            create: (context) => SignPsbtBloc(
                                  httpConfig: session.httpConfig,
                                  addresses: session.addresses,
                                  passwordRequired: settings
                                      .requirePasswordForCryptoOperations,
                                  unsignedPsbt: switch (state.composeResponse) {
                                    ComposeSendMpma(response: var resp) =>
                                      resp.psbtHex,
                                    ComposeSendSingle(response: var resp) =>
                                      resp.psbtHex,
                                  },
                                  signInputs: {
                                    address: switch (state.composeResponse) {
                                      ComposeSendMpma(response: var resp) =>
                                        List.generate(
                                            resp.numInputs(), (n) => n),
                                      ComposeSendSingle(response: var resp) =>
                                        List.generate(
                                            resp.numInputs(), (n) => n),
                                    }
                                  },
                                  sighashTypes: [
                                    0x01 // SIGHASH_ALL
                                  ],
                                ),
                            child: SignPsbtForm(
                              key: Key(
                                switch (state.composeResponse) {
                                  ComposeSendMpma(response: var resp) =>
                                    resp.psbt,
                                  ComposeSendSingle(response: var resp) =>
                                    resp.psbt,
                                },
                              ),
                              passwordRequired:
                                  settings.requirePasswordForCryptoOperations,
                              onSuccess: (signedPsbtHex) {
                                // onSuccess(signedPsbtHex);

                                //  chat if hit this condition, i don't
                                // want to call onCLose() below
                                Navigator.of(context).pop("signed");
                              },
                            )),
                      ),
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
                      //     child: state.current.psbtWithArgs.fold(
                      //       () => const SizedBox.shrink(),
                      //       (psbtWithArgs) => BlocProvider(
                      //           create: (context) => SignPsbtBloc(
                      //                 httpConfig: session.httpConfig,
                      //                 addresses: session.addresses,
                      //                 passwordRequired: settings
                      //                     .requirePasswordForCryptoOperations,
                      //                 unsignedPsbt: psbtWithArgs.psbtHex,
                      //                 signInputs: {
                      //                   address: psbtWithArgs.inputsToSign
                      //                 },
                      //                 sighashTypes: [
                      //                   0x01 // SIGHASH_ALL
                      //                 ],
                      //               ),
                      //           child: SignPsbtForm(
                      //             key: Key(psbtWithArgs.psbtHex),
                      //             passwordRequired: settings
                      //                 .requirePasswordForCryptoOperations,
                      //             onSuccess: (signedPsbtHex) {
                      //               onSuccess(signedPsbtHex);
                      //               Navigator.of(context).pop("signed");
                      //             },
                      //           )),
                      //     ))
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

class SendReviewFormSuccessHandler extends StatelessWidget {
  final Function(SendFlowConfirmationStep) onSuccess;
  const SendReviewFormSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendReviewFormBloc, SendReviewFormModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess) {
          onSuccess(SendFlowConfirmationStep(
            signedTxHex: state.signedTxHex,
            signedTxHash: state.signedTxHash,
          ));
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class SendReviewForm extends StatefulWidget {
  final SendReviewFormModel state;
  final SendFormReviewActions actions;
  const SendReviewForm({super.key, required this.state, required this.actions});

  @override
  State<SendReviewForm> createState() => _SendReviewFormState();
}

class _SendReviewFormState extends State<SendReviewForm> {
  final appIcons = AppIcons();

  _regularProperty(context, label, value, {Widget? widget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
                    fontSize: 12,
                  )),
          if (widget != null)
            widget
          else
            Text(value,
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    )),
        ],
      ),
    );
  }

  _renderSendEntry(
      HttpConfig httpConfig, SendEntryFormModel send, String sourceAddress) {
    return HorizonCard(
        backgroundColor:
            Theme.of(context).extension<CustomThemeExtension>()?.bgBlackOrWhite,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("You're sending",
              textAlign: TextAlign.left,
              style: Theme.of(context).inputDecorationTheme.hintStyle),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              QuantityText(
                quantity: send.quantityInput.value,
                style: const TextStyle(fontSize: 35),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 30,
                child: QuantityText(
                    quantity: send.balanceSelectorInput.value?.asset ?? "",
                    style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
          _regularProperty(context, "Token name", "",
              widget: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    appIcons.assetIcon(
                        httpConfig: httpConfig,
                        context: context,
                        width: 24,
                        height: 24,
                        description: send
                            .balanceSelectorInput.value?.assetInfo.description,
                        assetName:
                            send.balanceSelectorInput.value?.asset ?? ""),
                    const SizedBox(width: 10),
                    Text(
                        send.balanceSelectorInput.value?.assetLongname ??
                            send.balanceSelectorInput.value?.asset ??
                            "",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ))
                  ],
                ),
              )),
          commonHeightSizedBox,
          _regularProperty(context, "Source Address", sourceAddress),
          commonHeightSizedBox,
          _regularProperty(
              context, "Recipient Address", send.destinationInput.value),
        ]));
  }

  Widget _buildLabelValueRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SelectableText(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: transparentWhite33,
                ),
          ),
          const SizedBox(width: 12),
          SelectableText(
            value ?? '',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    // Extract response and source address once
    final (response, sourceAddress) = switch (widget.state.composeResponse) {
      ComposeSendMpma(response: var resp) => (resp, resp.params.source),
      ComposeSendSingle(response: var resp) => (resp, resp.params.source),
      _ => throw Exception(
          "Invalid compose response type: ${widget.state.composeResponse.runtimeType}"),
    };

    return Column(
      children: [
        ...widget.state.sendEntries
            .map((e) => _renderSendEntry(session.httpConfig, e, sourceAddress)),
        commonHeightSizedBox,
        const Divider(
          color: transparentBlack33,
          height: 20,
          thickness: 1,
        ),
        commonHeightSizedBox,
        CollapsableWidget(
            title: "Fee Details",
            child: Column(
              children: [
                _buildLabelValueRow("Fee", "${response.btcFee} sats"),
                _buildLabelValueRow("Virtual Size",
                    "${response.signedTxEstimatedSize.virtualSize} vbytes"),
                _buildLabelValueRow("Adjusted Virtual Size",
                    "${response.signedTxEstimatedSize.adjustedVirtualSize} vbytes"),
              ],
            )),
        commonHeightSizedBox,
        HorizonButton(
            child: TextButtonContent(value: "Sign and Submit"),
            isLoading: widget.state.submissionStatus.isInProgress,
            onPressed: () {
              widget.actions.onSubmit();
            }),
        const SizedBox(height: 24),
      ],
    );
  }
}
