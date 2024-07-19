import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/account_settings_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_bloc.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_event.dart';
import 'package:horizon/presentation/screens/addresses/bloc/addresses_state.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_bloc.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/logout_state.dart';
import 'package:horizon/presentation/screens/settings/bloc/password_prompt_bloc.dart';
import 'package:horizon/presentation/screens/settings/bloc/password_prompt_event.dart';
import 'package:horizon/presentation/screens/settings/bloc/password_prompt_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _pagePadding = 16.0;

class PasswordPrompt extends StatefulWidget {
  final String accountUuid;

  final AccountSettingsRepository accountSettingsRepository = GetIt.I.get<AccountSettingsRepository>();

  PasswordPrompt({required this.accountUuid, super.key});

  @override
  State<PasswordPrompt> createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<PasswordPrompt> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordPromptBloc, PasswordPromptState>(builder: (context, state) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: "Password", floatingLabelBehavior: FloatingLabelBehavior.always),
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                minimumSize: const Size(120, 48), // Ensures button doesn't resize
              ),
              onPressed: () {
                // Validate will return true if the form is valid, or false if
                // the form is invalid.
                if (_formKey.currentState!.validate()) {
                  state.whenOrNull(validate: () {
                    return;
                  });

                  String password = passwordController.text;

                  int gapLimit = widget.accountSettingsRepository.getGapLimit(widget.accountUuid);

                  context.read<PasswordPromptBloc>().add(Submit(
                        password: password,
                        gapLimit: gapLimit,
                      ));

                  // Process data.
                }
              },
              child: state.maybeWhen(
                validate: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
                orElse: () => const Text('Submit'),
              ),
            ),
          ],
        ),
      );
    });
    // Fill this out in the next step.
  }
}

class SettingsPage extends StatelessWidget {
  final cacheProvider = GetIt.I.get<CacheProvider>();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDarkTheme ? const Color.fromRGBO(35, 35, 58, 1) : const Color.fromRGBO(246, 247, 250, 1);

    Account? account = shell.state.maybeWhen(
        success: (state) => state.accounts.firstWhere((account) => account.uuid == state.currentAccountUuid),
        orElse: () => null);

    if (account == null) {
      throw Exception("invariant: account is null");
    }

    final initialGapLimit = GetIt.I.get<AccountSettingsRepository>().getGapLimit(account.uuid);

    SliverWoltModalSheetPage passwordPrompt(
      BuildContext modalSheetContext,
      TextTheme textTheme,
      int gapLimit,
    ) {
      return WoltModalSheetPage(
          isTopBarLayerAlwaysVisible: true,
          topBarTitle: Text('Enter password', style: textTheme.titleSmall),
          trailingNavBarWidget: IconButton(
            padding: const EdgeInsets.all(_pagePadding),
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<PasswordPromptBloc>().add(Reset(gapLimit: initialGapLimit));

              Navigator.of(modalSheetContext).pop();
            },
          ),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(
                _pagePadding,
                _pagePadding,
                _pagePadding,
                _bottomPaddingForButton,
              ),
              child: PasswordPrompt(
                accountUuid: account.uuid,
              )));
    }

    return BlocProvider(
      create: (context) => LogoutBloc(
        walletRepository: GetIt.I.get<WalletRepository>(),
        accountRepository: GetIt.I.get<AccountRepository>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        cacheProvider: GetIt.I.get<CacheProvider>(),
      ),
      child: BlocConsumer<PasswordPromptBloc, PasswordPromptState>(
        listener: (context, state) {
          state.whenOrNull(error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg),
            ));
          }, success: (password, gapLimit) async {
            context.read<AddressesBloc>().add(Update(accountUuid: account.uuid, gapLimit: gapLimit, password: password));

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Success"),
            ));

            await Future.delayed(const Duration(milliseconds: 500));

            Navigator.of(context).pop();
          }, initial: (maybeGapLimit) {
            if (maybeGapLimit != null) {
              // TODO put in account settings repository
              Settings.setValue('${account.uuid}:gap-limit', maybeGapLimit, notify: true);
            }
          }, prompt: (gapLimit) {
            WoltModalSheet.show<void>(
              context: context,
              onModalDismissedWithBarrierTap: () {
                context.read<PasswordPromptBloc>().add(Reset(gapLimit: initialGapLimit));

                Navigator.of(context).pop();
              },
              pageListBuilder: (modalSheetContext) {
                final textTheme = Theme.of(context).textTheme;
                return [passwordPrompt(modalSheetContext, textTheme, gapLimit)];
              },
              modalTypeBuilder: (context) {
                final size = MediaQuery.sizeOf(context).width;
                if (size < 768.0) {
                  return WoltModalType.bottomSheet;
                } else {
                  return WoltModalType.dialog;
                }
              },
            );
          });
        },
        builder: (context, state) {
          return Column(
            children: [
              Container(
                child: Expanded(
                  child: SettingsScreen(
                    hasAppBar: false,
                    key: Key(account.uuid),
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Address Settings',
                                  ),
                                  BlocListener<LogoutBloc, LogoutState>(
                                    listener: (context, state) {
                                      print('in the listener');
                                      if (state.logoutState is LoggedOut) {
                                        GoRouter.of(context).go('/onboarding');
                                      }
                                    },
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.read<LogoutBloc>().add(LogoutEvent());
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SliderSettingsTile(
                              title: 'Address Settings',
                              subtitle: 'Gap Limit',
                              leading: const Icon(Icons.numbers),
                              settingKey: '${account.uuid}:gap-limit',
                              defaultValue: 10,
                              min: 1,
                              max: 50,
                              step: 1,
                              decimalPrecision: 0,
                              onChange: (value) {
                                context.read<PasswordPromptBloc>().add(Show(initialGapLimit: initialGapLimit));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height - 220,
                child: BlocBuilder<AddressesBloc, AddressesState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () => const Text("initial"),
                      loading: () => const Text("loading"),
                      error: (error) => Text("Error: $error"),
                      success: (addresses) => ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            title: SelectableText(addresses[index].address),
                            subtitle: Text(addresses[index].index.toString()),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
