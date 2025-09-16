import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "./bloc/btc_activity_bloc.dart";
import "./_btc_view.dart";

class BtcActivityActions {
  final void Function() startPolling;
  final void Function() stopPolling;
  final void Function() load;
  final void Function() loadQuiet;
  final void Function() loadMore;

  const BtcActivityActions({
    required this.startPolling,
    required this.stopPolling,
    required this.load,
    required this.loadQuiet,
    required this.loadMore,
  });
}

class BTCActivityProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final AddressV2 address;
  final Widget Function(BtcActivityActions actions, BtcActivityState state)
      builder;

  const BTCActivityProvider(
      {super.key,
      required this.httpConfig,
      required this.address,
      required this.builder});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BtcActivityBloc(httpConfig: httpConfig, address: address.address)
            ..add(const Load()),
      child: BlocBuilder<BtcActivityBloc, BtcActivityState>(
          builder: (context, state) {
        return builder(
            BtcActivityActions(
              startPolling: () => context
                  .read<BtcActivityBloc>()
                  .add(const StartPolling(interval: Duration(seconds: 60))),
              stopPolling: () =>
                  context.read<BtcActivityBloc>().add(const StopPolling()),
              load: () => context.read<BtcActivityBloc>().add(const Load()),
              loadQuiet: () =>
                  context.read<BtcActivityBloc>().add(const LoadQuiet()),
              loadMore: () =>
                  context.read<BtcActivityBloc>().add(const LoadMore()),
            ),
            state);
      }),
    );
  }
}

class BTCActivityView extends StatelessWidget {
  final AddressV2 address;
  final BtcActivityActions actions;
  final BtcActivityState state;

  const BTCActivityView(
      {super.key,
      required this.address,
      required this.actions,
      required this.state});

  @override
  Widget build(BuildContext context) {
    return BTCActivityViewInternal(
        actions: actions, state: state, addresses: [address.address]);
  }
}
