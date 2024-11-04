import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/repositories/node_info_repository.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_bloc.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_event.dart';
import 'package:horizon/presentation/common/footer/bloc/footer_state.dart';
import 'package:url_launcher/url_launcher.dart';

const TAG = "v1.3.1";

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
    context.read<FooterBloc>().add(GetNodeInfo());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<FooterBloc, FooterState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkTheme ? darkNavyDarkTheme : greyLightTheme,
          ),
          child: SizedBox(
            height: 30,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go("/tos"),
                    child: Text(
                      'Terms of Service',
                      style: textStyle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () => context.go("/privacy-policy"),
                    child: Text(
                      'Privacy Policy',
                      style: textStyle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse(
                          "https://github.com/UnspendableLabs/Horizon-Wallet/releases/tag/$TAG"));
                    },
                    child: Text(
                      TAG,
                      style: textStyle,
                    ),
                  ),
                  const SizedBox(width: 20),
                  state.nodeInfoState.when(
                    initial: () => const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (error) => const SizedBox.shrink(),
                    success: (nodeInfo) => TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://github.com/CounterpartyXCP/counterparty-core/releases/tag/v${nodeInfo.version}"));
                      },
                      child: Text(
                        'Counterparty Core: ${nodeInfo.version}',
                        style: textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle get textStyle => const TextStyle(
        color: neonBlueDarkTheme,
        fontSize: 16,
      );
}
