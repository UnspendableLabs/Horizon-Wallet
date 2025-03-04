import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';

class SecurityView extends StatefulWidget {
  const SecurityView({super.key});

  @override
  State<SecurityView> createState() => _SecurityViewState();
}

class _SecurityViewState extends State<SecurityView> {
  final Map<int, String> _timeoutOptions = const {
    1: '1 minute',
    5: '5 minutes',
    30: '30 minutes',
    120: '2 hours',
    360: '6 hours',
    720: '12 hours',
  };

  int _selectedTimeout = 5;
  bool _requirePassword = false;

  @override
  void initState() {
    super.initState();
    _selectedTimeout = Settings.getValue(
      SettingsKeys.inactivityTimeout.toString(),
      defaultValue: 5,
    )!;
    _requirePassword = Settings.getValue(
          SettingsKeys.requiredPasswordForCryptoOperations.toString(),
          defaultValue: false,
        ) ??
        false;
  }

  void _onTimeoutChanged(int? value) {
    if (value != null) {
      setState(() {
        _selectedTimeout = value;
      });
      Settings.setValue(
        SettingsKeys.inactivityTimeout.toString(),
        value,
        notify: true,
      );
    }
  }

  Future<bool> _showPasswordPrompt(BuildContext context) async {
    bool isAuthenticated = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return HorizonPasswordPrompt(
          onPasswordSubmitted: (password) async {
            final wallet = await GetIt.I<WalletRepository>().getCurrentWallet();
            await GetIt.I<EncryptionService>()
                .decrypt(wallet!.encryptedPrivKey, password);

            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop(true);
            }
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
          buttonText: 'Continue',
          title: 'Enter Password',
        );
      },
    ).then((value) {
      isAuthenticated = (value == true);
    });

    return isAuthenticated;
  }

  Future<void> _onPasswordRequirementChanged(bool newValue) async {
    // If the user is trying to switch from true -> false
    if (_requirePassword == true && newValue == false) {
      final bool success = await _showPasswordPrompt(context);

      if (success) {
        setState(() => _requirePassword = false);
        Settings.setValue(
          SettingsKeys.requiredPasswordForCryptoOperations.toString(),
          false,
        );
      }
    } else {
      setState(() => _requirePassword = newValue);
      Settings.setValue(
        SettingsKeys.requiredPasswordForCryptoOperations.toString(),
        newValue,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingsItem(
            title: 'Require password',
            icon: Icons.lock_outline,
            isDarkTheme: isDarkTheme,
            trailing: HorizonToggle(
              value: _requirePassword,
              onChanged: _onPasswordRequirementChanged,
            ),
            onTap: null,
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Require password when signing transactions or granting access to wallet data.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SettingsItem(
            title: 'Inactivity Timeout',
            icon: Icons.timer_outlined,
            isDarkTheme: isDarkTheme,
            trailing: SizedBox(
              width: 120,
              height: 40,
              child: BlurredBackgroundDropdown<int>(
                items: _timeoutOptions.entries
                    .map((entry) => DropdownMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value),
                        ))
                    .toList(),
                onChanged: _onTimeoutChanged,
                selectedValue: _selectedTimeout,
                hintText: 'Select timeout',
              ),
            ),
            onTap: null,
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Period of inactivity before screen locks",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
