import 'package:flutter/material.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/link.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Tool extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Widget? trailing;
  final String name;
  final String description;
  final String? _href;

  const Tool({
    super.key,
    required this.title,
    required this.name,
    required this.description,
    this.icon,
    this.trailing,
    String? href,
  }) : _href = href;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();

    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    final href = _href ?? "${session.httpConfig.horizonMarket}/tools/$name";

    return Link(
      href: href,
      display: Container(
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
            child: Row(
              children: [
                icon ?? const SizedBox.shrink(),
                icon != null
                    ? const SizedBox(width: 12)
                    : const SizedBox.shrink(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                        child: Text(
                          description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                trailing ??
                    AppIcons.chevronRightIcon(
                      context: context,
                      color: Theme.of(context).iconTheme.color,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ToolsView extends StatefulWidget {
  const ToolsView({
    super.key,
  });

  @override
  State<ToolsView> createState() => _ToolsViewState();
}

class _ToolsViewState extends State<ToolsView> {
  Widget _buildTools() {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return ListView(
      children: [
        Tool(
          name: "manage swaps",
          title: 'Atomic Swaps',
          href: "${session.httpConfig.horizonMarket}/listing",
          description: "Manage your atomic swap listings",
          icon: AppIcons.swapIcon(context: context, width: 24, height: 24),
        ),
        Tool(
          name: "orders",
          title: "DEX Orders",
          href:
              "${session.httpConfig.horizonMarket}/listing?order_type=counterparty",
          description: "Manage your Counterparty DEX orders",
          icon: AppIcons.orderIcon(context: context, width: 24, height: 24),
        ),
        Tool(
          name: "Dispensers",
          title: "Dispensers",
          href:
              "${session.httpConfig.horizonMarket}/listing?order_type=dispenser",
          description: "Manage your Counterparty Dispensers",
          icon: AppIcons.dispenserIcon(context: context, width: 24, height: 24),
        ),
        const Tool(
            name: "mpma",
            title: 'Multiple Send',
            description:
                "Send multiple assets to multiple destinations at once.",
            icon: Icon(LucideIcons.arrowsUpFromLine, size: 24)),
        Tool(
          name: "sweep",
          title: "Sweep",
          description: "Sweep all assets to a single address",
          icon: AppIcons.cleaningBrushIcon(
              context: context, width: 24, height: 24),
        ),

        Tool(
          title: "Detach Asset",
          name: "detach",
          description: "Detach all assets from a UTXO",
          icon: AppIcons.detachIcon(context: context, width: 24, height: 24),
        ),
        const Tool(
          title: "Move Asset",
          name: "move",
          description: "Move all attached assets to a different utxo",
          icon: Icon(LucideIcons.arrowRightFromLine, size: 24),
        ),
        Tool(
          title: "Dividend",
          name: "dividend",
          description: "Distribute assets to all holders of an asset",
          icon: AppIcons.handCoinsIcon(context: context, width: 24, height: 24),
        ),
        const Tool(
          title: "Destroy",
          name: "destroy",
          description: "Destroy an asset",
          icon: Icon(LucideIcons.trash2, size: 24),
        ),
        const Tool(
          name: "lock-quantity",
          title: "Lock Asset Quantity",
          description: "Lock an asset quantity",
          icon: Icon(LucideIcons.lock, size: 24),
        ),
        const Tool(
          name: "lock-description",
          title: "Lock Asset Description",
          description: "Lock an asset description",
          icon: Icon(LucideIcons.fileLock, size: 24),
        ),
        Tool(
          name: "change-description",
          title: "Change Asset Description",
          description: "Change an asset description",
          icon: AppIcons.filePenIcon(context: context, width: 24, height: 24),
        ),
        const Tool(
          name: "change-ownership",
          title: "Change Asset Ownership",
          description: "Change the ownership of an asset",
          icon: Icon(LucideIcons.keyRound, size: 24),
        ),
        const Tool(
          name: "reset",
          title: "Reset Asset",
          description: "Reset an asset",
          icon: Icon(LucideIcons.rotateCcw, size: 24),
        ),
        const Tool(
          name: "issue-more",
          title: "Issue More",
          description: "Issue more of an asset",
          icon: Icon(LucideIcons.copyPlus, size: 24),
        ),
        // ToolsItem(
        //   toolName: "sweep",
        //   title: 'Sweep',
        //   icon: AppIcons.sweepIcon(context: context, width: 24, height: 24),
        // ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SizedBox(
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Tools",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return context.watch<SessionStateCubit>().state.maybeWhen(
        orElse: () => const CircularProgressIndicator(),
        success: (session) => Material(
              color: Theme.of(context).dialogTheme.backgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Scaffold(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(72),
                      child: _buildAppBar(),
                    ),
                    body: Container(
                      padding: const EdgeInsets.only(top: 14),
                      child: _buildTools(),
                    ),
                  ),
                ),
              ),
            ));
  }
}
