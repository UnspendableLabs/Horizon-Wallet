import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:horizon/presentation/colors.dart";

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () =>
                  _launchURL('https://explorer.unspendablelabs.com/tos'),
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
              onPressed: () => _launchURL(
                  'https://explorer.unspendablelabs.com/privacy-policy'),
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
