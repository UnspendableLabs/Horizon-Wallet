import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import 'package:horizon/presentation/shell/account_form/bloc/account_form_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

final validAccount = RegExp(r"^\d\'$");

class AddAccountForm extends StatefulWidget {
  const AddAccountForm({super.key});

  @override
  State<AddAccountForm> createState() => _AddAccountFormState();
}

class _AddAccountFormState extends State<AddAccountForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFormKey = GlobalKey<FormState>();
  final nativeHorizonAccountBlurb =
      "An account is a grouping for your balances. You can only spend from one account at a time, but you can of course move assets from one account to another. Native Horizon Wallets only support one Bitcoin address per account.";
  final importAccountBlurb =
      "An account is a grouping for your balances. You can only spend from account at a time, but you can of course move assets from one account to another. You can generate multiple addresses for each account. If you don't see an address that should be there, generate additional addresses in the \"Receive\" dialog.";

  @override
  void initState() {
    super.initState();
    context.read<AccountFormBloc>().add(Reset());
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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

    return BlocConsumer<AccountFormBloc, AccountFormState>(
      listener: (context, state) {
        final cb = switch (state) {
          AccountFormStep2(state: var _state) when _state is Step2Success =>
            () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Success"),
              ));

              // Update accounts in shell
              shell.refresh();
            },
          _ => () => {} // TODO: add noop util
        };

        cb();
      },
      builder: (context, state) {
        return switch (state) {
          AccountFormStep1() => Builder(builder: (context) {
              void handleSubmit() {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  context.read<AccountFormBloc>().add(Finalize());
                }
              }

              return Column(
                children: [
                  SelectableText(
                      currentHighestIndexAccount.importFormat ==
                              ImportFormat.horizon
                          ? nativeHorizonAccountBlurb
                          : importAccountBlurb,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16.0),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        HorizonTextFormField(
                          controller: nameController,
                          label: "Name",
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name for your account';
                            }
                            return null;
                          },
                          onEditingComplete: handleSubmit,
                        ),
                        HorizonDialogSubmitButton(
                          textChild: const Text('CONTINUE'),
                          onPressed: handleSubmit,
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
          AccountFormStep2(state: var _state) => Builder(builder: (context) {
              void handleSubmit() {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (passwordFormKey.currentState!.validate()) {
                  if (_state == Step2Loading()) {
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
                }
              }

              return Form(
                key: passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HorizonTextFormField(
                      enabled: _state is! Step2Loading,
                      controller: passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      label: 'Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onEditingComplete: handleSubmit,
                    ),
                    if (_state is Step2Error)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          _state.error,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 16),
                    HorizonDialogSubmitButton(
                      textChild: _state is Step2Loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('SUBMIT'),
                      onPressed: _state is Step2Loading ? () {} : handleSubmit,
                    )
                  ],
                ),
              );

              return Form(
                key: passwordFormKey,
                child: Column(
                  children: [
                    HorizonTextFormField(
                      enabled: _state != Step2Loading(),
                      controller: passwordController,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      label: 'Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }

                        return null;
                      },
                      onEditingComplete: handleSubmit,
                    ),
                    HorizonDialogSubmitButton(
                      textChild: switch (_state) {
                        Step2Loading() => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator()),
                        _ => const Text('SUBMIT')
                      },
                      onPressed: handleSubmit,
                    )
                  ],
                ),
              );
            }),
        };
      },
    );
  }
}
