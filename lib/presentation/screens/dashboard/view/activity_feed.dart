import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';

import 'package:horizon/presentation/common/tx_hash_display.dart';

import 'package:horizon/common/format.dart';

class SendTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  const SendTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Send $quantityNormalized $asset");
  }
}

class ReceiveTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  const ReceiveTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Text("Receive $quantityNormalized $asset");
  }
}

enum TransactionStatus {
  local,
  mempool,
  confirmed,
}

class TransactionStatusPill extends StatelessWidget {
  final TransactionStatus status;
  final String? text;

  const TransactionStatusPill({
    super.key,
    required this.status,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _getText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getText() {
    return text ??
        switch (status) {
          TransactionStatus.local => 'BROADCASTED',
          TransactionStatus.mempool => 'MEMPOOL',
          TransactionStatus.confirmed => 'CONFIRMED',
        };
  }

  Color _getBackgroundColor() {
    return switch (status) {
      TransactionStatus.local => Colors.blue[500]!.withOpacity(0.1),
      TransactionStatus.mempool => Colors.orange[500]!.withOpacity(0.1),
      TransactionStatus.confirmed => Colors.green[500]!.withOpacity(0.1)
    };
  }

  Color _getTextColor() {
    return switch (status) {
      TransactionStatus.local => Colors.blue[400]!,
      TransactionStatus.mempool => Colors.orange[400]!,
      TransactionStatus.confirmed => Colors.green[400]!,
    };
  }
}

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

enum SendSide { source, destination }

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
      // onTap: () {},
    );
  }

  Widget _buildTitle() {
    if (item.event != null) {
      return _buildEventTitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoTitle(item.info!);
    } else if (item.bitcoinTx != null) {
      return _buildBitcoinTxTitle(item.bitcoinTx!);
    } else {
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

  Widget _buildBitcoinTxTitle(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a.address).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => SendTitle(
          quantityNormalized: tx.getAmountSentNormalized(addresses_).toString(),
          asset: 'BTC',
        ),
      // TODO: assumes single party send?
      TransactionType.recipient => ReceiveTitle(
          quantityNormalized:
              tx.getAmountReceivedNormalized(addresses_).toString(),
          asset: 'BTC',
        ),
      TransactionType.neither =>
        const Text('Invariant: account neither sender or receiver')
    };
  }

  Widget _buildEventTitle(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SendTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
        ),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        ReceiveTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
        ),
      VerboseAssetIssuanceEvent(params: var params) =>
        Text("Issue ${params.quantityNormalized} ${params.asset}"),
      VerboseDispenseEvent(params: var params) => Text(
          "Dispense ${params.dispenseQuantityNormalized} ${params.asset} for ${params.btcAmountNormalized} BTC"),
      _ =>
        Text('Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildTransactionInfoTitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoEnhancedSendVerbose(
        unpackedData: var unpackedData,
      ) =>
        SendTitle(
            quantityNormalized: unpackedData.quantityNormalized,
            asset: unpackedData.asset),
      TransactionInfoIssuanceVerbose(
        unpackedData: var unpackedData,
      ) =>
        Text("Issue ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      // btc send
      TransactionInfoVerbose(btcAmount: var btcAmount)
          when btcAmount != null && btcAmount > 0 =>
        SendTitle(
          quantityNormalized: satoshisToBtc(btcAmount).toString(),
          asset: 'BTC',
        ),
      _ => Text(
          'Invariant: title unsupported TransactionInfo type: ${info.runtimeType}'),
    };
  }

  Icon _getTransactionInfoLeading(TransactionInfo info) {
    return switch (info) {
      // local can only ever be a send
      TransactionInfoEnhancedSendVerbose() =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      TransactionInfoIssuanceVerbose() =>
        const Icon(Icons.toll, color: Colors.grey),
      TransactionInfoVerbose(btcAmount: var btcAmount) when btcAmount != null =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      _ => const Icon(Icons.error),
    };
  }

  Widget _buildSubtitle() {
    if (item.event != null) {
      return _buildEventSubtitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoSubtitle(item.info!);
    } else if (item.bitcoinTx != null) {
      return _buildBitcoinTxSubtitle(item.bitcoinTx!);
    } else {
      return const Text('No details available');
    }
  }

  Widget _buildEventSubtitle(Event event) {
    return switch (event) {
      VerboseAssetIssuanceEvent(txHash: var hash) =>
        TxHashDisplay(hash: hash, uriType: URIType.hoex),
      VerboseEnhancedSendEvent(txHash: var hash) =>
        TxHashDisplay(hash: hash, uriType: URIType.hoex),
      VerboseDispenseEvent(txHash: var hash) =>
        TxHashDisplay(hash: hash, uriType: URIType.hoex),
      _ => Text(
          'Invariant: subtitle unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildTransactionInfoSubtitle(TransactionInfo info) {
    return switch (info) {
      // local can only ever be a send
      TransactionInfoEnhancedSendVerbose() =>
        TxHashDisplay(hash: info.hash, uriType: URIType.hoex),
      TransactionInfoIssuanceVerbose() =>
        TxHashDisplay(hash: info.hash, uriType: URIType.hoex),
      TransactionInfoVerbose(btcAmount: var btcAmount) when btcAmount != null =>
        TxHashDisplay(hash: info.hash, uriType: URIType.btcexplorer),
      _ => const Icon(Icons.error),
    };
  }

  Widget _buildBitcoinTxSubtitle(BitcoinTx btx) {
    return TxHashDisplay(
      hash: btx.txid,
      uriType: URIType.btcexplorer,
    );
  }

  Widget _buildTrailing() {
    if (item.event != null) {
      return _getEventTrailing(item.event!.state);
    } else if (item.info != null) {
      return _getTransactionTrailing(item.info!.domain);
    } else if (item.bitcoinTx != null) {
      return _getBitcoinTxTrailing(item.bitcoinTx!);
    } else {
      return const Icon(Icons.error);
    }
  }

  Widget _buildLeadingIcon() {
    if (item.event != null) {
      return _getEventLeadingIcon(item.event!);
    } else if (item.info != null) {
      return _getTransactionInfoLeading(item.info!);
    } else {
      return _getBitcoinTxLeadingIcon(item.bitcoinTx!);
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
      VerboseDispenseEvent(params: var params) =>
        const Icon(Icons.paid, color: Colors.grey),
      _ => const Icon(Icons.error),
    };
  }

  Icon _getBitcoinTxLeadingIcon(BitcoinTx btx) {
    final addresses_ = addresses.map((a) => a.address).toList();

    return switch (btx.getTransactionType(addresses_)) {
      TransactionType.sender => const Icon(Icons.arrow_back, color: Colors.red),
      // TODO: assumes single party send?
      TransactionType.recipient =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      TransactionType.neither =>
        const Icon(Icons.arrow_forward, color: Colors.green),
    };
  }

  Widget _getEventTrailing(EventState state) => switch (state) {
        EventStateMempool() =>
          const TransactionStatusPill(status: TransactionStatus.mempool),
        EventStateConfirmed(blockHeight: var blockHeight) =>
          TransactionStatusPill(
              status: TransactionStatus.confirmed,
              text: "${item.confirmations} confirmations"),
      };

  Widget _getTransactionTrailing(TransactionInfoDomain domain) {
    return switch (domain) {
      TransactionInfoDomainLocal() =>
        const TransactionStatusPill(status: TransactionStatus.local),
      TransactionInfoDomainMempool() =>
        const TransactionStatusPill(status: TransactionStatus.mempool),
      TransactionInfoDomainConfirmed() =>
        const TransactionStatusPill(status: TransactionStatus.confirmed),
    };
  }

  Widget _getBitcoinTxTrailing(BitcoinTx btx) {
    return switch (btx.status) {
      Status(confirmed: var confirmed, blockHeight: var blockHeight)
          when confirmed =>
        TransactionStatusPill(
            status: TransactionStatus.confirmed,
            text: "${item.confirmations} confirmations"),
      _ => const TransactionStatusPill(status: TransactionStatus.mempool),
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
  DashboardActivityFeedBloc? _bloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DashboardActivityFeedBloc>();

    // Start polling after the first frame
    // TODO: make this part of config?

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc?.add(const StartPolling(interval: Duration(seconds: 30)));
    });
  }

  @override
  void dispose() {
    // Use the saved reference to the bloc
    _bloc?.add(const StopPolling());
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
          return Center(child: SelectableText('Error: ${state.error}'));
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
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    return ActivityFeedListItem(
                      key: ValueKey(transactions[index].hash),
                      item: transactions[index],
                      addresses: widget.addresses,
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
