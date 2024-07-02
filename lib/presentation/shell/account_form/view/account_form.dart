import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import "package:horizon/remote_data_bloc/remote_data_state.dart";
import 'package:horizon/domain/entities/account.dart';

import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';

final validAccount = RegExp(r"^\d\'$");

class AddAccountForm extends StatefulWidget {
  const AddAccountForm({super.key});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final purposeController = TextEditingController();
  final coinTypeController = TextEditingController();
  final accountIndexController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    // TODO: the fact that we have to do all these paranoid checks
    // is a smell.

    Account? account = shell.state.maybeWhen(
        success: (state) => state.accounts
            .firstWhere((account) => account.uuid == state.currentAccountUuid),
        orElse: () => null);

    if (account == null) {
      throw Exception("invariant: account is null");
    }

    List<Account>? accounts = shell.state
        .maybeWhen(success: (state) => state.accounts, orElse: () => null);

    if (accounts == null) {
      throw Exception("invariant: accounts are null"); }
    purposeController.text = account.purpose;
    coinTypeController.text = account.coinType;

    return BlocConsumer<AccountFormBloc, RemoteDataState<Account>>(
        listener: (context, state) {
      state.whenOrNull(error: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
        ));
      }, success: (account) async {
        // update accounts in shell
        shell.refresh();


        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Success"),
        ));

        await Future.delayed(const Duration(milliseconds: 500));

        Navigator.of(context).pop();
      });
    }, builder: (context, state) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              // validator: (String? value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter some text';
              //   }
              //   return null;
              // },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: purposeController,
              readOnly: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Purpose",
                  floatingLabelBehavior: FloatingLabelBehavior
                      .always), // validator: (String? value) { if (value == null || value.isEmpty) { return 'Please enter some text'; }
              //   return null;
              // },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: coinTypeController,
              readOnly: true,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Coin',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              // validator: (String? value) {
              //   if (value == null || value.isEmpty) {
              //     return 'Please enter some text';
              //   }
              //   return null;
              // },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: accountIndexController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Account Index',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (String? value) {
                // parse int
                bool isValidAccount = validAccount.hasMatch(value ?? "");

                if (!isValidAccount) {
                  return 'Please enter a valid account ([0-9]\')';
                }

                bool accountExists =
                    accounts.any((account) => account.accountIndex == value);

                if (accountExists) {
                  return 'Account already exists';
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }

                // TODO: 32 byte password hack
                if (value.length != 32) {
                  return "Invalid";
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                minimumSize: Size(120, 48), // Ensures button doesn't resize
              ),
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  if (state == const RemoteDataState.loading()) {
                    return;
                  }

                  // get name field from form

                  String name = nameController.text;
                  String purpose = purposeController.text;
                  String coinType = coinTypeController.text;
                  String accountIndex = accountIndexController.text;
                  String walletUuid = account.walletUuid;
                  String password = passwordController.text;

                  context.read<AccountFormBloc>().add(Submit(
                      name: name,
                      purpose: purpose,
                      coinType: coinType,
                      accountIndex: accountIndex,
                      walletUuid: walletUuid,
                      password: password));

                  // Process data.
                }
              },
              child: state == const RemoteDataState.loading()
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: const CircularProgressIndicator())
                  : const Text('Submit'),
            ),
          ],
        ),
      );
    });
  }
}
