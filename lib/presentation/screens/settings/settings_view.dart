import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/settings/import_address/import_address_flow.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/reset_wallet_flow.dart';
import 'package:horizon/presentation/screens/settings/security_view.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/seed_phrase_flow.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:horizon/presentation/shell/app_shell.dart';

enum SettingsPage {
  main,
  security,
  seedPhrase,
  importAddress,
  resetWallet,
}

class SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDarkTheme;
  final Widget? trailing;

  const SettingsItem({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    required this.isDarkTheme,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkTheme ? transparentWhite8 : transparentBlack8,
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
                trailing ??
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

class ThemeToggle extends StatelessWidget {
  final bool isDarkTheme;
  final ValueChanged<bool> onChanged;

  const ThemeToggle({
    super.key,
    required this.isDarkTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isDarkTheme),
      child: Container(
        width: 94,
        height: 44,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDarkTheme ? transparentWhite8 : transparentBlack8,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  isDarkTheme ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                width: 36,
                height: 32,
                decoration: BoxDecoration(
                  color: transparentPurple16,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.dark_mode_outlined,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                Container(
                  width: 36,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.light_mode_outlined,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsView extends StatefulWidget {
  const SettingsView({
    super.key,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsPage _currentPage = SettingsPage.main;

  void _navigateBack() {
    setState(() {
      _currentPage = SettingsPage.main;
    });
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case SettingsPage.main:
        return "Settings";
      case SettingsPage.security:
        return "Security";
      case SettingsPage.seedPhrase:
        return "Seed Phrase";
      case SettingsPage.importAddress:
        return "Import Address";
      case SettingsPage.resetWallet:
        return "Reset Wallet";
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case SettingsPage.main:
        return _buildMainSettings();
      case SettingsPage.security:
        return const SecurityView();
      case SettingsPage.seedPhrase:
        return const SeedPhraseFlow();
      case SettingsPage.importAddress:
        return ImportAddressFlow(onNavigateBack: _navigateBack);
      case SettingsPage.resetWallet:
        return const ResetWalletFlow();
    }
  }

  Widget _buildMainSettings() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      children: [
        const SizedBox(height: 10),
        SettingsItem(
          title: 'Security',
          icon: Icons.security,
          isDarkTheme: isDarkTheme,
          onTap: () {
            setState(() {
              _currentPage = SettingsPage.security;
            });
          },
        ),
        SettingsItem(
          title: 'Seed phrase',
          icon: Icons.key,
          isDarkTheme: isDarkTheme,
          onTap: () {
            setState(() {
              _currentPage = SettingsPage.seedPhrase;
            });
          },
        ),
        SettingsItem(
          title: 'Import new address',
          icon: Icons.add_circle_outline,
          isDarkTheme: isDarkTheme,
          onTap: () {
            setState(() {
              _currentPage = SettingsPage.importAddress;
            });
          },
        ),
        SettingsItem(
          title: 'Reset wallet',
          icon: Icons.restore,
          isDarkTheme: isDarkTheme,
          onTap: () {
            setState(() {
              _currentPage = SettingsPage.resetWallet;
            });
          },
        ),
        SettingsItem(
          title: 'Appearance',
          icon: Icons.palette_outlined,
          isDarkTheme: isDarkTheme,
          trailing: ThemeToggle(
            isDarkTheme: isDarkTheme,
            onChanged: (value) {
              context.read<ThemeBloc>().add(ThemeToggled());
            },
          ),
        ),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: transparentPurple16,
              border: Border.all(
                color: isDarkTheme ? transparentWhite8 : transparentBlack8,
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
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Lock Screen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => const CircularProgressIndicator(),
        success: (session) => Material(
              color: isDarkTheme ? Colors.black : Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Scaffold(
                    backgroundColor: isDarkTheme ? offBlack : offWhite,
                    appBar: AppBar(
                      backgroundColor: isDarkTheme ? offBlack : offWhite,
                      elevation: 0,
                      centerTitle: false,
                      leadingWidth: 40,
                      toolbarHeight: 74,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 18.0),
                        child: Text(
                          _getPageTitle(),
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
                          onPressed: _currentPage != SettingsPage.main
                              ? _navigateBack
                              : () {
                                  AppShell.navigateToTab(context, 0);
                                },
                        ),
                      ),
                    ),
                    body: _buildCurrentPage(),
                  ),
                ),
              ),
            ));
  }
}
