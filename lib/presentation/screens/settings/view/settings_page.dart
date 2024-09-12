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
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const double _bottomPaddingForButton = 150.0;
const double _buttonHeight = 56.0;
const double _pagePadding = 16.0;

class PasswordPrompt extends StatefulWidget {
  final String accountUuid;

  final AccountSettingsRepository accountSettingsRepository =
      GetIt.I.get<AccountSettingsRepository>();

  PasswordPrompt({required this.accountUuid, super.key});

  @override
  State<PasswordPrompt> createState() => _PasswordPromptState();
}

class _PasswordPromptState extends State<PasswordPrompt> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PasswordPromptBloc, PasswordPromptState>(
        builder: (context, state) {
      return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HorizonTextFormField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: passwordController,
              label: "Password",
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
                  const Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Divider(
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
                                state.whenOrNull(validate: () {
                                  return;
                                });

                                String password = passwordController.text;

                                int gapLimit = widget.accountSettingsRepository
                                    .getGapLimit(widget.accountUuid);

                                context.read<PasswordPromptBloc>().add(Submit(
                                      password: password,
                                      gapLimit: gapLimit,
                                    ));
                                // Process data.
                              }
                            },
                            child: state.maybeWhen(
                              validate: () => const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator()),
                              orElse: () => const Text('Submit'),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class SettingsPage extends StatelessWidget {
  final cacheProvider = GetIt.I.get<CacheProvider>();
  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();

    Account? account = shell.state.maybeWhen(
        success: (state) => state.accounts
            .firstWhere((account) => account.uuid == state.currentAccountUuid),
        orElse: () => null);

    if (account == null) {
      throw Exception("invariant: account is null");
    }

    final initialGapLimit =
        GetIt.I.get<AccountSettingsRepository>().getGapLimit(account.uuid);
    SliverWoltModalSheetPage passwordPrompt(
      BuildContext modalSheetContext,
      TextTheme textTheme,
      int gapLimit,
    ) {
      final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
      return WoltModalSheetPage(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? dialogBackgroundColorDarkTheme
            : dialogBackgroundColorLightTheme,
        isTopBarLayerAlwaysVisible: true,
        topBar: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0.0, 0.0),
                  child: Text(
                    'Enter password',
                    style: TextStyle(
                        color: isDarkTheme ? mainTextWhite : mainTextBlack,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, right: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ],
          ),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 675),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                _pagePadding, 50, _pagePadding, _pagePadding),
            child: Center(
              child: PasswordPrompt(
                accountUuid: account.uuid,
              ),
            ),
          ),
        ),
      );
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
              content: SelectableText(msg),
            ));
          }, success: (password, gapLimit) async {
            context.read<AddressesBloc>().add(Update(
                accountUuid: account.uuid,
                gapLimit: gapLimit,
                password: password));

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Success"),
            ));

            await Future.delayed(const Duration(milliseconds: 500));

            Navigator.of(context).pop();
          }, initial: (maybeGapLimit) {
            if (maybeGapLimit != null) {
              // TODO put in account settings repository
              Settings.setValue('${account.uuid}:gap-limit', maybeGapLimit,
                  notify: true);
            }
          }, prompt: (gapLimit) {
            WoltModalSheet.show<void>(
              context: context,
              onModalDismissedWithBarrierTap: () {
                context
                    .read<PasswordPromptBloc>()
                    .add(Reset(gapLimit: initialGapLimit));

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
        }, builder: (context, state) {
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Address Settings',
                                  ),
                                  BlocListener<LogoutBloc, LogoutState>(
                                    listener: (context, state) {
                                      if (state.logoutState is LoggedOut) {
                                        final shell =
                                            context.read<ShellStateCubit>();
                                        shell.onOnboarding();
                                      }
                                    },
                                    child: FilledButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) {
                                            return BlocProvider.value(
                                              value:
                                                  BlocProvider.of<LogoutBloc>(
                                                      context),
                                              child: AlertDialog(
                                                title: const Text(
                                                    'Confirm Logout'),
                                                content: Text(
                                                  'This will result in deletion of all wallet data. To log back in, you will need to use your seed phrase.',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      GoRouter.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      context
                                                          .read<LogoutBloc>()
                                                          .add(LogoutEvent());
                                                    },
                                                    child: const Text('Logout'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SliderSettingsTile(
                              title: 'Gap Limit',
                              leading: const Icon(Icons.numbers),
                              settingKey: '${account.uuid}:gap-limit',
                              defaultValue: 10,
                              min: 1,
                              max: 50,
                              step: 1,
                              decimalPrecision: 0,
                              onChange: (value) {
                                context.read<PasswordPromptBloc>().add(
                                    Show(initialGapLimit: initialGapLimit));
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
                      error: (error) => SelectableText("Error: $error"),
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
        }));
  }
}
