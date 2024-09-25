import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/shared/colors.dart';
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
                  'Last Updated: September 24, 2024',
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
                  '1. Information We Collect',
                  [
                    Text(
                      'We collect various types of information in connection with the services we provide, as detailed below:',
                      style: TextStyle(color: fontColor),
                    ),
                    const SizedBox(height: 16),
                    _buildSubsection(
                      'Personal Information',
                      [
                        _buildBulletPoint(
                          'We do not collect personally identifiable information (PII).',
                          fontColor,
                        ),
                      ],
                      fontColor,
                    ),
                    _buildSubsection(
                      'Automatically Collected Information',
                      [
                        _buildBulletPoint(
                          'Vercel Analytics: To better understand and enhance user experience, we collect analytics data, including:',
                          fontColor,
                          subPoints: [
                            'Referring websites',
                            'Visitor country of origin',
                            'Visitor operating system',
                            'Visitor browser',
                          ],
                        ),
                        _buildBulletPoint(
                          'Vercel Logs: To monitor and improve our service, we log certain request information, which includes:',
                          fontColor,
                          subPoints: [
                            'Request path',
                            'Request time',
                            'User agent (information also aggregated by our analytics platform)',
                            'Visitor location',
                            'Request execution time',
                            'Any server-side errors, which do not include any PII',
                          ],
                        ),
                        _buildBulletPoint(
                          'Sentry: For error tracking and performance monitoring, we collect data on client and server-side exceptions, including:',
                          fontColor,
                          subPoints: [
                            'Request path that generated the exception',
                            'Browser',
                            'Operating system',
                            'IP address',
                            'Backtrace',
                          ],
                        ),
                      ],
                      fontColor,
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '2. How We Use Your Information',
                  [
                    Text(
                      'We use the information we collect in the following ways:',
                      style: TextStyle(color: fontColor),
                    ),
                    const SizedBox(height: 8),
                    _buildBulletPoint(
                      'To Provide and Maintain Our Service: Ensuring the functionality and security of our service.',
                      fontColor,
                    ),
                    _buildBulletPoint(
                      'To Improve Our Service: Analyzing how users interact with our service to improve user experience and performance.',
                      fontColor,
                    ),
                    _buildBulletPoint(
                      'To Monitor and Fix Errors: Using Sentry to track and resolve client and server-side exceptions.',
                      fontColor,
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '3. Changes to This Privacy Policy',
                  [
                    Text(
                      'We may update this Privacy Policy from time to time. Any changes will be effective immediately upon posting of the revised policy on our website. We encourage you to review this Privacy Policy periodically for any updates. Your continued use of the service after any changes to the policy will constitute your acceptance of those changes.',
                      style: TextStyle(color: fontColor),
                    ),
                  ],
                  fontColor,
                ),
                _buildSection(
                  '4. Contact Us',
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

  Widget _buildSubsection(
      String title, List<Widget> children, Color fontColor) {
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
