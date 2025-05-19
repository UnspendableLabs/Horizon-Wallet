import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';

class IconItemButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  const IconItemButton({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final customTheme = Theme.of(context).extension<CustomThemeExtension>();
    final bool isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: customTheme?.settingsItemBackground ?? transparentBlack66,
          border: Border.all(
            color:
                Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                    transparentBlack8,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            hoverColor: transparentPurple8,
            highlightColor: transparentPurple8,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
              child: Row(
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
