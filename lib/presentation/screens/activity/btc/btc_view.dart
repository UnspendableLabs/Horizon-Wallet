import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "./bloc/btc_activity_bloc.dart";
import "./_btc_view.dart";

class BtcActivityActions {
  final void Function() load;
  final void Function() loadMore;

  const BtcActivityActions({
    required this.load,
    required this.loadMore,
  });
}

class BTCActivityProvider extends StatelessWidget {
  final HttpConfig httpConfig;
  final AddressV2 address;
  final void Function(DateTime newDateTime) onLastUpdatedAtChange;
  final Widget Function(BtcActivityActions actions, BtcActivityState state)
      builder;

  const BTCActivityProvider(
      {super.key,
      required this.httpConfig,
      required this.address,
      required this.builder,
      required this.onLastUpdatedAtChange});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BtcActivityBloc(httpConfig: httpConfig, address: address.address)
            ..add(const Load()),
      child: BlocConsumer<BtcActivityBloc, BtcActivityState>(
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
            BtcActivityActions(
              load: () => context.read<BtcActivityBloc>().add(const Load()),
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
