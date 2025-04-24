import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/compose_send.dart';

import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transactions/quantity_display.dart';
import 'package:horizon/presentation/common/transactions/confirmation_field_with_label.dart';
import 'package:horizon/presentation/common/transactions/fee_confirmation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class ReviewView extends StatelessWidget {
  final ComposeSendResponse composeResponse;

  const ReviewView({
    required this.composeResponse,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
      // TODO: fee details needs to be conserved
    ]);
  }
}
