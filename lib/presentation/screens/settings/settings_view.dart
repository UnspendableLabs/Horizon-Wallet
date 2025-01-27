import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/main.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

enum SettingsValues {
  inactivityTimeout,
  lostFocusTimeout,
}

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => CircularProgressIndicator(),
        success: (session) => SettingsScreen(title: "Settings", children: [
              SettingsGroup(
                title: "Lock Screen",
                children: [
                  DropDownSettingsTile<int>(
                    title: 'Inactivity Timeout',
                    subtitle:
                        'Period before screen locks after last user interaction',
                    settingKey: SettingsValues.inactivityTimeout.toString(),
                    values: <int, String>{
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
                    values: <int, String>{
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
