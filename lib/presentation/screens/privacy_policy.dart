import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Last Updated: September 10, 2024',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'Horizon Wallet, a product of Unspendable Labs Inc., a Delaware Corporation ("we", "our", "us"), is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our service. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the service.',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              _buildSection(
                '1. Information We Collect',
                [
                  const Text(
                    'We collect various types of information in connection with the services we provide, as detailed below:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  _buildSubsection(
                    'Personal Information',
                    [
                      _buildBulletPoint(
                          'We do not collect personally identifiable information (PII).'),
                    ],
                  ),
                  _buildSubsection(
                    'Automatically Collected Information',
                    [
                      _buildBulletPoint(
                        'Vercel Analytics: To better understand and enhance user experience, we collect analytics data, including:',
                        subPoints: [
                          'Referring websites',
                          'Visitor country of origin',
                          'Visitor operating system',
                          'Visitor browser',
                        ],
                      ),
                      _buildBulletPoint(
                        'Vercel Logs: To monitor and improve our service, we log certain request information, which includes:',
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
                        subPoints: [
                          'Request path that generated the exception',
                          'Browser',
                          'Operating system',
                          'IP address',
                          'Backtrace',
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              _buildSection(
                '2. How We Use Your Information',
                [
                  const Text(
                    'We use the information we collect in the following ways:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                      'To Provide and Maintain Our Service: Ensuring the functionality and security of our service.'),
                  _buildBulletPoint(
                      'To Improve Our Service: Analyzing how users interact with our service to improve user experience and performance.'),
                  _buildBulletPoint(
                      'To Monitor and Fix Errors: Using Sentry to track and resolve client and server-side exceptions.'),
                ],
              ),
              // Add more sections here...
              _buildSection(
                '10. Contact Us',
                [
                  const Text(
                    'If you have any questions about this Privacy Policy, please contact us:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Email: ',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSubsection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBulletPoint(String text,
      {List<String>? subPoints, Widget? trailingWidget}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(text,
                          style: const TextStyle(color: Colors.white70)),
                    ),
                    if (trailingWidget != null) trailingWidget,
                  ],
                ),
                if (subPoints != null) ...[
                  const SizedBox(height: 8),
                  ...subPoints.map((subPoint) => Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('- ',
                                style: TextStyle(color: Colors.white70)),
                            Expanded(
                              child: Text(subPoint,
                                  style:
                                      const TextStyle(color: Colors.white70)),
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

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
