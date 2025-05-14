import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:horizon/presentation/common/gradient_avatar.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:go_router/go_router.dart';

import 'package:formz/formz.dart';
import "./bloc/generate_account_bloc.dart";

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final currentAccount = session.currentAccount;
    final accounts = session.accounts;

    return BlocProvider(
      create: (_) => GenerateAccountBloc(),
      child: BlocConsumer<GenerateAccountBloc, GenerateAccountState>(
          listener: (context, state) {
        if (state.status.isSuccess) {
          context.read<SessionStateCubit>().refresh();
        }
      }, builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];

                    // TODO: need to make this actully work

                    final isSelected = account.hash == currentAccount!.hash;

                    return ListTile(
                      leading: GradientAvatar(
                        input: account.hash,
                        radius: 18,
                      ),
                      title: Text(
                        account.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text("computed btc balance $isSelected",
                          style: const TextStyle(
                            fontSize: 10,
                          )),
                      onTap: () {
                        context
                            .read<SessionStateCubit>()
                            .onAccountChanged(account, () {
                          context.go("/dashboard");
                        });

                        // TODO: this isn't totally ideal
                        // Update session (if changing current account is allowed)
                        // Navigator.of(context).pop(); // go back after selecting
                      },
                    );
                  },
                ),
              ),
              Builder(builder: (context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HorizonButton(
                    child: TextButtonContent(value: 'New Account'),
                    onPressed: () {
                      context
                          .read<GenerateAccountBloc>()
                          .add(GenerateAccountClicked());
                      // TODO: Push to create account flow
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
