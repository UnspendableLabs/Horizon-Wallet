import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TxHashDisplay extends StatefulWidget {
  final String hash;
  final int displayLength;

  const TxHashDisplay({
    super.key,
    required this.hash,
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
      onTap: _copyToClipboard,
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: shortenedHash,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
