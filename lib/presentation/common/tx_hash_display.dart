import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  TxHashDisplayState createState() => TxHashDisplayState();
}

class TxHashDisplayState extends State<TxHashDisplay> {
  // ignore: unused_field
  bool _copied = false;

  String get shortenedHash {
    if (widget.hash.length <= widget.displayLength * 2) return widget.hash;
    return '${widget.hash.substring(0, widget.displayLength)}...${widget.hash.substring(widget.hash.length - widget.displayLength)}';
  }

  Future<void> _launchUrl(HttpConfig httpConfig) async {
    final uri = switch (widget.uriType) {
      URIType.btcexplorer =>
        Uri.parse("${httpConfig.btcExplorer}/tx/${widget.hash}"),
      URIType.hoex =>
        Uri.parse("${httpConfig.horizonExplorer}/tx/${widget.hash}")
    };

    // final uri =

    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
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
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return GestureDetector(
        onLongPress: _copyToClipboard,
        onTap: () => _launchUrl(session.httpConfig),
        child: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                mouseCursor: WidgetStateMouseCursor.clickable,
                text: shortenedHash,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ));
  }
}
