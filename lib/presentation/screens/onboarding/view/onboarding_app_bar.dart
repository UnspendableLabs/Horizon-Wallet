import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horizon/presentation/common/colors.dart';

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
                ? SvgPicture.asset(
                    'assets/logo-white.svg',
                    width: 48,
                    height: 48,
                  )
                : SvgPicture.asset(
                    'assets/logo-black.svg',
                    width: 48,
                    height: 48,
                  ),
            const SizedBox(width: 8),
            Text(
              'Horizon',
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? mainTextWhite : mainTextBlack),
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
