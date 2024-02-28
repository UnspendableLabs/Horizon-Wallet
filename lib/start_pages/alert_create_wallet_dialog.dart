import 'package:counterparty_wallet/secure_utils/create_address_and_fetch_balance.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AlertCreateWalletDialogueButton extends StatelessWidget {
  final String mnemonic;

  const AlertCreateWalletDialogueButton({required this.mnemonic, super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
              title: const Text('Have you written down your seed phrase?'),
              content: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BackButton(
                      style: const ButtonStyle(
                          alignment: AlignmentDirectional.topStart),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SelectableText(mnemonic),
                    // TODO: we will want a loading page on submit
                    ElevatedButton(
                      child: const Text('Create wallet'),
                      onPressed: () async {
                        await createAddressAndFetchBalance(mnemonic);

                        // ignore: use_build_context_synchronously
                        GoRouter.of(context).go('/wallet');
                      },
                    )
                  ],
                ),
              )),
        );
      },
      child: const Text('Create Wallet'),
    );
  }
}
