import 'package:counterparty_wallet/common/back_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlertCreateWalletDialog extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialog({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Have you written down your seed phrase?'),
        content: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              SelectableText(mnemonic),
              FilledButton(
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Create wallet'))
            ],
          ),
        ));
  }
}
