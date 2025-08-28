import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
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

class GradientLinkButton extends StatefulWidget {
  final String text;
  final String href;
  final Gradient? gradient;

  const GradientLinkButton({
    super.key,
    required this.text,
    required this.href,
    this.gradient,
  });

  @override
  State<GradientLinkButton> createState() => _GradientLinkButtonState();
}

class _GradientLinkButtonState extends State<GradientLinkButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gradient = widget.gradient ??
        LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isDark
              ? const [
                  goldenGradient1,
                  yellow1,
                  goldenGradient2,
                  goldenGradient3,
                ]
              : const [
                  duskGradient2,
                  duskGradient1,
                ],
          stops: isDark ? const [0.0, 0.325, 0.65, 1.0] : const [0.0, 1.0],
        );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: TextButton(
        onPressed: () async {
          final uri = Uri.parse(widget.href);
          if (!await launchUrl(uri)) {
            throw Exception('Could not launch $uri');
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            _isHovered
                ? (isDark ? const Color(0x22FFFFFF) : const Color(0x11000000))
                : Colors.transparent,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => gradient.createShader(bounds),
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.white, // color is masked by ShaderMask
            ),
          ),
        ),
      ),
    );
  }
}
