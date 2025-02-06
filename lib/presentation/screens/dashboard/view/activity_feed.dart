import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_state.dart';
import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/presentation/common/no_data.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/presentation/common/tx_hash_display.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/compose_rbf/view/compose_rbf_view.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:get_it/get_it.dart';

class RBF extends StatelessWidget {
  final String txHash;
  final String address;
  const RBF({
    super.key,
    required this.txHash,
    required this.address,
  });
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          HorizonUI.HorizonDialog.show(
            context: context,
            body: ComposeRBFPageWrapper(
                passwordRequired: GetIt.I
                    .get<SettingsRepository>()
                    .requirePasswordForCryptoOperations,
                dashboardActivityFeedBloc:
                    context.read<DashboardActivityFeedBloc>(),
                txHash: txHash,
                address: address),
          );
        },
        icon: const Icon(Icons.rocket_launch_sharp));
  }
}

class SendTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  final bool? isMpma;
  const SendTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
    this.isMpma,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(isMpma == true
        ? "MPMA Send $quantityNormalized $asset"
        : "Send $quantityNormalized $asset");
  }
}

class ReceiveTitle extends StatelessWidget {
  final String quantityNormalized;
  final String asset;
  final bool? isMpma;
  const ReceiveTitle({
    super.key,
    required this.quantityNormalized,
    required this.asset,
    this.isMpma,
  });

  @override
  Widget build(BuildContext context) {
    return SelectableText(isMpma == true
        ? "MPMA Receive $quantityNormalized $asset"
        : "Receive $quantityNormalized $asset");
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
      child: SelectableText(
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
          child: SelectableText(
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
  final List<String> addresses;
  final bool isMobile;

  const ActivityFeedListItem(
      {super.key,
      required this.item,
      required this.addresses,
      required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      leading: _buildLeadingIcon(),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        _buildRBF() ?? const SizedBox.shrink(),
        _buildTrailing(),
      ]),
      // onTap: () {},
    );
  }

  Widget? _buildRBF() {
    if (item.event != null && item.event!.state is EventStateMempool) {
      return _buildRBFEvent(item.event!);
    }
    if (item.bitcoinTx != null && item.bitcoinTx!.status.confirmed == false) {
      return _buildRBFBitcoinTx(item.bitcoinTx!);
    }
    return null;
  }

  Widget? _buildRBFBitcoinTx(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => RBF(txHash: tx.txid, address: addresses.first),
      _ => null
    };
  }

