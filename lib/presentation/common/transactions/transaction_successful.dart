import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';

class TransactionSuccessful extends StatelessWidget {
  final String? txHex;
  final String? txHash;
  final String? title;
  final bool loading;
  final VoidCallback? onClose;

  const TransactionSuccessful({
    super.key,
    this.txHex,
    this.txHash,
    this.loading = false,
    this.title,
    this.onClose,
  });

  Future<void> _launchExplorer(HttpConfig httpConfig) async {
    if (loading || txHash == null) return;

    final uri = Uri.parse("${httpConfig.btcExplorer}/tx/$txHash");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const TxnSuccessAnimation(),
        commonHeightSizedBox,
        Text(title ?? "Transaction Successful", style: Theme.of(context).textTheme.titleMedium,),
        const SizedBox(
          height: 32,
        ),
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
                          text: loading
                              ? ''
                              : (txHex?.replaceRange(
                                      6, txHex!.length - 6, '...') ??
                                  ''),
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
                  onPressed: loading || txHex == null
                      ? null
                      : () {
                          Clipboard.setData(ClipboardData(text: txHex!));
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
        const SizedBox(height: 28),
        HorizonButton(
          onPressed: loading ? null : () => _launchExplorer(session.httpConfig),
          disabled: loading,
          child: TextButtonContent(value: "View Transaction"),
          variant: ButtonVariant.black,
        ),
        commonHeightSizedBox,
        HorizonButton(
          onPressed: () {
            onClose?.call();
          },
          child: TextButtonContent(value: "Close"),
          disabled: loading,
          variant: ButtonVariant.black,
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}
