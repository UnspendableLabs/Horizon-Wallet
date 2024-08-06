import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/address.dart';

enum SendSide { source, destination }

class NewTransactionsBanner extends StatelessWidget {
  final int count;
  const NewTransactionsBanner({super.key, required this.count});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DashboardActivityFeedBloc>().add(const Load());
      },
      child: Container(
        color: Colors.blue,
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            '$count new transaction${count > 1 ? 's' : ''}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ActivityFeedListItem extends StatelessWidget {
  final ActivityFeedItem item;
  final List<Address> addresses;

  const ActivityFeedListItem(
      {super.key, required this.item, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      leading: _buildLeadingIcon(),
      trailing: _buildTrailing(),
      onTap: () {
        // Handle item tap
        // You might want to navigate to a detail page here
      },
    );
  }

  Widget _buildTitle() {
    if (item.event != null) {
      return _buildEventTitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoTitle(item.info!);
    } else {
      print("this case");
      return const Text('No details available');
    }
  }

  SendSide _getSendSide(String address) {
    if (addresses.any((a) => a.address == address)) {
      return SendSide.source;
    } else {
      return SendSide.destination;
    }
  }

  Widget _buildEventTitle(Event event) {
    return switch (event) {
      VerboseDebitEvent(params: var params) =>
        Text("Send ${params.quantityNormalized} ${params.asset}"),
      VerboseCreditEvent(params: var params) =>
        Text("Receive ${params.quantityNormalized} ${params.asset}"),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        Text(
            "Sent ${params.quantityNormalized} ${params.asset} to ${params.destination}"),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        Text(
            "Received ${params.quantityNormalized} ${params.asset} from ${params.source}"),
      VerboseAssetIssuanceEvent(params: var params) =>
        Text("Issued ${params.quantityNormalized} ${params.asset}"),
      _ =>
        Text('Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildTransactionInfoTitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoEnhancedSendVerbose(
        unpackedData: var unpackedData,
        // asset: var asset,
        // address: var address,
        // quantityNormalized: var quantityNormalized,
      ) =>
        Text(
            "Send ${unpackedData.quantityNormalized} ${unpackedData.asset} to ${unpackedData.address}"),
      TransactionInfoIssuanceVerbose(
        unpackedData: var unpackedData,
      ) =>
        Text("Issued ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      _ => Text(
          'Invariant: title unsupported TransactionInfo type: ${info.runtimeType}'),
    };
  }

  // return Text(info.hash);
  // return Text('Amount: ${info.btcAmount}, Fee: ${info.fee}');

  Widget _buildSubtitle() {
    if (item.event != null) {
      return _buildEventSubtitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoSubtitle(item.info!);
    } else {
      return const Text('No details available');
    }
  }

  Widget _buildEventSubtitle(Event event) {
    return switch (event) {
      VerboseDebitEvent(txHash: var hash) => Text(hash),
      VerboseCreditEvent(txHash: var hash) => Text(hash),
      VerboseAssetIssuanceEvent(txHash: var hash) => Text(hash),
      _ => Text(
          'Invariant: subtitle unsupported event type: ${event.runtimeType}'),
    };

    // // Customize this based on your Event structure
    // return Text("${event.event} ${event.txHash}");
    // // return Text('Event: ${event.event} - State: ${event.state}');
  }

  Widget _buildTransactionInfoSubtitle(TransactionInfo info) {
    // Customize this based on your TransactionInfo structure
    return Text(info.hash);
    // return Text('Amount: ${info.btcAmount}, Fee: ${info.fee}');
  }

  Widget _buildTrailing() {
    if (item.event != null) {
      return _getEventTrailing(item.event!.state);
    } else if (item.info != null) {
      return _getTransactionTrailing(item.info!.domain);
    } else {
      return const Icon(Icons.error);
    }
  }

  Widget _buildLeadingIcon() {
    if (item.event != null) {
      return _getEventLeadingIcon(item.event!);
    } else if (item.info != null) {
      return const Icon(Icons.info);
    } else {
      throw Exception('Invariant: Item must have either event or info');
    }
  }

  Icon _getEventLeadingIcon(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        const Icon(Icons.arrow_back, color: Colors.red),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      VerboseAssetIssuanceEvent(params: var params) =>
        const Icon(Icons.toll, color: Colors.grey),
      _ => const Icon(Icons.error),
    };

    // return switch (event.event) {
    //   "CREDIT" => const Icon(Icons.arrow_forward, color: Colors.green),
    //   "DEBIT" => const Icon(Icons.arrow_back, color: Colors.red),
    //   "ASSET_ISSUANCE" => const Icon(Icons.toll, color: Colors.grey),
    //   "ENHANCED_SEND" when event is  => const Icon(Icons.toll, color: Colors.grey),
    //
    //   _ => const Icon(Icons.error),
    // };
  }

  Icon _getEventTrailing(EventState state) => switch (state) {
        EventStateLocal() => const Icon(Icons.schedule, color: Colors.orange),
        EventStateMempool() => const Icon(Icons.pending, color: Colors.blue),
        EventStateConfirmed() =>
          const Icon(Icons.check_circle, color: Colors.green),
      };

  Icon _getTransactionTrailing(TransactionInfoDomain domain) {
    return switch (domain) {
      TransactionInfoDomainLocal() =>
        const Icon(Icons.schedule, color: Colors.orange),
      TransactionInfoDomainMempool() =>
        const Icon(Icons.pending, color: Colors.blue),
      TransactionInfoDomainConfirmed() =>
        const Icon(Icons.check_circle, color: Colors.green),
    };
  }
}

class DashboardActivityFeedScreen extends StatefulWidget {
  final List<Address> addresses;

  const DashboardActivityFeedScreen({super.key, required this.addresses});

  @override
  _DashboardActivityFeedScreenState createState() =>
      _DashboardActivityFeedScreenState();
}

class _DashboardActivityFeedScreenState
    extends State<DashboardActivityFeedScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DashboardActivityFeedBloc>()
        .add(const StartPolling(interval: Duration(seconds: 30)));
  }

  @override
  void dispose() {
    context.read<DashboardActivityFeedBloc>().add(const StopPolling());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      listener: (context, state) {
        // print('DashboardActivityFeedBloc state changed: $state');
      },
      builder: (context, state) {
        if (state is DashboardActivityFeedStateInitial ||
            state is DashboardActivityFeedStateLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DashboardActivityFeedStateCompleteError) {
          return Center(child: Text('Error: ${state.error}'));
        } else if (state is DashboardActivityFeedStateCompleteOk ||
            state is DashboardActivityFeedStateReloadingOk) {
          final transactions =
              (state as dynamic).transactions as List<ActivityFeedItem>;
          final newTransactionCount =
              (state as dynamic).newTransactionCount as int;
          return Column(
            children: [
              if (newTransactionCount > 0)
                NewTransactionsBanner(count: newTransactionCount),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length + 1,
                itemBuilder: (context, index) {
                  if (index < transactions.length) {
                    return ActivityFeedListItem(
                      item: transactions[index],
                      addresses: widget.addresses,
                    );
                  } else if (index == transactions.length) {
                    return state is DashboardActivityFeedStateReloadingOk
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<DashboardActivityFeedBloc>()
                      .add(const LoadMore());
                },
                child: const Text("Load More"),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