  Widget? _buildRBFEvent(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        RBF(txHash: params.txHash, address: params.source),
      VerboseAssetIssuanceEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseResetIssuanceEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,

      // for dispense, source and destination are inverted
      VerboseDispenseEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseOpenDispenserEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseRefillDispenserEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseDispenserUpdateEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseNewFairmintEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseNewFairminterEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseOpenOrderEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseCancelOrderEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseAttachToUtxoEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      VerboseDetachFromUtxoEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      AssetDestructionEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      AssetDividendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      BurnEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        event.txHash != null
            ? RBF(txHash: event.txHash!, address: params.source)
            : null,
      _ => null,
    };
  }

  Widget _buildTitle() {
    if (item.event != null) {
      return _buildEventTitle(item.event!);
    } else if (item.info != null) {
      return _buildTransactionInfoTitle(item.info!);
    } else if (item.bitcoinTx != null) {
      return _buildBitcoinTxTitle(item.bitcoinTx!);
    } else {
      return const SelectableText('No details available');
    }
  }

  SendSide _getSendSide(String address) {
    if (addresses.any((a) => a == address)) {
      return SendSide.source;
    } else {
      return SendSide.destination;
    }
  }

  Widget _buildBitcoinTxTitle(BitcoinTx tx) {
    final addresses_ = addresses.map((a) => a).toList();

    return switch (tx.getTransactionType(addresses_)) {
      TransactionType.sender => SendTitle(
          quantityNormalized:
              tx.getAmountSentNormalized(addresses_).toStringAsFixed(8),
          asset: 'BTC',
        ),
      // TODO: assumes single party send?
      TransactionType.recipient => ReceiveTitle(
          quantityNormalized:
              tx.getAmountReceivedNormalized(addresses_).toStringAsFixed(8),
          asset: 'BTC',
        ),
      TransactionType.neither =>
        const SelectableText('Invariant: account neither sender or receiver')
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
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SendTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
          isMpma: true,
        ),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        ReceiveTitle(
          quantityNormalized: params.quantityNormalized,
          asset: params.asset,
          isMpma: true,
        ),
      VerboseAssetIssuanceEvent(params: var params) =>
        _buildAssetIssuanceTitle(params),
      VerboseResetIssuanceEvent(params: var params) => SelectableText(
          "Reset Issuance ${displayAssetName(params.asset, params.assetLongname)}"),
      VerboseDispenseEvent(params: var params) => SelectableText(
          "Dispense ${params.dispenseQuantityNormalized} ${params.asset} for ${params.btcAmountNormalized} BTC"),
      VerboseOpenDispenserEvent(params: var params) =>
        SelectableText("Open Dispenser for ${params.asset}"),
      VerboseRefillDispenserEvent(params: var params) =>
        SelectableText("Refill Dispenser for ${params.asset}"),
      VerboseDispenserUpdateEvent(params: var params) =>
        _buildDispenserUpdateTitle(params),
      VerboseNewFairmintEvent(params: var params) =>
        _buildNewFairmintTitle(params),
      VerboseNewFairminterEvent(params: var params) =>
        _buildNewFairminterTitle(params),
      VerboseOpenOrderEvent(params: var params) => SelectableText(
          "Open Order: ${params.giveQuantityNormalized} ${params.giveAsset} /  ${params.getQuantityNormalized} ${params.getAsset} "),
      VerboseOrderMatchEvent(params: var params) => SelectableText(
          "Order Match: ${params.forwardQuantityNormalized} ${params.forwardAsset} / ${params.backwardQuantityNormalized} ${params.backwardAsset}"),
      VerboseOrderUpdateEvent() => const SelectableText("Order Update"),
      VerboseOrderFilledEvent(params: var _) =>
        const SelectableText("Order Filled"),
      VerboseCancelOrderEvent(params: var params) =>
        const SelectableText("Order Cancelled"),
      VerboseOrderExpirationEvent(params: var params) =>
        const SelectableText("Order Expiration"),
      VerboseNewFairminterEvent(params: var params) =>
        _buildNewFairminterTitle(params),
      VerboseAttachToUtxoEvent(params: var params) => SelectableText(
          "Attach to UTXO ${params.asset} ${params.quantityNormalized}"),
      VerboseDetachFromUtxoEvent(params: var params) => SelectableText(
          "Detach from UTXO ${params.asset} ${params.quantityNormalized}"),
      VerboseMoveToUtxoEvent(params: var params) => SelectableText(
          "Move to UTXO ${params.asset} ${params.quantityNormalized}"),
      AtomicSwapEvent(params: var params) => SelectableText(
          "Swap ${params.quantityNormalized} ${params.asset} for ${params.bitcoinSwapAmount} BTC"),
      AssetDestructionEvent(params: var params) =>
        SelectableText("Destroy ${params.quantityNormalized} ${params.asset}"),
      AssetDividendEvent(params: var params) => SelectableText(
          "Dividend ${params.asset} - ${params.dividendAsset} ${params.quantityPerUnitNormalized} per unit"),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        SelectableText(
            "Sweep ${flagMapper[params.flags]} to ${params.destination}"),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        SelectableText(
            "Sweep ${flagMapper[params.flags]} from ${params.source}"),
      BurnEvent(params: var params) => SelectableText(
          "Burn ${params.burnedNormalized} BTC for ${params.earnedNormalized} XCP"),
      _ => SelectableText(
          'Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildAssetIssuanceTitle(VerboseAssetIssuanceParams params) {
    if (params.transfer && params.assetEvents != 'fairmint') {
      if (addresses.any((a) => a == params.source)) {
        return SelectableText(
            "Transfer Out of ${displayAssetName(params.asset, params.assetLongname)}");
      } else {
        return SelectableText(
            "Transfer In of ${displayAssetName(params.asset, params.assetLongname)}");
      }
    }
    if (params.assetEvents != null && params.assetEvents!.isNotEmpty) {
      return switch (params.assetEvents) {
        "reissuance" => SelectableText(
            "Reissue ${displayAssetName(params.asset, params.assetLongname)}"),
        "lock_quantity" => SelectableText(
            "Lock Quantity for ${displayAssetName(params.asset, params.assetLongname)}"),
        "change_description" => SelectableText(
            "Change Description for ${displayAssetName(params.asset, params.assetLongname)}"),
        "lock_description" => SelectableText(
            "Lock Description for ${displayAssetName(params.asset, params.assetLongname)}"),
        "open_fairminter" => SelectableText(
            "New Fairminter for ${displayAssetName(params.asset, params.assetLongname)}"),
        "fairmint" => SelectableText(
            "Fairmint for ${displayAssetName(params.asset, params.assetLongname)}"),
        "transfer" => addresses.any((a) => a == params.source)
            ? SelectableText(
                "Transfer Out of ${displayAssetName(params.asset, params.assetLongname)}")
            : SelectableText(
                "Transfer In of ${displayAssetName(params.asset, params.assetLongname)}"),
        _ => SelectableText(
            "Issue ${params.quantityNormalized} ${displayAssetName(params.asset, params.assetLongname)}"),
      };
    }
    if (params.asset == null || params.quantityNormalized == null) {
      return const SelectableText('Issue (INVALID)',
          style: TextStyle(color: redErrorText));
    }
    return SelectableText(
        "Issue ${params.quantityNormalized} ${displayAssetName(params.asset, params.assetLongname)}");
  }

  Widget _buildNewFairmintTitle(VerboseNewFairmintParams params) {
    if (params.status?.contains('invalid') ?? false) {
      return const SelectableText('New Fairmint (INVALID)',
          style: TextStyle(color: redErrorText));
    }
    return SelectableText("New Fairmint for ${params.asset}");
  }

  Widget _buildNewFairminterTitle(VerboseNewFairminterParams params) {
    if (params.status?.contains('invalid') ?? false) {
      return const SelectableText('New Fairminter (INVALID)',
          style: TextStyle(color: redErrorText));
    }
    return SelectableText("New Fairminter for ${params.asset}");
  }

  Widget _buildDispenserUpdateTitle(VerboseDispenserUpdateParams params) {
    if (params.status == 10 || params.status == 11) {
      return SelectableText("Close Dispenser for ${params.asset}");
    } else {
      return SelectableText("Update Dispenser for ${params.asset}");
    }
  }

  Widget _buildTransactionInfoTitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoMpmaSend(unpackedData: var unpackedData) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: unpackedData.messageData
              .map((data) => SendTitle(
                    quantityNormalized: data.quantityNormalized!,
                    asset: data.asset,
                    isMpma: true,
                  ))
              .toList(),
        ),
      TransactionInfoAttach(
        unpackedData: var unpackedData,
      ) =>
        SelectableText(
            "Attach to UTXO ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      TransactionInfoMoveToUtxo() => const SelectableText("Move to UTXO"),
      TransactionInfoEnhancedSend(
        unpackedData: var unpackedData,
      ) =>
        SendTitle(
            quantityNormalized: unpackedData.quantityNormalized,
            asset: unpackedData.asset),
      TransactionInfoIssuance(
        unpackedData: var unpackedData,
      ) =>
        SelectableText(
            "Issue ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      TransactionInfo(btcAmount: var btcAmount)
          when btcAmount != null && btcAmount > 0 =>
        SendTitle(
          quantityNormalized: satoshisToBtc(btcAmount).toStringAsFixed(8),
          asset: 'BTC',
        ),
      TransactionInfoDispense(
        unpackedData: var unpackedData,
      ) =>
        const SelectableText("Trigger Dispense"),
      // btc send
      TransactionInfoDispenser(
        unpackedData: var unpackedData,
      ) =>
        SelectableText("Open or Update Dispenser for ${unpackedData.asset}"),
      TransactionInfoFairmint(
        unpackedData: var unpackedData,
      ) =>
        SelectableText("New Fairmint for ${unpackedData.asset}"),
      TransactionInfoFairminter(
        unpackedData: var unpackedData,
      ) =>
        SelectableText("New Fairminter for ${unpackedData.asset}"),
      TransactionInfoOrder(
        unpackedData: var unpackedData,
      ) =>
        SelectableText(
            "Open Order: ${unpackedData.giveQuantityNormalized} ${unpackedData.giveAsset} /  ${unpackedData.getQuantityNormalized} ${unpackedData.getAsset}"),
      TransactionInfoCancel(
        unpackedData: var _,
      ) =>
        const SelectableText("Cancel Order"),
      TransactionInfoDetach(
        unpackedData: var unpackedData,
      ) =>
        SelectableText("Detach from UTXO ${unpackedData.destination}"),
      TransactionInfoAssetDestruction(unpackedData: var unpackedData) =>
        SelectableText(
            "Destroy ${unpackedData.quantityNormalized} ${unpackedData.asset}"),
      TransactionInfoAssetDividend(unpackedData: var unpackedData) =>
        SelectableText("Dividend ${unpackedData.asset}"),
      TransactionInfoSweep(unpackedData: var unpackedData) => SelectableText(
          "Sweep ${flagMapper[unpackedData.flags]} to ${unpackedData.destination}"),
      _ => SelectableText(
          'Invariant: title unsupported TransactionInfo type: ${info.runtimeType}'),
    };
  }

  Icon _getTransactionInfoLeading(TransactionInfo info) {
    return switch (info) {
      TransactionInfoMpmaSend() =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      TransactionInfoEnhancedSend() =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      TransactionInfoIssuance() => const Icon(Icons.toll, color: Colors.grey),
      TransactionInfoDispenser() =>
        const Icon(Icons.account_balance, color: Colors.grey),
      TransactionInfoDispense() => const Icon(Icons.paid, color: Colors.grey),
      TransactionInfoFairmint() => const Icon(Icons.money, color: Colors.grey),
      TransactionInfoFairminter() =>
        const Icon(Icons.print, color: Colors.grey),
      TransactionInfoOrder() => const Icon(Icons.toc, color: Colors.grey),
      TransactionInfoCancel() => const Icon(Icons.toc, color: Colors.grey),
      TransactionInfoAttach() =>
        const Icon(Icons.attach_file, color: Colors.grey),
      TransactionInfoDetach() => const Icon(Icons.link_off, color: Colors.grey),
      TransactionInfoMoveToUtxo() =>
        const Icon(Icons.swap_horiz, color: Colors.grey),
      TransactionInfoAssetDestruction() =>
        const Icon(Icons.delete_forever, color: Colors.grey),
      TransactionInfoAssetDividend() =>
        const Icon(Icons.currency_exchange, color: Colors.grey),
      TransactionInfo(btcAmount: var btcAmount) when btcAmount != null =>
        const Icon(Icons.arrow_back, color: Colors.grey),
      TransactionInfoSweep() =>
        const Icon(Icons.cleaning_services, color: Colors.grey),
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
      return const SelectableText('No details available');
    }
  }

  Widget _buildEventSubtitle(Event event) {
    return switch (event) {
      VerboseAssetIssuanceEvent(txHash: var hash, params: var params) => Row(
          children: [
            hash != null
                ? TxHashDisplay(hash: hash, uriType: URIType.hoex)
                : const SizedBox.shrink(),
            switch (params.status) {
              EventStatusValid() => const SizedBox.shrink(),
              EventStatusInvalid(reason: var reason) => Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded, // Warning icon
                        color: redErrorText, // Icon color
                        size: 16.0, // Small icon size
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                        child: SelectableText(reason,
                            style: const TextStyle(color: redErrorText)),
                      ),
                    ],
                  ),
                ),
            }
          ],
        ),
      VerboseOrderExpirationEvent(params: var params) => Row(
          children: [
            const Text("order hash:"),
            const SizedBox(width: 10.0),
            TxHashDisplay(hash: params.orderHash, uriType: URIType.hoex)
          ],
        ),
      VerboseEvent(txHash: var hash) => hash != null
          ? TxHashDisplay(hash: hash, uriType: URIType.hoex)
          : const SizedBox.shrink(),
      _ => SelectableText(
          'Invariant: subtitle unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildTransactionInfoSubtitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoCancel(unpackedData: var unpackedData) => Row(
          children: [
            const Text("order hash:"),
            const SizedBox(width: 10.0),
            TxHashDisplay(hash: unpackedData.orderHash, uriType: URIType.hoex)
          ],
        ),
      TransactionInfo(btcAmount: var btcAmount) when btcAmount != null =>
        TxHashDisplay(hash: info.hash, uriType: URIType.btcexplorer),
      _ => TxHashDisplay(hash: info.hash, uriType: URIType.hoex)
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
      return _getEventTrailing(item.event!.state, item.event!.txHash);
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
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        const Icon(Icons.arrow_back, color: Colors.red),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      VerboseAssetIssuanceEvent(params: var _) =>
        _getAssetIssuanceLeadingIcon(event),
      VerboseResetIssuanceEvent(params: var _) =>
        const Icon(Icons.toll, color: Colors.grey),
      VerboseDispenseEvent(params: var _) =>
        const Icon(Icons.paid, color: Colors.grey),
      VerboseOpenDispenserEvent(params: var _) =>
        const Icon(Icons.account_balance, color: Colors.grey),
      VerboseRefillDispenserEvent(params: var _) =>
        const Icon(Icons.account_balance, color: Colors.grey),
      VerboseDispenserUpdateEvent(params: var params) =>
        const Icon(Icons.account_balance, color: Colors.grey),
      VerboseNewFairmintEvent(params: var _) =>
        const Icon(Icons.money, color: Colors.grey),
      VerboseNewFairminterEvent(params: var _) =>
        const Icon(Icons.print, color: Colors.grey),
      VerboseOpenOrderEvent(params: var _) =>
        const Icon(Icons.toc, color: Colors.grey),
      VerboseOrderMatchEvent(params: var _) =>
        const Icon(Icons.toc, color: Colors.grey),
      VerboseOrderUpdateEvent() => const Icon(Icons.toc, color: Colors.grey),
      VerboseOrderFilledEvent(params: var _) =>
        const Icon(Icons.toc, color: Colors.grey),
      VerboseCancelOrderEvent(params: var _) =>
        const Icon(Icons.toc, color: Colors.grey),
      VerboseOrderExpirationEvent(params: var _) =>
        const Icon(Icons.toc, color: Colors.grey),
      VerboseAttachToUtxoEvent(params: var _) =>
        const Icon(Icons.attach_file, color: Colors.grey),
      VerboseDetachFromUtxoEvent(params: var _) =>
        const Icon(Icons.link_off, color: Colors.grey),
      VerboseMoveToUtxoEvent(params: var _) =>
        const Icon(Icons.swap_horiz, color: Colors.grey),
      AtomicSwapEvent(params: var _) =>
        const Icon(Icons.swap_horiz, color: Colors.grey),
      AssetDestructionEvent(params: var _) =>
        const Icon(Icons.delete_forever, color: Colors.grey),
      AssetDividendEvent(params: var _) =>
        const Icon(Icons.currency_exchange, color: Colors.grey),
      SweepEvent(params: var _) =>
        const Icon(Icons.cleaning_services, color: Colors.grey),
      BurnEvent(params: var _) =>
        const Icon(Icons.local_fire_department, color: Colors.grey),
      _ => const Icon(Icons.error),
    };
  }

  Icon _getAssetIssuanceLeadingIcon(VerboseAssetIssuanceEvent event) {
    if (event.params.assetEvents == "open_fairminter") {
      return const Icon(Icons.print, color: Colors.grey);
    } else if (event.params.assetEvents == "fairmint") {
      return const Icon(Icons.money, color: Colors.grey);
    }
    return const Icon(Icons.toll, color: Colors.grey);
  }

  Icon _getBitcoinTxLeadingIcon(BitcoinTx btx) {
    return switch (btx.getTransactionType(addresses)) {
      TransactionType.sender => const Icon(Icons.arrow_back, color: Colors.red),
      // TODO: assumes single party send?
      TransactionType.recipient =>
        const Icon(Icons.arrow_forward, color: Colors.green),
      TransactionType.neither =>
        const Icon(Icons.arrow_forward, color: Colors.green),
    };
  }

  Widget _getEventTrailing(EventState state, String? txHash) => switch (state) {
        EventStateMempool() =>
          const TransactionStatusPill(status: TransactionStatus.mempool),
        EventStateConfirmed(blockHeight: var blockHeight) =>
          TransactionStatusPill(
              status: TransactionStatus.confirmed,
              text: _getConfirmations(item.confirmations, blockHeight)),
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
            text: _getConfirmations(item.confirmations, blockHeight)),
      _ => const TransactionStatusPill(status: TransactionStatus.mempool),
    };
  }

  String _getConfirmations(int? confirmations, int? blockHeight) {
    return switch (confirmations) {
      null => "#${numberWithCommas.format(blockHeight)}",
      _ =>
        "${confirmations > 6 ? '>6' : confirmations}${isMobile ? '' : ' confirmations'}",
    };
  }
}

