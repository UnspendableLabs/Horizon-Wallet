import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/domain/services/platform_service.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_bloc.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return context.read<SessionStateCubit>().state.maybeWhen(
          success: (session) => BlocProvider(
            create: (context) => FooterBloc(
                httpConfig: session.httpConfig,
                nodeInfoRepository: GetIt.I.get<NodeInfoRepository>()),
            child: const _Footer(),
          ),
          orElse: () => const SizedBox
              .shrink(), // Return an empty widget if the state is not success
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
    final config = GetIt.I.get<Config>();
    final widthSpacing = MediaQuery.of(context).size.width * 0.02;
    final textButtonStyle = TextButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: BlocBuilder<FooterBloc, FooterState>(
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: textButtonStyle,
                  onPressed: () => context.go("/tos"),
                  child: const Text('Terms of Service'),
                ),
                SizedBox(width: widthSpacing),
                TextButton(
                  style: textButtonStyle,
                  onPressed: () => context.go("/privacy-policy"),
                  child: const Text('Privacy Policy'),
                ),
                SizedBox(width: widthSpacing),
                TextButton(
                  style: textButtonStyle,
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://github.com/UnspendableLabs/Horizon-Wallet/releases/tag/v${config.version.toString()}"));
                  },
                  child: Text(config.version.toString()),
                ),
                SizedBox(width: widthSpacing),
                state.nodeInfoState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (error) => const SizedBox.shrink(),
                  success: (nodeInfo) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        style: textButtonStyle,
                        onPressed: () {
                          launchUrl(Uri.parse(
                              "https://github.com/CounterpartyXCP/counterparty-core/releases/tag/v${nodeInfo.version}"));
                        },
                        child: Text('Counterparty Core v${nodeInfo.version}'),
                      ),
                      if (config.isWebExtension) SizedBox(width: widthSpacing),
                    ],
                  ),
                ),
                if (config.isWebExtension) ...[
                  SizedBox(width: widthSpacing),
                  TextButton(
                    style: textButtonStyle,
                    onPressed: _openInNewTab,
                    child: const Text('Open in Tab'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
