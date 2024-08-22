import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import "package:horizon/remote_data_bloc/remote_data_state.dart";
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage addAccountModal(
  BuildContext modalSheetContext,
  TextTheme textTheme,
  bool isDarkTheme,
) {
  const double pagePadding = 16.0;

  return WoltModalSheetPage(
    backgroundColor: isDarkTheme
        ? dialogBackgroundColorDarkTheme
        : dialogBackgroundColorLightTheme,
    isTopBarLayerAlwaysVisible: true,
    topBarTitle: Text('Add an account',
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: isDarkTheme ? mainTextWhite : mainTextBlack)),
    trailingNavBarWidget: IconButton(
      padding: const EdgeInsets.all(pagePadding),
      icon: const Icon(Icons.close),
      onPressed: Navigator.of(modalSheetContext).pop,
    ),
    child: const Padding(
        padding: EdgeInsets.fromLTRB(
          pagePadding,
          50,
          pagePadding,
          pagePadding,
        ),
        child: AddAccountForm()),
  );
}

final validAccount = RegExp(r"^\d\'$");

class AddAccountForm extends StatefulWidget {
  final BuildContext? modalSheetContext;
  const AddAccountForm({super.key, this.modalSheetContext});

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
      });
    }, builder: (context, state) {
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HorizonTextFormField(
              controller: nameController,
              isDarkMode: isDarkMode,
              label: "Name:",
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your account';
                }
                return null;
              },
            ),

            const SizedBox(height: 16.0), // Spacing between inputs
            HorizonTextFormField(
              controller: passwordController,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              isDarkMode: isDarkMode,
              label: 'Password',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }

                return null;
              },
            ),
            const SizedBox(height: 16.0), // Spacing between inputs
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Divider(
                      color: isDarkMode
                          ? greyDarkThemeUnderlineColor
                          : greyLightThemeUnderlineColor,
                      thickness: 1.0,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SizedBox(
                          height: 45,
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState!.validate()) {
                                if (state == const RemoteDataState.loading()) {
                                  return;
                                }

                                // get name field from form

                                String name = nameController.text;
                                String purpose =
                                    currentHighestIndexAccount.purpose;
                                String coinType =
                                    currentHighestIndexAccount.coinType;
                                String accountIndex = "$newAccountIndex";
                                String walletUuid =
                                    currentHighestIndexAccount.walletUuid;
                                String password = passwordController.text;

                                context.read<AccountFormBloc>().add(Submit(
                                    name: name,
                                    purpose: purpose,
                                    coinType: coinType,
                                    accountIndex: "$accountIndex'",
                                    walletUuid: walletUuid,
                                    password: password,
                                    importFormat: currentHighestIndexAccount
                                        .importFormat));
                                Navigator.of(context).pop();
                                // return to dashboard if modalSheetContext is not null
                                // this will be the case on smaller screens to close the wolt bottom sheet
                                if (widget.modalSheetContext != null) {
                                  Navigator.of(widget.modalSheetContext!).pop();
                                }
                              }
                            },
                            child: state == const RemoteDataState.loading()
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator())
                                : const Text('Submit'),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
