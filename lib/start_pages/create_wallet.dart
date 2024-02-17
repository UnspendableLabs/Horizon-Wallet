import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// TODO: remove file
class CreateWalletPage extends StatelessWidget {
  const CreateWalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: generate seed phrase https://github.com/dart-bitcoin/bip39
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.navigate_before),
          tooltip: 'Go back',
          onPressed: () => GoRouter.of(context).go('/'),
        ),
      ),
      body: Center(
        child: TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('text'),
                              const SizedBox(height: 15),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ));
            },
            child: const Text('Create Wallet')),
      ),
    );
  }
}
