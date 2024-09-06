import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:horizon/presentation/colors.dart";

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Center(
        child: TextButton(
          onPressed: () async {
            const url =
                'https://explorer.unspendablelabs.com/tos'; // Replace with your actual TOS URL
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              // Handle error
              print('Could not launch $url');
            }
          },
          child: const Text(
            'Terms of Service',
            style: TextStyle(
              color: neonBlueDarkThemeButtonTextColor,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
