import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A utility class for managing SVG icons across the app.
class AppIcons {
  /// Folder path for icon assets
  static const String _iconPath = '/icons';

  /// Available icons
  static const String receive = '$_iconPath/receive.svg';
  static const String send = '$_iconPath/send.svg';
  static const String swap = '$_iconPath/swap.svg';
  static const String mint = '$_iconPath/mint.svg';

  /// Get an SVG icon as a widget with customizable parameters
  /// Uses the current theme's icon style if no color is specified
  static Widget getIcon(
    String iconPath, {
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    // Use the theme's icon color if no color is specified
    final iconColor = color ?? Theme.of(context).iconTheme.color;

    return SvgPicture.asset(
      iconPath,
      width: width ?? Theme.of(context).iconTheme.size,
      height: height ?? Theme.of(context).iconTheme.size,
      color: iconColor,
      fit: fit,
    );
  }

  /// Receive icon with theme-aware styling
  static Widget receiveIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      receive,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  /// Send icon with theme-aware styling
  static Widget sendIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      send,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  /// Swap icon with theme-aware styling
  static Widget swapIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      swap,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  /// Mint icon with theme-aware styling
  static Widget mintIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      mint,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  /// Helper method to create a clickable icon button with theme-aware styling
  static Widget iconButton({
    required BuildContext context,
    required String iconPath,
    required VoidCallback onPressed,
    double? width,
    double? height,
    Color? color,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    BoxFit fit = BoxFit.contain,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: padding,
        child: getIcon(
          iconPath,
          context: context,
          width: width,
          height: height,
          color: color,
          fit: fit,
        ),
      ),
    );
  }
}