class DashboardActivityFeedScreen extends StatefulWidget {
  final List<String> addresses; // this is always = [sourceAddress]
  final int initialItemCount;
  const DashboardActivityFeedScreen(
      {super.key, required this.addresses, required this.initialItemCount});

  @override
  DashboardActivityFeedScreenState createState() =>
      DashboardActivityFeedScreenState();
}

class DashboardActivityFeedScreenState
    extends State<DashboardActivityFeedScreen> {
  late int _displayedTransactionsCount;
  static const int pageSize = 20;
  DashboardActivityFeedBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _displayedTransactionsCount = widget.initialItemCount;
    // Start polling after the first frame
    _bloc = context.read<DashboardActivityFeedBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc?.add(const StartPolling(interval: Duration(seconds: 30)));
    });
  }

  @override
  void dispose() {
    _bloc?.add(const StopPolling());
    super.dispose();
  }

  Widget _buildNewTransactionsBanner(DashboardActivityFeedState state) {
    final newTransactionCount = (state as dynamic).newTransactionCount as int;
    if (newTransactionCount > 0) {
      return NewTransactionsBanner(count: newTransactionCount);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      listener: (context, state) {
        // print('DashboardActivityFeedBloc state changed: $state');
      },
      builder: (context, state) {
        final widgets = <Widget>[];

        if (state is DashboardActivityFeedStateCompleteOk ||
            state is DashboardActivityFeedStateReloadingOk) {
          widgets.add(_buildNewTransactionsBanner(state));
        }

        widgets.addAll(_buildContent(state));

        if (state is DashboardActivityFeedStateCompleteOk &&
            state.transactions.length > _displayedTransactionsCount) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _displayedTransactionsCount += pageSize;
                  });
                },
                child: const Text("View More"),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => widgets[index],
            childCount: widgets.length,
          ),
        );
      },
    );
  }

  List<Widget> _buildContent(DashboardActivityFeedState state) {
    if (state is DashboardActivityFeedStateInitial ||
        state is DashboardActivityFeedStateLoading) {
      return [
        const SizedBox(
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        )
      ];
    } else if (state is DashboardActivityFeedStateCompleteError) {
      return [
        SizedBox(
          height: 200,
          child: Center(child: Text('Error: ${state.error}')),
        )
      ];
    } else if (state is DashboardActivityFeedStateCompleteOk ||
        state is DashboardActivityFeedStateReloadingOk) {
      final transactions =
          (state as dynamic).transactions as List<ActivityFeedItem>;

      final filteredTransactions = transactions.where((t) {
        if (t.event != null &&
            t.event is VerboseAssetIssuanceEvent &&
            t.event?.state is EventStateMempool) {
          final assetIssuanceEvent = t.event as VerboseAssetIssuanceEvent;
          final isFairmintIssuance =
              (assetIssuanceEvent.params.assetEvents == "fairmint" &&
                  !widget.addresses
                      .any((a) => a == assetIssuanceEvent.params.source));
          final isOpenFairminterIssuance =
              assetIssuanceEvent.params.assetEvents == "open_fairminter";
          // asset issuance events for fairmints on the source address and fairminters are already captured by NEW_FAIRMINT and NEW_FAIRMINTER events
          // we filter out ASSET_ISSUANCE for these cases so they don't display as duplicates in the activity feed
          return !isFairmintIssuance && !isOpenFairminterIssuance;
        }
        return true;
      }).toList();

      if (filteredTransactions.isEmpty) {
        return [
          const NoData(
            title: 'No Transactions',
          )
        ];
      }

      final displayedTransactions =
          filteredTransactions.take(_displayedTransactionsCount).toList();
      final isMobile = MediaQuery.of(context).size.width < 600;

      return displayedTransactions
          .map((transaction) => ActivityFeedListItem(
                key: ValueKey(transaction.id),
                item: transaction,
                addresses: widget.addresses,
                isMobile: isMobile,
              ))
          .toList();
    }

    throw Exception('Invalid state: $state');
  }
}
