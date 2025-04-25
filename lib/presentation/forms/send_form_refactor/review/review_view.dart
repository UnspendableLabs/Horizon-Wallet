import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_send.dart';

import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transactions/quantity_display.dart';
import 'package:horizon/presentation/common/transactions/confirmation_field_with_label.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/forms/send_form_refactor/review/bloc/review_event.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/compose_response.dart';

import "./bloc/review_bloc.dart";
import "./bloc/review_state.dart";
import 'package:formz/formz.dart';

class ReviewProvider<TComposeResponse extends ComposeResponse>
    extends StatelessWidget {
  final Widget child;
  final TComposeResponse composeResponse;
  final String Function(TComposeResponse) getSource;
  const ReviewProvider({
    required this.getSource,
    required this.child,
    required this.composeResponse,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReviewBloc<TComposeResponse>>(
      create: (context) => ReviewBloc<TComposeResponse>(
        composeResponse: composeResponse,
        getSource: getSource,
      ),
      child: child,
    );
  }
}

class ReviewView extends StatelessWidget {
  final ComposeSendResponse composeResponse;

  const ReviewView({
    required this.composeResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 500;
    bool dialogIsOpen = false;

    return BlocConsumer<ReviewBloc<ComposeSendResponse>, ReviewState>(
        listener: (outer, state) async {
      if (!state.showPasswordModal && dialogIsOpen) {
        Navigator.of(outer, rootNavigator: true).pop();
        dialogIsOpen = false;
      }

      if (state.showPasswordModal && !dialogIsOpen) {
        dialogIsOpen = true;

        await showDialog(
          context: outer,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            final bloc = context.read<ReviewBloc<ComposeSendResponse>>();

            return BlocProvider.value(
              value: bloc,
              child: BlocBuilder<ReviewBloc<ComposeSendResponse>, ReviewState>(
                  builder: (dialogContext, dialogState) {
                return HorizonPasswordPrompt(
                  onPasswordSubmitted: (password) async {
                    dialogContext
                        .read<ReviewBloc<ComposeSendResponse>>()
                        .add(PasswordPromptSubmitted(password));
                  },
                  onCancel: () {
                    dialogContext
                        .read<ReviewBloc<ComposeSendResponse>>()
                        .add(PasswordPromptCancelClicked());

                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                      dialogIsOpen = false; // reset flag
                    }
                  },
                  buttonText: 'Continue',
                  title: 'Enter Password',
                  errorText: dialogState.passwordFormModel.error,
                  isLoading: dialogState.passwordFormModel.status.isInProgress,
                );
              }),
            );
          },
        );
      }
    }, builder: (context, state) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        QuantityDisplay(
          loading: false,
          quantity: composeResponse.params.quantityNormalized,
        ),
        commonHeightSizedBox,
        ConfirmationFieldWithLabel(
            loading: false,
            label: 'Token Name',
            value: displayAssetName(composeResponse.params.asset,
                composeResponse.params.assetInfo.assetLongname)),
        commonHeightSizedBox,
        ConfirmationFieldWithLabel(
          loading: false,
          label: 'Source Address',
          value: composeResponse.params.source,
        ),
        commonHeightSizedBox,
        ConfirmationFieldWithLabel(
          loading: false,
          label: 'Recipient Address',
          value: composeResponse.params.destination,
        ),
        commonHeightSizedBox,
        FeeConfirmation(
          fee: "${composeResponse.btcFee.toString()} sats",
          virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
          adjustedVirtualSize:
              composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
        ),
        commonHeightSizedBox,
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: 30, horizontal: isSmallScreen ? 20 : 40),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 64,
                  child: HorizonOutlinedButton(
                      isTransparent: false,
                      onPressed: () {
                        context.read<ReviewBloc<ComposeSendResponse>>().add(
                            const SignAndSubmitClicked()); // TODO: handle password
                      },
                      buttonText: "Sign and Submit"),
                ),
              ),
            ],
          ),
        )
        // TODO: fee details needs to be conserved
      ]);
    });
  }
}
