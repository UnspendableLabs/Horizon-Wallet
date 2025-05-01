import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:horizon/presentation/common/gradient_avatar.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionStateCubit>().state.successOrThrow();
    final currentAccount = session.currentAccount;
    final accounts = session.accounts;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isSelected = account.uuid == currentAccount?.uuid;

                return ListTile(
                  leading: GradientAvatar(
                    input: account.uuid,
                    radius: 18,
                  ),
                  title: Text(
                    account.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text("computed btc balance",
                      style: TextStyle(
                        fontSize: 10,
                      )),
                  onTap: () {
                    // Update session (if changing current account is allowed)
                    Navigator.of(context).pop(); // go back after selecting
                  },
                );
              },
            ),
          ),
          Builder(builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: HorizonButton(
                buttonText: "need a value here or else type error",
                child: Text('New Account'),
                onPressed: () {
                  // TODO: Push to create account flow
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
