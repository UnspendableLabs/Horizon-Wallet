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
                  'Last Updated: December 25, 2024',
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
                    const SizedBox(height: 16),
                    _buildSubsection(
                      'Analytics Data:',
                      [],
                      fontColor,
                    ),
                    _buildSubsection(
                      'Collected to monitor usage patterns and performance:',
                      [
                        _buildBulletPoint(
                          'Web Vitals',
                          fontColor,
                          subPoints: [
                            'Metrics such as page load time, input delay, and visual stability. A random UUID is assigned to sessions to group metrics, and it resets periodically.',
                          ],
                        ),
                        _buildBulletPoint(
                          'Broadcasted Transactions:',
                          fontColor,
                          subPoints: [
                            'Logs of transaction occurrences and their types (e.g., broadcast_tx_issue, broadcast_tx_send). Each event is assigned a unique, random UUID that is not linked to wallet UUIDs, session IDs, or other events.',
                          ],
                        ),
                        _buildBulletPoint(
                          'Wallet Sessions:',
                          fontColor,
                          subPoints: [
                            'Logs of wallet access events (e.g., opening, refreshing, or logging in). Each wallet is assigned a persistent, anonymous UUID tied to local storage. If a wallet is deleted locally and re-imported, a new UUID is generated.',
                          ],
                        ),
                      ],
                      fontColor,
                      16,
                      FontWeight.normal,
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      'Debugging Data:',
                      [],
                      fontColor,
                    ),
                    _buildSubsection(
                      'Collected to identify and resolve errors:',
                      [
                        _buildBulletPoint(
                          'Error Diagnostics:',
                          fontColor,
                          subPoints: [
                            'Context from the user session from the moment an application error occurs, including error messages, stack traces, application state, runtime settings, and system metadata (e.g., device type, browser configuration).',
                          ],
                        ),
                        _buildBulletPoint(
                          'API Request Breadcrumbs: ',
                          fontColor,
                          subPoints: [
                            'A list of API requests from the session that have led up to an error. This information helps identify which preceding calls (e.g., fetching balances, fee estimates, and other relevant data) may have contributed to the issue.',
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
                      'Track aggregated usage patterns, such as the total number of active wallets, and number and types of transactions made.',
                      fontColor,
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '3. Data Handling',
                  [
                    _buildBulletPoint(
                      'We do not sell, share, or rent the data we collect.',
                      fontColor,
                    ),
                    _buildBulletPoint(
                      'Data is processed by third-party service providers solely for analytics and debugging.',
                      fontColor,
                    ),
                    _buildBulletPoint(
                      'We retain data for as long as it is needed to fulfill the purposes described in this policy.',
                      fontColor,
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
