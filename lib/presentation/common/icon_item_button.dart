import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class IconItemButton extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onTap;
  final bool isDarkTheme;
  final Widget? trailing;

  const IconItemButton({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    required this.isDarkTheme,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkTheme ? transparentWhite8 : transparentBlack8,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
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
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
