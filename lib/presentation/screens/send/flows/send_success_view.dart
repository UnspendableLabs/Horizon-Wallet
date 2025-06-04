import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class SendSuccessView extends StatelessWidget {
  final String txHex;
  final String txHash;

  const SendSuccessView({super.key, required this.txHex, required this.txHash});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(
          height: 218,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TxnSuccessAnimation(),
            ],
          ),
        ),
        Text(
          "Send Successful",
          style: theme.textTheme.titleMedium,
        ),
        commonHeightSizedBox,
        // Text(
        //   "2 listings successfully fulfilled",
        //   style: theme.inputDecorationTheme.hintStyle,
        // ),
        commonHeightSizedBox,
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                      transparentBlack8,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Transaction id: ',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.color,
                                  ),
                        ),
                        TextSpan(
                          text:
                              (txHex.replaceRange(6, txHex.length - 6, '...')),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color,
                                  ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.visible,
                    maxLines: 1,
                  ),
                ),
              ),
              IntrinsicWidth(
                child: HorizonButton(
                  borderRadius: 12,
                  height: 32,
                  variant: ButtonVariant.purple,
                    child: TextButtonContent(value: "Copy"),
                    icon: AppIcons.copyIcon(context: context, width: 16, height: 16),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: txHex));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tx id copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        HorizonButton(
          variant: ButtonVariant.black,
          child: TextButtonContent(value: "View Transaction"), onPressed: () {
          // TODO: Implement view transaction
        }),
        commonHeightSizedBox,
        HorizonButton(
          variant: ButtonVariant.black,
          child: TextButtonContent(value: "Close"), onPressed: () {
          context.go("/");
        }),
      ],
    );
  }
}
