import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

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
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: fontColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Updated: November 18, 2024',
                  style: TextStyle(
                      color: isDarkTheme ? Colors.grey : Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Horizon Wallet, a product of Unspendable Labs Inc., a Delaware Corporation ("we", "our", "us"), is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our service. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the service.',
                  style: TextStyle(color: fontColor),
                ),
                const SizedBox(height: 24),
                _buildSection(
                  '1. Data We Collect',
                  [
                    Text(
                      'We collect data solely for analytics and debugging purposes. No Personally Identifiable Information (PII) is collected.',
                      style: TextStyle(color: fontColor),
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      'Contextual Metadata:',
                      [],
                      fontColor,
                    ),
                    _buildSubsection(
                      'Each event includes metadata such as:',
                      [
                        _buildBulletPoint(
                          'User agent (browser and operating system details)',
                          fontColor,
                        ),
                        _buildBulletPoint(
                          'Timestamp',
                          fontColor,
                        ),
                        _buildBulletPoint(
                          'Timezone',
                          fontColor,
                        ),
                        _buildBulletPoint(
                          'URL',
                          fontColor,
                        ),
                      ],
                      fontColor,
                      16,
                      FontWeight.normal,
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      'Event Types:',
                      [],
                      fontColor,
                    ),
                    _buildSubsection(
                      'We log the following types of events:',
                      [
                        _buildBulletPoint(
                          'Web Vitals',
                          fontColor,
                          subPoints: [
                            'Data: Metrics such as page load time, input delay, and visual stability are collected throughout the session.',
                            'UUID: A random UUID is assigned to each session to group all Web Vitals. This UUID resets periodically.',
                          ],
                        ),
                        _buildBulletPoint(
                          'Broadcasted Transactions:',
                          fontColor,
                          subPoints: [
                            'Data: We log when a transaction occurs and its type (e.g., broadcast_tx_issue, broadcast_tx_send).',
                            'UUID: Each broadcast_tx_* event is assigned a random, unique UUID to ensure it is not linked to any wallet UUID, session ID, or other events.',
                          ],
                        ),
                        _buildBulletPoint(
                          'Wallet Sessions:',
                          fontColor,
                          subPoints: [
                            'Data: A wallet_opened event is logged whenever a wallet is accessed (opened, refreshed, or logged into).',
                            'UUID: Each wallet is assigned a persistent, anonymous UUID tied to local storage. If a wallet is deleted locally and re-imported, a new UUID is generated.',
                          ],
                        ),
                      ],
                      fontColor,
                      16,
                      FontWeight.normal,
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '2. How We Use the Data',
                  [
                    Text(
                      'We use the data collected to:',
                      style: TextStyle(color: fontColor),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Monitor performance and debug issues.',
                      fontColor,
                    ),
                    _buildBulletPoint(
                      'Track aggregated usage patterns, such as the total number of active wallets.',
                      fontColor,
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '3. Data Handling',
                  [
                    Text(
                      'We do not sell, share, or rent the data we collect. Data is processed by third-party service providers solely for analytics and debugging. We retain data for as long as it is needed to fulfill the purposes described in this policy.',
                      style: TextStyle(color: fontColor),
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '4. Updates to This Policy',
                  [
                    Text(
                      'We may update this Privacy Policy at any time. Updates will be posted on this page with the "Last Updated" date.',
                      style: TextStyle(color: fontColor),
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '5. Contact Us',
                  [
                    Text(
                      'If you have any questions about this Privacy Policy, please contact us:',
                      style: TextStyle(color: fontColor),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'Email: ',
                      fontColor,
                      trailingWidget: InkWell(
                        onTap: () =>
                            _launchURL('mailto:contact@unspendablelabs.com'),
                        child: const Text(
                          'contact@unspendablelabs.com',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                  fontColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, Color fontColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: fontColor,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubsection(String title, List<Widget> children, Color fontColor,
      [double? fontSize, FontWeight? fontWeight]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: fontSize ?? 20,
            fontWeight: fontWeight ?? FontWeight.bold,
            color: fontColor,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletPoint(String text, Color fontColor,
      {List<String>? subPoints, Widget? trailingWidget}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: fontColor)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(text, style: TextStyle(color: fontColor)),
                    if (trailingWidget != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: trailingWidget,
                      ),
                  ],
                ),
                if (subPoints != null) ...[
                  const SizedBox(height: 8),
                  ...subPoints.map((subPoint) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('- ', style: TextStyle(color: fontColor)),
                            Expanded(
                              child: Text(subPoint,
                                  style: TextStyle(color: fontColor)),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
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
