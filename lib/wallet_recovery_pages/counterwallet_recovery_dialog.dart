import 'package:counterparty_wallet/common/back_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CounterwalletRecoveryDialog extends StatefulWidget {
  const CounterwalletRecoveryDialog({super.key});

  @override
  State<CounterwalletRecoveryDialog> createState() => _RecoverWalletPageState();
}

class _RecoverWalletPageState extends State<CounterwalletRecoveryDialog> {
  final _textFieldController = TextEditingController();

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: _getShape(),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CommonBackButton(),
              TextField(
                controller: _textFieldController,
                decoration: const InputDecoration(
                    hintText: "input counterwallet seed phrase"),
              ),
              FilledButton(
                  onPressed: () async {

                    // ignore: use_build_context_synchronously
                    GoRouter.of(context).go('/wallet');
                  },
                  child: const Text('Recover wallet'))
            ],
          ),
        ));
  }

  ShapeBorder _getShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
      side: const BorderSide(
        color: Color.fromRGBO(86, 142, 96, 1),
      ),
    );
  }
}
