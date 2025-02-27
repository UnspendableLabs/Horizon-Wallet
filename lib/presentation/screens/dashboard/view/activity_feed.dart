import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/uuid.dart';
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
import 'package:horizon/presentation/screens/dashboard/view/balances_display.dart';
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

  String _formatQuantity(String? quantity) {
    if (quantity == null) return '';
    return quantity
        .replaceAll(RegExp(r'(?<=\d)0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: _buildTitle(),
      subtitle: _buildSubtitle(),
      // TODO: ADD RBF
      // trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      //   _buildRBF() ?? const SizedBox.shrink(),
      // ]),
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
      TransactionType.sender => Row(
          children: [
            const Text(
              "Send",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(tx.getAmountSentNormalized(addresses_).toStringAsFixed(8))} BTC",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      TransactionType.recipient => Row(
          children: [
            const Text(
              "Receive",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(tx.getAmountReceivedNormalized(addresses_).toStringAsFixed(8))} BTC",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      TransactionType.neither => const Row(
          children: [
            Text(
              "Invariant: account neither sender or receiver",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
    };
  }

  Widget _buildEventTitle(Event event) {
    return switch (event) {
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        Row(
          children: [
            const Text(
              "Send",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseEnhancedSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        Row(
          children: [
            const Text(
              "Receive",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        Row(
          children: [
            const Text(
              "MPMA Send",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseMpmaSendEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        Row(
          children: [
            const Text(
              "MPMA Receive",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseAssetIssuanceEvent(params: var params) =>
        _buildAssetIssuanceTitle(params),
      VerboseResetIssuanceEvent(params: var params) => Row(
          children: [
            const Text(
              "Reset",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        ),
      VerboseDispenseEvent(params: var params) => Row(
          children: [
            const Text(
              "Dispense",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.dispenseQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseOpenDispenserEvent(params: var params) => Row(
          children: [
            const Text(
              "Open Dispenser",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseRefillDispenserEvent(params: var params) => Row(
          children: [
            const Text(
              "Refill Dispenser",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseDispenserUpdateEvent(params: var params) => Row(
          children: [
            Text(
              params.status == 10 || params.status == 11
                  ? "Close Dispenser"
                  : "Update Dispenser",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseNewFairmintEvent(params: var params) => Row(
          children: [
            Text(
              params.status?.contains('invalid') ?? false
                  ? "Fairmint (INVALID)"
                  : "Fairmint",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: params.status?.contains('invalid') ?? false
                    ? redErrorText
                    : null,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseNewFairminterEvent(params: var params) => Row(
          children: [
            Text(
              params.status?.contains('invalid') ?? false
                  ? "Fairminter (INVALID)"
                  : "Fairminter",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: params.status?.contains('invalid') ?? false
                    ? redErrorText
                    : null,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseOpenOrderEvent(params: var params) => Row(
          children: [
            const Text(
              "Open Order",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.giveQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.giveAsset),
            Text(
              " / ${_formatQuantity(params.getQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.getAsset),
          ],
        ),
      VerboseOrderMatchEvent(params: var params) => Row(
          children: [
            const Text(
              "Order Match",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.forwardQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.forwardAsset),
            Text(
              " / ${_formatQuantity(params.backwardQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.backwardAsset),
          ],
        ),
      VerboseOrderUpdateEvent() => const Row(
          children: [
            Text(
              "Order Update",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      VerboseOrderFilledEvent(params: var _) => const Row(
          children: [
            Text(
              "Order Filled",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      VerboseCancelOrderEvent(params: var _) => const Row(
          children: [
            Text(
              "Cancel Order",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      VerboseOrderExpirationEvent(params: var _) => const Row(
          children: [
            Text(
              "Order Expiration",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      VerboseAttachToUtxoEvent(params: var params) => Row(
          children: [
            const Text(
              "Attach to UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseDetachFromUtxoEvent(params: var params) => Row(
          children: [
            const Text(
              "Detach from UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      VerboseMoveToUtxoEvent(params: var params) => Row(
          children: [
            const Text(
              "Move to UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      AtomicSwapEvent(params: var params) => Row(
          children: [
            const Text(
              "Swap",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
            Text(
              " for ${_formatQuantity(params.bitcoinSwapAmount)} BTC",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      AssetDestructionEvent(params: var params) => Row(
          children: [
            const Text(
              "Destroy",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(params.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(params.asset),
          ],
        ),
      AssetDividendEvent(params: var params) => Row(
          children: [
            const Text(
              "Dividend",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.dividendAsset),
            Text(
              " ${_formatQuantity(params.quantityPerUnitNormalized)} per unit",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.source =>
        Row(
          children: [
            const Text(
              "Sweep out",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${flagMapper[params.flags]}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      SweepEvent(params: var params)
          when _getSendSide(params.source) == SendSide.destination =>
        Row(
          children: [
            const Text(
              "Sweep in",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${flagMapper[params.flags]}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      BurnEvent(params: var params) => Row(
          children: [
            const Text(
              "Burn",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${params.burnedNormalized} BTC for ${params.earnedNormalized} XCP",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      _ => SelectableText(
          'Invariant: title unsupported event type: ${event.runtimeType}'),
    };
  }

  Widget _buildAssetIssuanceTitle(VerboseAssetIssuanceParams params) {
    if (params.transfer && params.assetEvents != 'fairmint') {
      if (addresses.any((a) => a == params.source)) {
        return Row(
          children: [
            const Text(
              "Transfer Out",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        );
      } else {
        return Row(
          children: [
            const Text(
              "Transfer In",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(params.asset, params.assetLongname),
          ],
        );
      }
    }
    if (params.assetEvents != null && params.assetEvents!.isNotEmpty) {
      return switch (params.assetEvents) {
        "reissuance" => Row(
            children: [
              const Text(
                "Reissue",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "lock_quantity" => Row(
            children: [
              const Text(
                "Lock Quantity",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "change_description" => Row(
            children: [
              const Text(
                "Change Description",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "lock_description" => Row(
            children: [
              const Text(
                "Lock Description",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "open_fairminter" => Row(
            children: [
              const Text(
                "Fairminter",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "fairmint" => Row(
            children: [
              const Text(
                "Fairmint",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
        "transfer" => addresses.any((a) => a == params.source)
            ? Row(
                children: [
                  const Text(
                    "Transfer Out",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildAssetDisplay(params.asset, params.assetLongname),
                ],
              )
            : Row(
                children: [
                  const Text(
                    "Transfer In",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _buildAssetDisplay(params.asset, params.assetLongname),
                ],
              ),
        _ => Row(
            children: [
              const Text(
                "Issue",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                "${_formatQuantity(params.quantityNormalized)} ",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _buildAssetDisplay(params.asset, params.assetLongname),
            ],
          ),
      };
    }
    if (params.asset == null || params.quantityNormalized == null) {
      return const Row(
        children: [
          Text(
            "Issue (INVALID)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: redErrorText,
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        const Text(
          "Issue",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          "${_formatQuantity(params.quantityNormalized)} ",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        _buildAssetDisplay(params.asset, params.assetLongname),
      ],
    );
  }

  Widget _buildTransactionInfoTitle(TransactionInfo info) {
    return switch (info) {
      TransactionInfoMpmaSend(unpackedData: var unpackedData) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: unpackedData.messageData
              .map((data) => Row(
                    children: [
                      const Text(
                        "MPMA Send",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_formatQuantity(data.quantityNormalized)} ",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _buildAssetDisplay(data.asset),
                    ],
                  ))
              .toList(),
        ),
      TransactionInfoAttach(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Attach to UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(unpackedData.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoMoveToUtxo() => const Row(
          children: [
            Text(
              "Move to UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      TransactionInfoEnhancedSend(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Send",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(unpackedData.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoIssuance(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Issue",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(unpackedData.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfo(btcAmount: var btcAmount)
          when btcAmount != null && btcAmount > 0 =>
        Row(
          children: [
            const Text(
              "Send",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(satoshisToBtc(btcAmount).toStringAsFixed(8))} BTC",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      TransactionInfoDispense(unpackedData: var _) => const Row(
          children: [
            Text(
              "Trigger Dispense",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      TransactionInfoDispenser(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Open or Update Dispenser",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoFairmint(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Fairmint",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoFairminter(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Fairminter",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoOrder(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Open Order",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(unpackedData.giveQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.giveAsset),
            Text(
              " / ${_formatQuantity(unpackedData.getQuantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.getAsset),
          ],
        ),
      TransactionInfoCancel(unpackedData: var _) => const Row(
          children: [
            Text(
              "Cancel Order",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      TransactionInfoDetach(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Detach from UTXO",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              unpackedData.destination,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      TransactionInfoAssetDestruction(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Destroy",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${_formatQuantity(unpackedData.quantityNormalized)} ",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoAssetDividend(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Dividend",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            _buildAssetDisplay(unpackedData.asset),
          ],
        ),
      TransactionInfoSweep(unpackedData: var unpackedData) => Row(
          children: [
            const Text(
              "Sweep",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              "${flagMapper[unpackedData.flags]} to ${unpackedData.destination}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      _ => SelectableText(
          'Invariant: title unsupported TransactionInfo type: ${info.runtimeType}'),
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
                            style: const TextStyle(
                                color: redErrorText, fontSize: 12)),
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

  Widget _buildAssetText(String text) {
    return MiddleTruncatedText(
      text: text,
      width: 100,
      charsToShow: 8,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildAssetDisplay(String? asset, [String? assetLongname]) {
    final displayName = assetLongname != null && assetLongname.isNotEmpty
        ? assetLongname
        : asset ?? '';
    return _buildAssetText(displayName);
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
  DashboardActivityFeedBloc? _bloc;

  @override
  void initState() {
    super.initState();
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

  // Widget _buildNewTransactionsBanner(DashboardActivityFeedState state) {
  //   final newTransactionCount = (state as dynamic).newTransactionCount as int;
  //   if (newTransactionCount > 0) {
  //     return NewTransactionsBanner(count: newTransactionCount);
  //   }
  //   return const SizedBox.shrink();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardActivityFeedBloc, DashboardActivityFeedState>(
      listener: (context, state) {
        // print('DashboardActivityFeedBloc state changed: $state');
      },
      builder: (context, state) {
        final widgets = <Widget>[];

        // if (state is DashboardActivityFeedStateCompleteOk ||
        //     state is DashboardActivityFeedStateReloadingOk) {
        //   widgets.add(_buildNewTransactionsBanner(state));
        // }

        widgets.addAll(_buildContent(state));

        return SingleChildScrollView(
          child: Column(
            children: widgets,
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

      final isMobile = MediaQuery.of(context).size.width < 600;

      return filteredTransactions
          .map((transaction) => ActivityFeedListItem(
                key: ValueKey(uuid.v4()),
                item: transaction,
                addresses: widget.addresses,
                isMobile: isMobile,
              ))
          .toList();
    }

    throw Exception('Invalid state: $state');
  }
}
