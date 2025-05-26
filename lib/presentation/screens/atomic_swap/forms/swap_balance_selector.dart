import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';


class SwapBalanceSelector extends StatefulWidget {
  const SwapBalanceSelector({super.key});

  @override
  State<SwapBalanceSelector> createState() => _SwapBalanceSelectorState();
}

class _SwapBalanceSelectorState extends State<SwapBalanceSelector> {
  final appIcons = AppIcons();
  _buildBalaceItem(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child:
                      Text("A22s6g...B1ss7", style: theme.textTheme.bodySmall)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("120.0", style: theme.textTheme.titleSmall),
                  Text("XCP", style: theme.textTheme.bodySmall),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildAssetListItem(BuildContext context, HttpConfig httpConfig) {
    final theme = Theme.of(context);
    final customTheme = Theme.of(context).extension<CustomThemeExtension>();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              appIcons.assetIcon(
                httpConfig: httpConfig,
                context: context,
                width: 34,
                height: 34,
                assetName: "XCP",
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("XCP",
                      style:
                          theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                  Text("A22s6g...B1ss7", style: theme.textTheme.titleSmall),
                ],
              )),
              commonHeightSizedBox,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("120.0",
                      textAlign: TextAlign.end,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      )),
                  Text("XCP",
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: customTheme!.mutedDescriptionTextColor,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: HorizonTextField(
            controller: TextEditingController(),
            hintText: "Search",
            suffixIcon:
                AppIcons.searchIcon(context: context, width: 20, height: 20),
          ),
        ),
        Expanded(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppIcons.attachIcon(
                            context: context, width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text("Attached and ready to swap",
                            style: theme.textTheme.titleSmall)
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildAssetListItem(context, session.httpConfig),
                    _buildAssetListItem(context, session.httpConfig),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppIcons.attachIcon(
                            context: context, width: 16, height: 16),
                        const SizedBox(width: 8),
                        Text("Balance to attach",
                            style: theme.textTheme.titleSmall)
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBalaceItem(context),
                    _buildBalaceItem(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
