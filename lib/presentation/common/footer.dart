import 'package:flutter/material.dart';
import "package:horizon/presentation/colors.dart";
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
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
    );
  }
}
