import 'package:flutter/material.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';


class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => const CircularProgressIndicator(),
        success: (session) => SettingsScreen(title: "Settings", children: [
              SettingsGroup(
                title: "Security",
                children: [
                  SwitchSettingsTile(
                    title: 'Require password',
                    enabledLabel:
                        'Require password when signing transactions or granting access to wallet data. ( Disabling requires reauthentication )',
                    disabledLabel:
                        "Require password when signing transactions or granting access to wallet data.",
                    settingKey: SettingsKeys.requiredPasswordForCryptoOperations
                        .toString(),
                    defaultValue: true,
                    onChange: (value) {
                      if (value == false) {
                        context.read<SessionStateCubit>().onLogout();
                      }
                    },
                  ),
                  DropDownSettingsTile<int>(
                    title: 'Inactivity Timeout',
                    subtitle:
                        'Period before screen locks after last user interaction',
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
                  DropDownSettingsTile<int>(
                    title: 'Lost Focus Timeout',
                    subtitle: 'Period before screen locks after focus is lost',
                    settingKey: SettingsKeys.lostFocusTimeout.toString(),
                    values: const <int, String>{
                      1: '1 minute',
                      5: '5 minutes',
                      30: '30 minutes',
                      120: '2 hours',
                      360: '6 hours',
                      720: '12 hours',
                    },
                    selected: Settings.getValue(
                        SettingsKeys.lostFocusTimeout.toString(),
                        defaultValue: 1)!,
                    onChange: (value) {
                      Settings.setValue(
                          SettingsKeys.lostFocusTimeout.toString(), value,
                          notify: true);
                    },
                  ),
                ],
              )
            ]));
  }
}
