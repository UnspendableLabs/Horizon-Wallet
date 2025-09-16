import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "./bloc/xcp_activity_bloc.dart";
import "./_xcp_view.dart";

class XcpActivityActions {
  final void Function() startPolling;
  final void Function() stopPolling;
  final void Function() load;
  final void Function() loadQuiet;
  final void Function() loadMore;

  const XcpActivityActions({
    required this.startPolling,
    required this.stopPolling,
    required this.load,
    required this.loadQuiet,
    required this.loadMore,
  });
}

class XCPActivityProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final AddressV2 address;
  final Widget Function(XcpActivityActions actions, XcpActivityState state)
      builder;

  const XCPActivityProvider(
      {super.key,
      required this.httpConfig,
      required this.address,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          XcpActivityBloc(httpConfig: httpConfig, address: address.address)
            ..add(const Load()),
      child: BlocBuilder<XcpActivityBloc, XcpActivityState>(
          builder: (context, state) {
        return builder(
            XcpActivityActions(
              startPolling: () => context
                  .read<XcpActivityBloc>()
                  .add(const StartPolling(interval: Duration(seconds: 15))),
              stopPolling: () =>
                  context.read<XcpActivityBloc>().add(const StopPolling()),
              load: () => context.read<XcpActivityBloc>().add(const Load()),
              loadQuiet: () =>
                  context.read<XcpActivityBloc>().add(const LoadQuiet()),
              loadMore: () =>
                  context.read<XcpActivityBloc>().add(const LoadMore()),
            ),
            state);
      }),
    );
  }
}

class XCPActivityView extends StatelessWidget {
  final AddressV2 address;
  final XcpActivityActions actions;
  final XcpActivityState state;

  const XCPActivityView(
      {super.key,
      required this.actions,
      required this.state,
      required this.address});

  @override
  Widget build(BuildContext context) {
    return XCPActivityViewInternal(
        state: state, actions: actions, addresses: [address.address]);
  }
}
