import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/secure_kv_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/reset_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/reset/view/reset_dialog.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/view/import_address_pk_form.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/dashboard/view_seed_phrase_form/view/view_seed_phrase_form.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDarkTheme;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDarkTheme
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: isDarkTheme
                          ? Colors.white.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordProtectedSwitch extends StatefulWidget {
  final String title;
  final String description;
  final String settingKey;
  final bool defaultValue;

  const PasswordProtectedSwitch({
    super.key,
    required this.title,
    required this.description,
    required this.settingKey,
    this.defaultValue = true,
  });

  @override
  _PasswordProtectedSwitchState createState() =>
      _PasswordProtectedSwitchState();
}

class _PasswordProtectedSwitchState extends State<PasswordProtectedSwitch> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = Settings.getValue<bool>(
          widget.settingKey,
          defaultValue: widget.defaultValue,
        ) ??
        widget.defaultValue;
  }

  Future<bool> _showPasswordPrompt(BuildContext context) async {
    bool isAuthenticated = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        String? error;
        final TextEditingController controller = TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter Password'),
              content: TextField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: error,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final enteredPassword = controller.text;
                      final wallet =
                          await GetIt.I<WalletRepository>().getCurrentWallet();
                      await GetIt.I<EncryptionService>()
                          .decrypt(wallet!.encryptedPrivKey, enteredPassword);

                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop(true);
                      }
                    } catch (e) {
                      setState(() {
                        error = "Invalid password";
                      });
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) {
      isAuthenticated = (value == true);
    });

    return isAuthenticated;
  }

  Future<void> _onSwitchChanged(bool newValue) async {
    // If the user is trying to switch from true -> false
    if (_value == true && newValue == false) {
      final bool success = await _showPasswordPrompt(context);

      if (success) {
        setState(() => _value = false);
        Settings.setValue(widget.settingKey, false);
      } else {}
    } else {
      setState(() => _value = newValue);
      Settings.setValue(widget.settingKey, newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      tileColor: Theme.of(context).cardTheme.color, // or 'surfaceVariant'

      title: Text(
          style: TextStyle(
              color: Theme.of(context).dialogTheme.contentTextStyle?.color),
          widget.title),
      subtitle: Text(widget.description),
      value: _value,
      onChanged: _onSwitchChanged,
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => const CircularProgressIndicator(),
        success: (session) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: false,
                leadingWidth: 40,
                toolbarHeight: 74,
                title: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(left: 9.0, top: 18.0),
                  child: BackButton(
                    color: isDarkTheme ? Colors.white : Colors.black,
                    onPressed: () {
                      // Find the closest ancestor TabController
                      final bottomTabController = context
                          .findAncestorStateOfType<DashboardPageState>()
                          ?.bottomTabController;
                      if (bottomTabController != null) {
                        bottomTabController.animateTo(0);
                      }
                    },
                  ),
                ),
              ),
              body: ListView(
                children: [
                  const SizedBox(height: 10),
                  SettingsItem(
                    title: 'Security',
                    icon: Icons.security,
                    isDarkTheme: isDarkTheme,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Security Settings'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PasswordProtectedSwitch(
                                title: 'Require password',
                                description:
                                    "Require password when signing transactions or granting access to wallet data.",
                                settingKey: SettingsKeys
                                    .requiredPasswordForCryptoOperations
                                    .toString(),
                                defaultValue: false,
                              ),
                              const SizedBox(height: 16),
                              DropDownSettingsTile<int>(
                                title: 'Inactivity Timeout',
                                subtitle:
                                    'Period of inactivity before screen locks',
                                settingKey:
                                    SettingsKeys.inactivityTimeout.toString(),
                                values: const <int, String>{
                                  1: '1 minute',
                                  5: '5 minutes',
                                  30: '30 minutes',
                                  120: '2 hours',
                                  360: '6 hours',
                                  720: '12 hours',
                                },
                                selected: Settings.getValue(
                                    SettingsKeys.inactivityTimeout.toString(),
                                    defaultValue: 5)!,
                                onChange: (value) {
                                  Settings.setValue(
                                      SettingsKeys.inactivityTimeout.toString(),
                                      value,
                                      notify: true);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    title: 'Seed phrase',
                    icon: Icons.key,
                    isDarkTheme: isDarkTheme,
                    onTap: () {
                      HorizonUI.HorizonDialog.show(
                        context: context,
                        body: const HorizonUI.HorizonDialog(
                          includeBackButton: false,
                          includeCloseButton: true,
                          title: "View wallet seed phrase",
                          body: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: ViewSeedPhraseFormWrapper(),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    title: 'Import new address',
                    icon: Icons.add_circle_outline,
                    isDarkTheme: isDarkTheme,
                    onTap: () {
                      HorizonUI.HorizonDialog.show(
                        context: context,
                        body: Builder(builder: (context) {
                          final bloc = context.watch<ImportAddressPkBloc>();
                          final cb = switch (bloc.state) {
                            ImportAddressPkStep2() => () {
                                bloc.add(ResetForm());
                              },
                            _ => () {
                                Navigator.of(context).pop();
                              },
                          };
                          return HorizonUI.HorizonDialog(
                            onBackButtonPressed: cb,
                            title: "Import address private key",
                            body: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: ImportAddressPkForm(),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  SettingsItem(
                    title: 'Reset wallet',
                    icon: Icons.restore,
                    isDarkTheme: isDarkTheme,
                    onTap: () {
                      HorizonUI.HorizonDialog.show(
                        context: context,
                        body: BlocProvider(
                          create: (context) => ResetBloc(
                            kvService: GetIt.I.get<SecureKVService>(),
                            inMemoryKeyRepository:
                                GetIt.I.get<InMemoryKeyRepository>(),
                            walletRepository: GetIt.I.get<WalletRepository>(),
                            accountRepository: GetIt.I.get<AccountRepository>(),
                            addressRepository: GetIt.I.get<AddressRepository>(),
                            importedAddressRepository:
                                GetIt.I.get<ImportedAddressRepository>(),
                            cacheProvider: GetIt.I.get<CacheProvider>(),
                            analyticsService: GetIt.I.get<AnalyticsService>(),
                          ),
                          child: const ResetDialog(),
                        ),
                      );
                    },
                  ),
                  SettingsItem(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                    isDarkTheme: isDarkTheme,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Appearance Settings'),
                          content: Row(
                            children: [
                              const Text("Theme"),
                              const Spacer(),
                              Switch(
                                value: isDarkTheme,
                                onChanged: (value) {
                                  context.read<ThemeBloc>().add(ThemeToggled());
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 335),
                      child: Container(
                        height: 64,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: transparentPurple16,
                          border: Border.all(
                            color: isDarkTheme
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              context.read<SessionStateCubit>().onLogout();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 11, 14, 11),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 24,
                                    color: isDarkTheme
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Lock Screen',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDarkTheme
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 24,
                                    color: isDarkTheme
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}
