import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionSuccessful extends StatelessWidget {
  final TransactionType transactionType;
  final String txHex;
  final String txHash;
  const TransactionSuccessful(
      {super.key,
      required this.transactionType,
      required this.txHex,
      required this.txHash});

  Future<void> _launchExplorer() async {
    final config = GetIt.I<Config>();
    final uri = Uri.parse("${config.btcExplorerBase}/tx/$txHash");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SelectableText(
            '${transactionType.name.toUpperCase()} Successful',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                      children: [
                        TextSpan(
                          text: 'Transaction id: ',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.color,
                                  ),
                        ),
                        TextSpan(
                          text:
                              txHash.replaceRange(6, txHash.length - 6, '...'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton(
                  style: Theme.of(context).textButtonTheme.style?.copyWith(
                        backgroundColor: WidgetStateProperty.all(
                          transparentPurple8,
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 12),
                        ),
                      ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: txHash));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tx id copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppIcons.copyIcon(
                        context: context,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'COPY',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 64,
          child: HorizonOutlinedButton(
            onPressed: _launchExplorer,
            buttonText: 'View transaction',
            isTransparent: true,
          ),
        ),
        commonHeightSizedBox,
        SizedBox(
          height: 64,
          child: HorizonOutlinedButton(
            onPressed: () => Navigator.pop(context),
            buttonText: 'Close',
            isTransparent: true,
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
