import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class TermsOfService extends StatelessWidget {
  const TermsOfService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms of Service',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildNumberedList([
                _buildSection(
                  'Acceptance of Terms',
                  'By accessing or using Horizon Wallet, a product of Unspendable Labs Inc., a Delaware Corporation ("we", "our", "us"), you agree to comply with and be bound by these Terms of Service. If you do not agree to these terms, please do not use Horizon Wallet.',
                ),
                _buildSection(
                  'Modification of Terms',
                  'We reserve the right to modify these terms at any time. Any changes will be effective immediately upon posting. Your continued use of Horizon Wallet after any such changes constitutes your acceptance of the new terms.',
                ),
                _buildSection(
                  'Use of the Service',
                  'You agree to use Horizon Wallet only for lawful purposes and in a manner that does not infringe the rights of, restrict, or inhibit anyone else\'s use and enjoyment of Horizon Wallet. You acknowledge that the data provided is sourced from public blockchain information and is subject to the accuracy and reliability of the underlying blockchain technology.',
                ),
                _buildSection(
                  'Privacy',
                  'Your use of Horizon Wallet is also governed by our ',
                  trailingWidget: GestureDetector(
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
                  'The data and information provided by Horizon Wallet are offered on an "as-is" and "as-available" basis. We make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability, or availability of Horizon Wallet or the information, products, services, or related graphics contained on Horizon Wallet for any purpose. Any reliance you place on such information is strictly at your own risk. We also make no warranties regarding the operation or availability of Horizon Wallet or the information, content, and materials included on Horizon Wallet.',
                ),
                _buildSection(
                  'Limitation of Liability',
                  'In no event will we be liable for any damages of any kind arising from the use of Horizon Wallet, including but not limited to direct, indirect, incidental, punitive, and consequential damages, or any loss or damage whatsoever arising from loss of funds or profits.',
                ),
                _buildSection(
                  'Content Disclaimer',
                  'We are not responsible for any content, including but not limited to data, text, graphics, links, or other items, that are presented on Horizon Wallet. All content is provided by third parties or is automatically generated by the blockchain and is not controlled or verified by us. Use of any content is at your own risk.',
                ),
                _buildSection(
                  'Governing Law',
                  'These terms and any disputes arising out of or related to them will be governed by and construed in accordance with the laws of the state of Delaware, without regard to its conflict of law rules.',
                ),
                _buildSection(
                  'Contact Information',
                  'If you have any questions about these Terms of Service, please contact us at ',
                  trailingWidget: InkWell(
                    onTap: () =>
                        _launchURL('mailto:contact@unspendablelabs.com'),
                    child: const Text(
                      'contact@unspendablelabs.com',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberedList(List<Widget> items) {
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
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Expanded(child: items[index]),
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, String content, {Widget? trailingWidget}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.white70),
            children: [
              TextSpan(text: content),
              if (trailingWidget != null) WidgetSpan(child: trailingWidget),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
