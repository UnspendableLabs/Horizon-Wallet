import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? darkNavyDarkTheme : greyLightTheme,
      ),
      child: SizedBox(
        height: 30,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => context.go("/tos"),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: neonBlueDarkTheme,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () => context.go("/privacy-policy"),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: neonBlueDarkTheme,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () {
                  launchUrl(Uri.parse(
                      "https://github.com/UnspendableLabs/Horizon-Wallet/releases/tag/v1.2.4"));
                },
                child: const Text(
                  'v1.2.4',
                  style: TextStyle(
                    color: neonBlueDarkTheme,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
