import 'package:counterparty_wallet/secure_utils/create_address_and_fetch_balance.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Define a custom Form widget.
class RecoverWalletDialogButton extends StatefulWidget {
  const RecoverWalletDialogButton({super.key});

  @override
  State<RecoverWalletDialogButton> createState() => _RecoverWalletPageState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _RecoverWalletPageState extends State<RecoverWalletDialogButton> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  String mnemonic = '';
  final _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
                side: const BorderSide(
                  color: Color.fromRGBO(86, 142, 96, 1),
                ),
              ),
              child: Padding(
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
                    TextField(
                      controller: _textFieldController,
                      onChanged: (v) {
                        mnemonic = v;
                        setState(() {});
                      },
                    ),
                    // TODO: any validation on the seed phrase?
                    // TODO: we will want a loading page on submit
                    ElevatedButton(
                      child: const Text('Recover wallet'),
                      onPressed: () async {
                        // TODO: allow recovery of old wallets
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
      style: ButtonStyle(
          fixedSize: MaterialStateProperty.all<Size?>(const Size(150.0, 50.0)),
          textStyle: MaterialStateProperty.all<TextStyle?>(
              const TextStyle(fontSize: 15))),
      child: const Text('Recover Wallet'),
    );
  }
}
