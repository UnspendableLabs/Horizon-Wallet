import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/utils/horizon_market_referral.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    void launchURL(String path) async {
      final uri = withWalletReferral(Uri.parse("https://horizon.market/$path"));
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(height: 1.75),
        children: [
          const TextSpan(
            text: "By proceeding, I agree to Horizon Wallet's\n",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchURL("wallet-terms"),
          ),
          const TextSpan(
            text: " and ",
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => launchURL("wallet-privacy"),
          ),
        ],
      ),
    );
  }
}
