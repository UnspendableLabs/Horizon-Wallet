import 'package:flutter/material.dart';
import "package:horizon/presentation/colors.dart";
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';

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
                    color: neonBlueDarkThemeButtonTextColor,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 20), // Add some space between the links
              TextButton(
                onPressed: () => context.go("/privacy-policy"),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: neonBlueDarkThemeButtonTextColor,
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
