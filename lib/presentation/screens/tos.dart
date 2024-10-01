import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final fontColor = isDarkTheme ? Colors.white70 : Colors.black;
    final backgroundColor = isDarkTheme ? darkNavyDarkTheme : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SelectableRegion(
        focusNode: FocusNode(),
        selectionControls: MaterialTextSelectionControls(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: fontColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Effective Date: September 24, 2024',
                  style: TextStyle(
                      color: isDarkTheme ? Colors.grey : Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                _buildNumberedList([
                  _buildSection(
                    'Acceptance of Terms',
                    'By accessing or using Horizon Wallet, a product of Unspendable Labs Inc., a Delaware Corporation ("we," "our," or "us"), you agree to comply with and be bound by these Terms of Service ("Terms"). If you do not agree to these Terms, you are not permitted to use Horizon Wallet.',
                    fontColor,
                  ),
                  _buildSection(
                    'Modification of Terms',
                    'We reserve the right to modify these Terms at any time. Any changes will be effective immediately upon posting the updated Terms on our website. Your continued use of Horizon Wallet after any such changes constitutes your acceptance of the new Terms. It is your responsibility to review these Terms periodically.',
                    fontColor,
                  ),
                  _buildSection(
                    'Use of the Service',
                    'You agree to use Horizon Wallet only for lawful purposes and in compliance with all applicable laws and regulations. You acknowledge that using Horizon Wallet involves inherent risks, including but not limited to the loss of digital assets, and you agree that you understand these risks.',
                    fontColor,
                  ),
                  _buildSection(
                    'Software License',
                    'Horizon Wallet is licensed under the terms available at ',
                    fontColor,
                    trailingWidget: const LinkText(
                      'https://github.com/UnspendableLabs/Horizon-Wallet/blob/main/LICENSE.md',
                      'https://github.com/UnspendableLabs/Horizon-Wallet/blob/main/LICENSE.md',
                    ),
                  ),
                  _buildSection(
                    'Data Sources',
                    'The data and information presented on Horizon Wallet are sourced from public blockchain networks and other services. While we strive to provide accurate and up-to-date information, we make no warranties or representations regarding the completeness, accuracy, or reliability of the data displayed.',
                    fontColor,
                  ),
                  _buildSection(
                    'Privacy',
                    'Horizon Wallet does not collect or store any personal information. As a non-custodial wallet, all data related to your wallet and transactions is stored locally on your device. Please review our ',
                    fontColor,
                    trailingWidget: InkWell(
                      onTap: () => context.go('/privacy-policy'),
                      child: const Text(
                        'Privacy Policy',
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  _buildSection(
                    'Disclaimer of Warranties',
                    'Horizon Wallet and all information, content, and materials included or otherwise made available to you through it are provided on an "as is" and "as available" basis. We make no representations or warranties of any kind, express or implied, regarding the operation of Horizon Wallet or the information, content, or materials provided.\n\nYou acknowledge that blockchain technology and cryptocurrencies carry inherent risks, including but not limited to security vulnerabilities, technical glitches, and market volatility. We do not warrant that Horizon Wallet is free of viruses or other harmful components. Use of Horizon Wallet is at your own risk.\n\nNo Financial Advice: Nothing on Horizon Wallet constitutes professional, financial, or investment advice. All information is provided for informational purposes only, and you should not rely on it for making investment decisions.',
                    fontColor,
                  ),
                  _buildSection(
                    'Limitation of Liability',
                    'To the fullest extent permitted by applicable law, Unspendable Labs Inc. shall not be liable for any direct, indirect, incidental, special, consequential, or exemplary damages, including but not limited to loss of funds, data, or other intangible losses, resulting from:\n\n- Your use of or inability to use Horizon Wallet.\n- Any unauthorized access to or alteration of your data.\n- Any loss or damage arising from your failure to maintain the security of your wallet, seed phrase, password, and private keys.\n- Any other matter relating to Horizon Wallet.',
                    fontColor,
                  ),
                  _buildSection(
                    'User Conduct and Responsibility',
                    'You are solely responsible for all activities that occur in connection with your use of Horizon Wallet. You agree not to engage in any conduct that is unlawful, harmful, or otherwise objectionable. You acknowledge that you are responsible for maintaining the security of your wallet, seed phrase, password, and private keys, and we have no ability to retrieve or restore your credentials if they are lost or stolen.',
                    fontColor,
                  ),
                  _buildSection(
                    'Intellectual Property Rights',
                    'While Horizon Wallet utilizes software and displays data derived from various sources, certain elements are proprietary to Unspendable Labs Inc. This includes, but is not limited to, our trademarks, logos, proprietary graphics, and any original content or features provided on the website or within the software not covered by external licenses.\n\nThese proprietary elements are the property of Unspendable Labs Inc. and are protected by applicable intellectual property laws. You may not use our trademarks, logos, or proprietary content without our prior written consent.',
                    fontColor,
                  ),
                  _buildSection(
                    'Security Risks',
                    'We do not warrant that Horizon Wallet is free of viruses or other harmful components. You are responsible for implementing sufficient security measures to protect your wallet, seed phrase, password, private keys, and devices. We are not responsible for any loss or damage arising from unauthorized access to your wallet or failure to implement appropriate security precautions.',
                    fontColor,
                  ),
                  _buildSection(
                    'Age Restriction',
                    'Horizon Wallet is intended for users who are at least 18 years old (or the age of majority in your jurisdiction). By using the service, you represent and warrant that you meet this age requirement and have the legal capacity to enter into this agreement.',
                    fontColor,
                  ),
                  _buildSection(
                    'Governing Law and Jurisdiction',
                    'These Terms and any disputes arising out of or related to them will be governed by and construed in accordance with the laws of the State of Delaware, without regard to its conflict of law rules. Any legal actions or proceedings arising out of or relating to these Terms shall be brought exclusively in the federal or state courts located in Kent County, Delaware, and you consent to the jurisdiction of such courts.',
                    fontColor,
                  ),
                  _buildSection(
                    'Entire Agreement',
                    'These Terms, along with our Privacy Policy, constitute the entire agreement between you and Unspendable Labs Inc. regarding your use of Horizon Wallet and supersede any prior agreements between you and us.',
                    fontColor,
                  ),
                  _buildSection(
                    'Contact Information',
                    'If you have any questions about these Terms of Service, please contact us at ',
                    fontColor,
                    trailingWidget: const LinkText(
                      'contact@unspendablelabs.com',
                      'mailto:contact@unspendablelabs.com',
                    ),
                  ),
                ], fontColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<Widget> items, Color fontColor) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}.',
              style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(child: items[index]),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, String content, Color fontColor,
      {Widget? trailingWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: fontColor,
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: TextStyle(color: fontColor),
            children: [
              TextSpan(text: content),
              if (trailingWidget != null) WidgetSpan(child: trailingWidget),
            ],
          ),
        ),
      ],
    );
  }
}

class LinkText extends StatelessWidget {
  final String text;
  final String url;

  const LinkText(this.text, this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // You might want to show a snackbar or dialog here to inform the user
      // that the link couldn't be opened.
    }
  }
}
