import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class DialogHelper {
  static late GlobalKey<NavigatorState> navigatorKey;

  static void init(GlobalKey<NavigatorState> key) {
    navigatorKey = key;
  }

  static Future showAppDialog({
    required Widget child,
    bool barrierDismissible = true,
    bool gradBorder = true,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('No valid context found to show dialog.');
      return Future.value(null);
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.transparent,
        barrierLabel: 'Dismiss Dialog',
        transitionDuration: const Duration(milliseconds: 150),
        pageBuilder: (_, __, ___) {
          return const SizedBox.shrink();
        },
        transitionBuilder: (context, animation, _, __) {
          return FadeTransition(
              opacity: animation,
              child: GestureDetector(
                  onTap:
                      barrierDismissible ? () => Navigator.pop(context) : null,
                  child: Material(
                    child: Stack(
                      children: [
                        // blurred bg
                        BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              color: transparentBlack33,
                              child: Container(
                                color: transparentBlack33,
                              ),
                            )),
                        Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                                onTap: () {},
                                child: Container(
                                  margin: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: gradBorder
                                        ? GradientBoxBorder(
                                            context: context, width: 1)
                                        : Border.all(
                                            color: isDarkMode
                                                ? transparentWhite8
                                                : transparentBlack8,
                                            width: 1),
                                    color: isDarkMode
                                        ? transparentWhite8
                                        : transparentBlack8,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 250,
                                    ),
                                    child: IntrinsicHeight(
                                      child: child,
                                    ),
                                  ),
                                ))),
                      ],
                    ),
                  )));
        });
  }
}
