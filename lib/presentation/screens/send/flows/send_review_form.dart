import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/presentation/common/collapsable_view.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_review_form_bloc.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SendReviewForm extends StatefulWidget {
  final SendType sendType;
  final Function() onSignSuccess;
  const SendReviewForm(
      {super.key, required this.sendType, required this.onSignSuccess});

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

  _renderSendEntry(HttpConfig httpConfig, SendEntryFormModel send) {
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
                        description: send.balanceSelectorInput.value?.assetInfo.description,
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
          _regularProperty(context, "Source Address",
              widget.sendType.selectedBalanceEntry?.address ?? ""),
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
    return BlocConsumer<SendReviewFormBloc, SendReviewFormModel>(
      listener: (context, state) {
        if (state.submissionStatus == FormzSubmissionStatus.success) {
          widget.onSignSuccess();
        }
      },
      builder: (BuildContext context, SendReviewFormModel state) {
        return Column(
          children: [
            ...widget.sendType.sendEntries!
                .map((e) => _renderSendEntry(session.httpConfig, e)),
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
                    _buildLabelValueRow("Fee",
                        "${widget.sendType.composeResponse?.btcFee ?? 0} sats"),
                    _buildLabelValueRow("Virtual Size",
                        "${widget.sendType.composeResponse?.signedTxEstimatedSize.virtualSize} vbytes"),
                    _buildLabelValueRow("Adjusted Virtual Size",
                        "${widget.sendType.composeResponse?.signedTxEstimatedSize.adjustedVirtualSize} vbytes"),
                  ],
                )),
            commonHeightSizedBox,
            HorizonButton(
                child: TextButtonContent(value: "Sign and Submit"),
                onPressed: () {
                  context
                      .read<SendReviewFormBloc>()
                      .add(OnSignAndSubmitEvent(sendType: widget.sendType));
                })
          ],
        );
      },
    );
  }
}
