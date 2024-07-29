import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';

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

  const ActivityFeedListItem({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.hash),
      subtitle: _buildSubtitle(),
      trailing: _buildTrailingIcon(),
      onTap: () {
        // Handle item tap
        // You might want to navigate to a detail page here
      },
    );
  }

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
    // Customize this based on your Event structure
    return Text('Event: ${event.event} - State: ${event.state}');
  }

  Widget _buildTransactionInfoSubtitle(TransactionInfo info) {
    // Customize this based on your TransactionInfo structure
    return Text('Amount: ${info.btcAmount}, Fee: ${info.fee}');
  }

  Widget _buildTrailingIcon() {
    if (item.event != null) {
      return _getEventStateIcon(item.event!.state);
    } else if (item.info != null) {
      return _getTransactionStateIcon(item.info!.domain);
    } else {
      return const Icon(Icons.error);
    }
  }

  Icon _getEventStateIcon(EventState state) => switch (state) {
        EventStateLocal() => const Icon(Icons.schedule, color: Colors.orange),
        EventStateMempool() => const Icon(Icons.pending, color: Colors.blue),
        EventStateConfirmed() =>
          const Icon(Icons.check_circle, color: Colors.green),
      };

  Icon _getTransactionStateIcon(TransactionInfoDomain domain) {
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
  const DashboardActivityFeedScreen({super.key});
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
    return BlocBuilder<DashboardActivityFeedBloc, DashboardActivityFeedState>(
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
                    return ActivityFeedListItem(item: transactions[index]);
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