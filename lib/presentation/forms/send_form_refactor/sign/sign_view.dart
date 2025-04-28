import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_send.dart';

import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transactions/quantity_display.dart';
import 'package:horizon/presentation/common/transactions/confirmation_field_with_label.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

import 'package:horizon/presentation/forms/base/sign/sign_view.dart';

class SignView extends StatelessWidget {
  final ComposeSendResponse composeResponse;
  final void Function(String txHex, String texHash) onSubmitSuccess;

  const SignView({
    required this.onSubmitSuccess,
    required this.composeResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SignViewBase<ComposeSendResponse>(
        onSubmitSuccess: onSubmitSuccess,
        composeResponse: composeResponse,
        child: (feeWidget, signAndSubmitWidget) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                feeWidget,
                commonHeightSizedBox,
                signAndSubmitWidget,
              ]);
        });
  }
}
