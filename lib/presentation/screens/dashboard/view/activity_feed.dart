import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';

class NewTransactionsBanner extends StatelessWidget {
  final int count;
  const NewTransactionsBanner({Key? key, required this.count})
      : super(key: key);
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

class TransactionListItem extends StatelessWidget {
  final ActivityFeedItem transaction;
  const TransactionListItem({Key? key, required this.transaction})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(transaction.hash),
      subtitle: Text(transaction.info
          .toString()), // You may want to customize this based on your TransactionInfo structure
      onTap: () {
// Handle transaction tap
      },
    );
  }
}

class DashboardActivityFeedScreen extends StatefulWidget {
  const DashboardActivityFeedScreen({Key? key}) : super(key: key);
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
                    return TransactionListItem(
                        transaction: transactions[index]);
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
