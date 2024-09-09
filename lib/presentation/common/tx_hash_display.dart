import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:get_it/get_it.dart';

enum URIType { btcexplorer, hoex }

class TxHashDisplay extends StatefulWidget {
  final String hash;
  final int displayLength;
  final Config config = GetIt.I<Config>();
  final URIType uriType;

  TxHashDisplay({
    super.key,
    required this.hash,
    required this.uriType,
    this.displayLength = 5,
  });

  @override
  _TxHashDisplayState createState() => _TxHashDisplayState();
}

class _TxHashDisplayState extends State<TxHashDisplay> {
  bool _copied = false;

  String get shortenedHash {
    if (widget.hash.length <= widget.displayLength * 2) return widget.hash;
    return '${widget.hash.substring(0, widget.displayLength)}...${widget.hash.substring(widget.hash.length - widget.displayLength)}';
  }

  Future<void> _launchUrl() async {
    final uri = switch (widget.uriType) {
      URIType.btcexplorer =>
        Uri.parse("${widget.config.btcExplorerBase}/tx/${widget.hash}"),
      URIType.hoex =>
        Uri.parse("${widget.config.horizonExplorerBase}/tx/${widget.hash}")
    };

    // final uri =

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  String _getUrl() {
    final uri = switch (widget.uriType) {
      URIType.btcexplorer =>
        Uri.parse("${widget.config.btcExplorerBase}/tx/${widget.hash}"),
      URIType.hoex =>
        Uri.parse("${widget.config.horizonExplorerBase}/tx/${widget.hash}")
    };
    return uri.toString();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.hash));
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: _copyToClipboard,
        onTap: _launchUrl,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: shortenedHash,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
