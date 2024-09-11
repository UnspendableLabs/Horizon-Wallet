import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import "package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart";
import "package:horizon/presentation/shell/account_form/bloc/account_form_event.dart";
import 'package:horizon/presentation/shell/account_form/bloc/account_form_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
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
  final passwordController = TextEditingController();
  final passwordFormKey = GlobalKey<FormState>();

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
        state.whenOrNull(error: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: SelectableText(msg),
          ));
        }, success: (account) async {
          // update accounts in shell
          shell.refresh();

          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Success"),
          ));

          await Future.delayed(const Duration(milliseconds: 500));
        });
      },
      builder: (context, state) {
        return state.maybeWhen(
          initial: () => Column(
            children: [
              SelectableText(
                  currentHighestIndexAccount.importFormat ==
                          ImportFormat.horizon
                      ? "An account is a grouping for your balances. You can only spend from one account at a time, but you can of course move assets from one account to another. Native Horizon Wallets only support one Bitcoin address per account."
                      : "An account is a grouping for your balances. You can only spend from account at a time, but you can of course move assets from one account to another. You can generate multiple addresses for each account. If you don't see an address that should be there, generate additional addresses in the \"Receive\" dialog.",
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
                    ),
                    HorizonDialogSubmitButton(
                      textChild: const Text('CONTINUE'),
                      onPressed: () {
                        // Validate will return true if the form is valid, or false if
                        // the form is invalid.
                        if (_formKey.currentState!.validate()) {
                          if (state == const AccountFormState.loading()) {
                            return;
                          }
                          context.read<AccountFormBloc>().add(Finalize());
                        }
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
          orElse: () {
            return Form(
              key: passwordFormKey,
              child: Column(
                children: [
                  HorizonTextFormField(
                    enabled: state != const AccountFormState.loading(),
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
                  ),
                  HorizonDialogSubmitButton(
                    textChild: state.maybeWhen(
                        loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator()),
                        success: (_) => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator()),
                        orElse: () => const Text('SUBMIT')),
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (passwordFormKey.currentState!.validate()) {
                        if (state == const AccountFormState.loading()) {
                          return;
                        }

                        // get name field from form

                        String name = nameController.text;
                        String purpose = currentHighestIndexAccount.purpose;
                        String coinType = currentHighestIndexAccount.coinType;
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
                            importFormat:
                                currentHighestIndexAccount.importFormat));
                      }
                    },
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
