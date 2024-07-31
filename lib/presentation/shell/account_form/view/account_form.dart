import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import "package:horizon/remote_data_bloc/remote_data_state.dart";

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

    List<Account>? accounts = shell.state
        .maybeWhen(success: (state) => state.accounts, orElse: () => null);

    if (accounts == null) {
      throw Exception("invariant: accounts are null");
    }

    Account? currentHighestIndexAccount = shell.state.maybeWhen(
        success: (state) {
          // Find the account with the highest hardened account index
          Account? highestAccount;
          int maxIndex = -1;

          for (var account in state.accounts) {
            int currentIndex =
                int.parse(account.accountIndex.replaceAll("'", ""));
            if (currentIndex > maxIndex) {
              maxIndex = currentIndex;
              highestAccount = account;
            }
          }
          return highestAccount;
        },
        orElse: () => null);

    if (currentHighestIndexAccount == null) {
      throw Exception("invariant: account is null");
    }

    int newAccountIndex =
        int.parse(currentHighestIndexAccount.accountIndex.replaceAll("'", "")) +
            1;

    String newAccountPath = currentHighestIndexAccount.importFormat ==
            ImportFormat.segwit
        ? "m/${currentHighestIndexAccount.purpose}/${currentHighestIndexAccount.coinType}/$newAccountIndex'/"
        : "m/$newAccountIndex'/";

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
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              controller: TextEditingController(text: newAccountPath),
              decoration: InputDecoration(
                  labelText: "Account Path:",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black)),
              enabled: false, // This makes the input field disabled
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your account';
                }
                return null;
              },
            ),

            const SizedBox(height: 16.0), // Spacing between inputs
            TextFormField(
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                minimumSize:
                    const Size(120, 48), // Ensures button doesn't resize
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
                  String purpose = currentHighestIndexAccount.purpose;
                  String coinType = currentHighestIndexAccount.coinType;
                  String accountIndex = "$newAccountIndex";
                  String walletUuid = currentHighestIndexAccount.walletUuid;
                  String password = passwordController.text;

                  context.read<AccountFormBloc>().add(Submit(
                      name: name,
                      purpose: purpose,
                      coinType: coinType,
                      accountIndex: "$accountIndex'",
                      walletUuid: walletUuid,
                      password: password,
                      importFormat: currentHighestIndexAccount.importFormat));
                  Navigator.of(context).pop();
                }
              },
              child: state == const RemoteDataState.loading()
                  ? const SizedBox(
                      width: 20, height: 20, child: CircularProgressIndicator())
                  : const Text('Submit'),
            ),
          ],
        ),
      );
    });
  }
}
