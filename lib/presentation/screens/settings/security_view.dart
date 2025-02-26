import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/presentation/screens/dashboard/view/dashboard_page.dart';
import 'package:horizon/presentation/screens/settings/settings_view.dart';

class SecurityView extends StatelessWidget {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 40,
        toolbarHeight: 74,
        title: Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: Text(
            "Security",
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
              // Find the closest ancestor TabController and switch back to settings tab
              final bottomTabController = context
                  .findAncestorStateOfType<DashboardPageState>()
                  ?.bottomTabController;
              if (bottomTabController != null) {
                bottomTabController.animateTo(1); // Switch to settings tab
              }
              Navigator.of(context).pop(); // Go back
            },
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PasswordProtectedSwitch(
              title: 'Require password',
              description:
                  "Require password when signing transactions or granting access to wallet data.",
              settingKey:
                  SettingsKeys.requiredPasswordForCryptoOperations.toString(),
              defaultValue: false,
            ),
            const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
