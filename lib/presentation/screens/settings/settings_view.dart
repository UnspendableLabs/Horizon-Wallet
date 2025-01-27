import 'package:flutter/material.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

enum SettingsValues {
  requiredPasswordForCryptoOperations,
  inactivityTimeout,
  lostFocusTimeout,
}

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
                    subtitle: 'Require password when signing transactions or granting access to wallet data',
                    settingKey: SettingsValues.requiredPasswordForCryptoOperations.toString(),
                    defaultValue: true,
                  ),
                  DropDownSettingsTile<int>(
                    title: 'Inactivity Timeout',
                    subtitle:
                        'Period before screen locks after last user interaction',
                    settingKey: SettingsValues.inactivityTimeout.toString(),
                    values: const <int, String>{
                      1: '1 minute',
                      5: '5 minutes',
                      30: '30 minutes',
                      120: '2 hours',
                      360: '6 hours',
                      720: '12 hours',
                    },
                    selected: Settings.getValue(
                        SettingsValues.inactivityTimeout.toString(),
                        defaultValue: 5)!,
                    onChange: (value) {
                      Settings.setValue(
                          SettingsValues.inactivityTimeout.toString(), value,
                          notify: true);
                    },
                  ),
                  DropDownSettingsTile<int>(
                    title: 'Lost Focus Timeout',
                    subtitle: 'Period before screen locks after focus is lost',
                    settingKey: SettingsValues.lostFocusTimeout.toString(),
                    values: const <int, String>{
                      1: '1 minute',
                      5: '5 minutes',
                      30: '30 minutes',
                      120: '2 hours',
                      360: '6 hours',
                      720: '12 hours',
                    },
                    selected: Settings.getValue(
                        SettingsValues.lostFocusTimeout.toString(),
                        defaultValue: 1)!,
                    onChange: (value) {
                      Settings.setValue(
                          SettingsValues.lostFocusTimeout.toString(), value,
                          notify: true);
                    },
                  ),
                ],
              )
            ]));
  }
}
