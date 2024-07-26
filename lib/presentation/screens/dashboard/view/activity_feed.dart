import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/display_transaction.dart';

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
final DisplayTransaction transaction;
const TransactionListItem({Key? key, required this.transaction}) : super(key: key);
@override
Widget build(BuildContext context) {
return ListTile(
title: Text(transaction.hash),
subtitle: Text(transaction.info.toString()), // You may want to customize this based on your TransactionInfo structure
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
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<DashboardActivityFeedBloc>().add(const Load());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<DashboardActivityFeedBloc>().add(const LoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Feed'),
      ),
      body: BlocBuilder<DashboardActivityFeedBloc, DashboardActivityFeedState>(
        builder: (context, state) {
          if (state is DashboardActivityFeedStateInitial ||
              state is DashboardActivityFeedStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardActivityFeedStateCompleteError) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is DashboardActivityFeedStateCompleteOk ||
              state is DashboardActivityFeedStateReloadingOk) {
            final transactions =
                (state as dynamic).transactions as List<DisplayTransaction>;
            final newTransactionCount =
                (state as dynamic).newTransactionCount as int;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardActivityFeedBloc>().add(const Load());
              },
              child: Column(
                children: [
                  if (newTransactionCount > 0)
                    NewTransactionsBanner(count: newTransactionCount),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: transactions.length + 1,
                      itemBuilder: (context, index) {
                        if (index == transactions.length) {
                          return state is DashboardActivityFeedStateReloadingOk
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink();
                        }
                        return TransactionListItem(
                            transaction: transactions[index]);
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
