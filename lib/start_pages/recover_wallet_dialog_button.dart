import 'package:counterparty_wallet/start_pages/go_to_wallet_submit_button.dart';
import 'package:flutter/material.dart';

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
  final _textFieldController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _textFieldController.dispose();
    super.dispose();
  }

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
                      decoration: const InputDecoration(
                          hintText: "Text Field in Dialog"),
                    ),
                    // TODO: any validation on the seed phrase?
                    // TODO: we will want a loading page on submit
                    GoToWalletSubmitButton(
                        mnemonic: _textFieldController.text,
                        submitText: 'Recover Wallet')
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
