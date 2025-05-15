import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/screens/settings/import_address/import_address_flow.dart';
import 'package:horizon/presentation/screens/settings/reset_wallet/reset_wallet_flow.dart';
import 'package:horizon/presentation/screens/settings/security_view.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/seed_phrase_flow.dart';
import 'package:horizon/utils/app_icons.dart';

class SubSettingsView extends StatefulWidget {
  final String category;
  const SubSettingsView({super.key, required this.category});

  @override
  State<SubSettingsView> createState() => _SubSettingsViewState();
}

class _SubSettingsViewState extends State<SubSettingsView> {
  String _getPageTitle() {
    switch (widget.category) {
      case "seedPhrase":
        return "Seed Phrase";
      case "importAddress":
        return "Import Address";
      case "resetWallet":
        return "Reset Wallet";
      default:
        return "Security";
    }
  }

  Widget _buildAppBar() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          IconButton(
              onPressed: () {
                context.pop();
              },
              icon: AppIcons.backArrowIcon(
                  context: context, width: 24, height: 24)),
          const SizedBox(width: 10),
          Text(
            _getPageTitle(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ]));
  }

  Widget _buildBody() {
    switch (widget.category) {
      case "seedPhrase":
        return const SeedPhraseFlow();
      case "security":
        return const SecurityView();
      case "importAddress":
        return ImportAddressFlow(onNavigateBack: () {
          context.pop();
        });
      case "resetWallet":
        return const ResetWalletFlow();
      default:
        return const SecurityView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customTheme = theme.extension<CustomThemeExtension>();
    return Material(
      color: theme.dialogTheme.backgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: transparentWhite8),
                color: customTheme?.bgBlackOrWhite ?? black,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(child: _buildBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
