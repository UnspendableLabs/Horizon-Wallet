import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_response.dart';

import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

import 'package:formz/formz.dart';

import 'package:horizon/presentation/forms/base/sign/bloc/sign_event.dart';
import 'package:horizon/presentation/forms/base/sign/bloc/sign_state.dart';
import 'package:horizon/presentation/forms/base/sign/bloc/sign_bloc.dart';

class SignViewBase<TComposeResponse extends ComposeResponse>
    extends StatelessWidget {
  final Widget Function(Widget feeWidget, Widget submitButton) child;

  final TComposeResponse composeResponse;
  final void Function(String txHex, String texHash) onSubmitSuccess;

  const SignViewBase({
    required this.child,
    required this.onSubmitSuccess,
    required this.composeResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isSmallScreen = MediaQuery.of(context).size.width < 500;
    bool dialogIsOpen = false;

    return BlocConsumer<SignBloc<TComposeResponse>, SignState>(
        listener: (outer, state) async {
      if (state.formModel.status.isSuccess) {
        onSubmitSuccess(
          state.formModel.txHex!,
          state.formModel.txHash!,
        );
      }

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
            final bloc = context.read<SignBloc<TComposeResponse>>();

            return BlocProvider.value(
              value: bloc,
              child: BlocBuilder<SignBloc<TComposeResponse>, SignState>(
                  builder: (dialogContext, dialogState) {
                return HorizonPasswordPrompt(
                  onPasswordSubmitted: (password) async {
                    dialogContext
                        .read<SignBloc<TComposeResponse>>()
                        .add(PasswordPromptSubmitted(password));
                  },
                  onCancel: () {
                    dialogContext
                        .read<SignBloc<TComposeResponse>>()
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
      return child(
          _buildFeeConfirmation(),
          _buildSubmitButton(
            isSmallScreen: isSmallScreen,
            onPressed: () {
              if (state.formModel.status.isInProgress ||
                  state.formModel.status.isSuccess) {
                return;
              }
              context
                  .read<SignBloc<TComposeResponse>>()
                  .add(const SignAndSubmitClicked()); // TODO: handle password
            },
            buttonText: state.formModel.status.isInProgress
                ? "Submitting..."
                : "Sign and Submit",
          ));
    });
  }

  Widget _buildFeeConfirmation() {
    return FeeConfirmation(
      fee: "${composeResponse.btcFee.toString()} sats",
      virtualSize: composeResponse.signedTxEstimatedSize.virtualSize,
      adjustedVirtualSize:
          composeResponse.signedTxEstimatedSize.adjustedVirtualSize,
    );
  }

  Widget _buildSubmitButton(
      {required bool isSmallScreen,
      required VoidCallback onPressed,
      required String buttonText}) {
    return Padding(
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
                    onPressed();
                  },
                  buttonText: buttonText),
            ),
          ),
        ],
      ),
    );
  }
}
