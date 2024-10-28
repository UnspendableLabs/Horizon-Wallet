import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

final validAccount = RegExp(r"^\d\'$");

class ImportAddressPkForm extends StatefulWidget {
  const ImportAddressPkForm({super.key});

  @override
  State<ImportAddressPkForm> createState() => _ImportAddressPkFormState();
}

class _ImportAddressPkFormState extends State<ImportAddressPkForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final pkController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFormKey = GlobalKey<FormState>();

  ImportAddressPkFormat? selectedFormat = ImportAddressPkFormat.segwit;

  @override
  void initState() {
    super.initState();
    context.read<ImportAddressPkBloc>().add(ResetForm());
  }

  @override
  void dispose() {
    pkController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    // List<Account>? accounts = shell.state.maybeWhen(success: (state) => state.accounts, orElse: () => null);

    // if (accounts == null) {
    //   throw Exception("invariant: accounts are null");
    // }

    // Account? currentHighestIndexAccount = shell.state.maybeWhen(
    //     success: (state) {
    //       // Find the account with the highest hardened account index
    //       Account? highestAccount;
    //       int maxIndex = -1;

    //       for (var account in state.accounts) {
    //         int currentIndex = int.parse(account.accountIndex.replaceAll("'", ""));
    //         if (currentIndex > maxIndex) {
    //           maxIndex = currentIndex;
    //           highestAccount = account;
    //         }
    //       }
    //       return highestAccount;
    //     },
    //     orElse: () => null);

    // if (currentHighestIndexAccount == null) {
    //   throw Exception("invariant: account is null");
    // }

    // int newAccountIndex = int.parse(currentHighestIndexAccount.accountIndex.replaceAll("'", "")) + 1;

    return BlocConsumer<ImportAddressPkBloc, ImportAddressPkState>(
      listener: (context, state) {
        final cb = switch (state) {
          ImportAddressPkStep2(state: var state) when state is Step2Success =>
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
          ImportAddressPkStep1() => Builder(builder: (context) {
              void handleSubmit() {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  context.read<ImportAddressPkBloc>().add(Finalize());
                }
              }

              return Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        HorizonUI.HorizonTextFormField(
                          controller: nameController,
                          label: "Name",
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                          onEditingComplete: handleSubmit,
                        ),
                        const SizedBox(height: 16),
                        HorizonUI.HorizonTextFormField(
                          controller: pkController,
                          label: "Private Key",
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a private key';
                            }
                            return null;
                          },
                          onEditingComplete: handleSubmit,
                        ),
                        const SizedBox(height: 16),
                        HorizonUI.HorizonDropdownMenu(
                          selectedValue: selectedFormat,
                          items: ImportAddressPkFormat.values
                              .map((e) =>
                                  DropdownMenuItem<ImportAddressPkFormat>(
                                    value: e,
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedFormat = value;
                            });
                          },
                        ),
                        HorizonUI.HorizonDialogSubmitButton(
                          textChild: const Text('CONTINUE'),
                          onPressed: handleSubmit,
                        )
                      ],
                    ),
                  ),
                ],
              );
            }),
          ImportAddressPkStep2(state: var state) => Builder(builder: (context) {
              void handleSubmit() {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (passwordFormKey.currentState!.validate()) {
                  if (state == Step2Loading()) {
                    return;
                  }

                  String pk = pkController.text;
                  String password = passwordController.text;

                  context.read<ImportAddressPkBloc>().add(Submit(
                        pk: pk,
                        password: password,
                        format: selectedFormat!,
                        name: nameController.text,
                      ));
                }
              }

              return Form(
                key: passwordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HorizonUI.HorizonTextFormField(
                      enabled: state is! Step2Loading,
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
                    if (state is Step2Error)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          state.error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    HorizonUI.HorizonDialogSubmitButton(
                      textChild: state is Step2Loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('SUBMIT'),
                      onPressed: state is Step2Loading ? () {} : handleSubmit,
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
