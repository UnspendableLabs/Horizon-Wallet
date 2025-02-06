import 'package:flutter/material.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:go_router/go_router.dart';

import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';

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
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => const CircularProgressIndicator(),
        success: (session) =>
            SettingsScreen(title: "Settings", hasAppBar: false, children: [
              AppBar(
                title: const Text("Settings"),
                leading: BackButton(
                  onPressed: () {
                    context.go("/dashboard");
                  },
                ),
              ),
              SettingsGroup(
                title: "Security",
                children: [
                  PasswordProtectedSwitch(
                    title: 'Require password',
                    description:
                        "Require password when signing transactions or granting access to wallet data.",
                    settingKey: SettingsKeys.requiredPasswordForCryptoOperations
                        .toString(),
                    defaultValue: true,
                  ),
                  const Divider(height: 0.0),
                  DropDownSettingsTile<int>(
                    title: 'Inactivity Timeout',
                    subtitle: 'Period of inactivity before screen locks',
                    settingKey: SettingsKeys.inactivityTimeout.toString(),
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
                          SettingsKeys.inactivityTimeout.toString(), value,
                          notify: true);
                    },
                  ),
                ],
              )
            ]));
  }
}
