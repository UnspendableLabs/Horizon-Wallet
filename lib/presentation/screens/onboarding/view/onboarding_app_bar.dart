import 'package:flutter/material.dart';

class OnboardingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isDarkMode;
  final bool isSmallScreenWidth;
  final bool isSmallScreenHeight;
  final Color scaffoldBackgroundColor;

  const OnboardingAppBar({
    required this.isDarkMode,
    required this.isSmallScreenWidth,
    required this.isSmallScreenHeight,
    required this.scaffoldBackgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: scaffoldBackgroundColor,
      title: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isDarkMode
                ? Image.asset(
                    'app-bar-H-dark-mode.png',
                    width: 48,
                    height: 48,
                  )
                : Image.asset(
                    'app-bar-H-light-mode.png',
                    width: 48,
                    height: 48,
                  ),
          ],
        ),
      ),
      toolbarHeight: kToolbarHeight + 24,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 24);
}
