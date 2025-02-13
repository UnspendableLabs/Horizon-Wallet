import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_bloc.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/domain/services/platform_service.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          FooterBloc(nodeInfoRepository: GetIt.I.get<NodeInfoRepository>()),
      child: const _Footer(),
    );
  }
}

class _Footer extends StatefulWidget {
  const _Footer();

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  @override
  void initState() {
    super.initState();
    context.read<FooterBloc>().add(NodeInfoRequested());
  }

  void _openInNewTab() {
    if (GetIt.I.get<Config>().isWebExtension) {
      GetIt.I.get<PlatformService>().openInNewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    TextStyle textStyle() => TextStyle(
          color: isDarkTheme ? Colors.white : Colors.black,
          fontSize: screenWidth < 600 ? 10 : 16,
          fontWeight: FontWeight.w300,
        );

    final config = GetIt.I.get<Config>();

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: BlocBuilder<FooterBloc, FooterState>(
        builder: (context, state) {
          return Container(
            width: double.infinity,
            height: 30,
            decoration: BoxDecoration(
              color: isDarkTheme
                  ? darkThemeBackgroundColor
                  : lightThemeBackgroundColorTopGradiant,
            ),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: screenWidth < 600 ? 4 : 20,
                runSpacing: 4,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? 4 : 16,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => context.go("/tos"),
                    child: Text(
                      'Terms of Service',
                      style: textStyle(),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? 4 : 16,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => context.go("/privacy-policy"),
                    child: Text(
                      'Privacy Policy',
                      style: textStyle(),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth < 600 ? 4 : 16,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://github.com/UnspendableLabs/Horizon-Wallet/releases/tag/v${config.version.toString()}"));
                    },
                    child: Text(
                      config.version.toString(),
                      style: textStyle(),
                    ),
                  ),
                  state.nodeInfoState.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (error) => const SizedBox.shrink(),
                    success: (nodeInfo) => TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 4 : 16,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://github.com/CounterpartyXCP/counterparty-core/releases/tag/v${nodeInfo.version}"));
                      },
                      child: Text(
                        'Counterparty Core v${nodeInfo.version}',
                        style: textStyle(),
                      ),
                    ),
                  ),
                  if (config.isWebExtension)
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth < 600 ? 4 : 16,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _openInNewTab,
                      child: Text(
                        'Open in Tab',
                        style: textStyle(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
