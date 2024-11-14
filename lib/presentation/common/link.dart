import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:get_it/get_it.dart';

class Link extends StatefulWidget {
  final String display;
  final String href;
  final Config config = GetIt.I<Config>();

  Link({
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
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                mouseCursor: WidgetStateMouseCursor.clickable,
                text: widget.display,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ));
  }
}

