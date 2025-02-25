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
    final config = GetIt.I.get<Config>();

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: BlocBuilder<FooterBloc, FooterState>(
        builder: (context, state) {
          return SizedBox(
            width: double.infinity,
            height: 38,
            // padding: const EdgeInsets.symmetric(horizontal:  16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.go("/tos"),
                  child: const Text('Terms of Service'),
                ),
                // const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.go("/privacy-policy"),
                  child: const Text('Privacy Policy'),
                ),
                // const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://github.com/UnspendableLabs/Horizon-Wallet/releases/tag/v${config.version.toString()}"));
                  },
                  child: Text(config.version.toString()),
                ),
                // const SizedBox(width: 8),
                state.nodeInfoState.when(
                  initial: () => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (error) => const SizedBox.shrink(),
                  success: (nodeInfo) => TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://github.com/CounterpartyXCP/counterparty-core/releases/tag/v${nodeInfo.version}"));
                    },
                    child: Text('Counterparty Core v${nodeInfo.version}'),
                  ),
                ),
                if (config.isWebExtension) ...[
                  // const SizedBox(width: 8),
                  TextButton(
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
