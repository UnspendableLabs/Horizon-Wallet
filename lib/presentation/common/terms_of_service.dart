import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsOfService extends StatelessWidget {
  final String prefixText;
  final String linkText;
  final String url;

  const TermsOfService({
    super.key,
    this.prefixText = "By proceeding, I agree to Horizon Wallet's ",
    this.linkText = "Terms of Service",
    this.url = "https://horizon.market/terms",
  });

  void _launchURL() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: prefixText,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
          TextSpan(
            text: linkText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            recognizer: TapGestureRecognizer()..onTap = _launchURL,
          ),
        ],
      ),
    );
  }
}
