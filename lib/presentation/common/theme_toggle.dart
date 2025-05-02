import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_bloc.dart';
import 'package:horizon/presentation/session/theme/bloc/theme_event.dart';
import 'package:horizon/utils/app_icons.dart';

class HorizonThemeToggle extends StatefulWidget {

  const HorizonThemeToggle({
    super.key,
  });

  @override
  State<HorizonThemeToggle> createState() => _HorizonThemeToggleState();
}

class _HorizonThemeToggleState extends State<HorizonThemeToggle> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isDarkMode ? transparentWhite8 : transparentBlack8, width: 1),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.read<ThemeBloc>().add(ThemeToggled()),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isDarkMode ? transparentPurple16 : transparentPurple4,
              ),
              iconSize: 24,
              icon: AppIcons.moonIcon(context: context, height: 24, width: 24),
            ),
            const SizedBox(width: 6),
            IconButton(
              onPressed: () => context.read<ThemeBloc>().add(ThemeToggled()),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isDarkMode
                    ? transparentPurple4
                    : transparentPurple16,
              ),
              iconSize: 24,
              icon: AppIcons.sunIcon(context: context, height: 24, width: 24),
            ),
          ],
        ),
      ),
    );
  }
}
