import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Link extends StatefulWidget {
  final Widget display;
  final String href;

  const Link({
    super.key,
    required this.display,
    required this.href,
  });

  @override
  LinkState createState() => LinkState();
}

class LinkState extends State<Link> {
  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.href);

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _launchUrl,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: widget.display,
      ),
    );
  }
}
