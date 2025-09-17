import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "./bloc/xcp_activity_bloc.dart";
import "./_xcp_view.dart";
import 'package:horizon/domain/entities/remote_data.dart';

class XcpActivityActions {
  final void Function() load;
  final void Function() loadMore;

  const XcpActivityActions({
    required this.load,
    required this.loadMore,
  });
}

class XCPActivityProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final AddressV2 address;
  final void Function(DateTime newDateTime) onLastUpdatedAtChange;
  final Widget Function(XcpActivityActions actions, XcpActivityState state)
      builder;

  const XCPActivityProvider(
      {super.key,
      required this.httpConfig,
      required this.address,
      required this.builder,
      required this.onLastUpdatedAtChange});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          XcpActivityBloc(httpConfig: httpConfig, address: address.address)
            ..add(const Load()),
      child: BlocConsumer<XcpActivityBloc, XcpActivityState>(
          listenWhen: (previous, current) {
        final prevousReplete = previous.remoteState.getOrNull();
        final currentReplete = current.remoteState.getOrNull();

        return prevousReplete?.lastUpdatedAt != currentReplete?.lastUpdatedAt;
      }, listener: (context, state) {
        // if _lastdUpdatedAt is differnet
        final newDateTime = state.remoteState.getOrNull()?.lastUpdatedAt;

        if (newDateTime != null) {
          onLastUpdatedAtChange(newDateTime);
        }
      }, builder: (context, state) {
        return builder(
            XcpActivityActions(
              load: () => context.read<XcpActivityBloc>().add(const Load()),
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
