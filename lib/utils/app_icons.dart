import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:horizon/data/sources/network/horizon_explorer_client.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class AppIcons {
  static final AppIcons _instance = AppIcons._internal();
  factory AppIcons() => _instance;
  AppIcons._internal();

  final HorizonExplorerApi _horizonExplorerApi = GetIt.I<HorizonExplorerApi>();

  static const String _iconPath = kDebugMode ? '/icons' : 'assets/icons';
  static const String receive = '$_iconPath/receive.svg';
  static const String send = '$_iconPath/send.svg';
  static const String swap = '$_iconPath/swap.svg';
  static const String mint = '$_iconPath/mint.svg';
  static const String search = '$_iconPath/search.svg';
  static const String close = '$_iconPath/close.svg';
  static const String pieChart = '$_iconPath/pie_chart.svg';
  static const String settings = '$_iconPath/settings.svg';
  static const String attach = '$_iconPath/attach.svg';
  static const String order = '$_iconPath/order.svg';
  static const String destroy = '$_iconPath/destroy.svg';
  static const String dispenser = '$_iconPath/dispenser.svg';
  static const String detach = '$_iconPath/detach.svg';
  static const String dividend = '$_iconPath/dividend.svg';
  static const String reset = '$_iconPath/reset.svg';
  static const String edit = '$_iconPath/edit.svg';
  static const String lock = '$_iconPath/lock.svg';
  static const String unlock = '$_iconPath/unlock.svg';
  static const String transfer = '$_iconPath/transfer.svg';
  static const String plus = '$_iconPath/plus.svg';
  static const String warning = '$_iconPath/warning.svg';
  static const String warningHex = '$_iconPath/warning_hex.svg';
  static const String backArrow = '$_iconPath/back_arrow.svg';
  static const String rocket = '$_iconPath/rocket.svg';
  static const String starOutlined = '$_iconPath/star_outlined.svg';
  static const String starFilled = '$_iconPath/star_filled.svg';
  static const String caretUp = '$_iconPath/caret_up.svg';
  static const String caretDown = '$_iconPath/caret_down.svg';
  static const String check = '$_iconPath/check.svg';
  static const String eyeOpen = '$_iconPath/eye_open.svg';
  static const String eyeClosed = '$_iconPath/eye_closed.svg';
  static const String moon = '$_iconPath/moon.svg';
  static const String sun = '$_iconPath/sun.svg';
  static const String shield = '$_iconPath/shield.svg';
  static const String copy = '$_iconPath/copy.svg';
  static const String refresh = '$_iconPath/refresh.svg';
  static const String spectacles = '$_iconPath/spectacles.svg';
  static const String chevronRight = '$_iconPath/chevron_right.svg';
  static const String key = '$_iconPath/key.svg';
  static const String xcp = '$_iconPath/xcp.svg';
  static const String btc = '$_iconPath/btc.svg';
  static const String paste = '$_iconPath/paste_squares.svg';

  static Widget getIcon(
    String iconPath, {
    required BuildContext? context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
    Key? key,
  }) {
    if (context == null) {
      return SvgPicture.asset(
        iconPath,
        width: width,
        height: height,
        color: color,
        fit: fit,
        key: key,
      );
    }

    final iconColor = color ?? Theme.of(context).iconTheme.color;

    return SvgPicture.asset(
      iconPath,
      width: width ?? Theme.of(context).iconTheme.size,
      height: height ?? Theme.of(context).iconTheme.size,
      color: iconColor,
      fit: fit,
      key: key,
    );
  }
  
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

  static Widget searchIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      search,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget closeIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      close,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget pieChartIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      pieChart,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget settingsIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      settings,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
      key: const Key('settings_icon'),
    );
  }

  static Widget attachIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      attach,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget pasteIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      paste,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget orderIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      order,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget destroyIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      destroy,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget dispenserIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      dispenser,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget detachIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      detach,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget dividendIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      dividend,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget resetIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      reset,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget editIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      edit,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget unlockIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      unlock,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget lockIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      unlock,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget transferIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      transfer,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget plusIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      plus,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget warningIcon({
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      warning,
      context: null,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget warningHexIcon({
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      warningHex,
      context: null,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget backArrowIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      backArrow,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget rocketLaunchIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      rocket,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget starOutlinedIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      starOutlined,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget starFilledIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      starFilled,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget caretUpIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      caretUp,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget caretDownIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      caretDown,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget checkIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      check,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget eyeOpenIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      eyeOpen,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget eyeClosedIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      eyeClosed,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget moonIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      moon,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget sunIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      sun,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget shieldIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      shield,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget copyIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      copy,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget refreshIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      refresh,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget spectaclesIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      spectacles,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget keyIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      key,
      context: context,
      width: width,
      height: height,
    );
  }

  static Widget chevronRightIcon({
    required BuildContext context,
    double? width,
    double? height,
    Color? color,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      chevronRight,
      context: context,
      width: width,
      height: height,
      color: color,
      fit: fit,
    );
  }

  static Widget xcpIcon({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      xcp,
      context: null,
      width: width,
      height: height,
      color: null,
      fit: fit,
    );
  }

  static Widget btcIcon({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
  }) {
    return getIcon(
      btc,
      context: null,
      width: width,
      height: height,
      color: null,
    );
  }
  static Widget iconButton({
    required BuildContext context,
    required Widget icon,
    required VoidCallback onPressed,
    double? width,
    double? height,
    Color? color,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    BoxFit fit = BoxFit.contain,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: EdgeInsets.zero,
            child: icon,
          ),
        ),
      ),
    );
  }

  Widget assetIcon({
    required BuildContext context,
    required String assetName,
    String? description,
    bool showLarge = false,
    double? width = 40,
    double? height = 40,
    BoxFit fit = BoxFit.cover,
  }) {

    if (assetName == 'XCP') {
      return xcpIcon(
        width: width,
        height: height,
        fit: fit,
      );
    }

    if (assetName == 'BTC') {
      return btcIcon(
        width: width,
        height: height,
        fit: fit,
      );
    }

    return FutureBuilder(
      future:
          _horizonExplorerApi.getAssetSrc(assetName, description, showLarge),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                      transparentBlack8,
              shape: BoxShape.circle,
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data?.src != null) {
          return ClipOval(
            child: CachedNetworkImage(
              imageUrl: snapshot.data!.src!,
              width: width,
              height: height,
              fit: fit,
              alignment: Alignment.center,
              placeholder: (context, url) => Container( 
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.outlineBorder?.color ??
                      transparentBlack8,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
