import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

/// -----------------------------
/// TX TYPE FILTER (FilterBar skin)
/// -----------------------------
enum TransactionType { btc, xcp }

extension TxTypeLabel on TransactionType {
  String get label => switch (this) {
        TransactionType.btc => 'BTC',
        TransactionType.xcp => 'XCP',
      };
}

class TransactionTypeFilter extends StatelessWidget {
  const TransactionTypeFilter({
    super.key,
    required this.current,
    required this.onChanged,
    this.allowDeselect = false,
    this.disabled = const <TransactionType>{},
    this.paddingHorizontal,
    this.itemGap,
  });

  final TransactionType current;
  final ValueChanged<TransactionType?> onChanged;
  final bool allowDeselect;
  final Set<TransactionType> disabled;
  final double? paddingHorizontal;
  final double? itemGap;

  @override
  Widget build(BuildContext context) {
    return FilterBar(
      currentFilter: current,
      allowDeselect: allowDeselect,
      paddingHorizontal: paddingHorizontal,
      itemGap: itemGap,
      disabledOptions: disabled.toList(),
      filterOptions: const [
        FilterOption(label: 'BTC', value: TransactionType.btc),
        FilterOption(label: 'XCP', value: TransactionType.xcp),
      ],
      onFilterSelected: (obj) => onChanged(obj as TransactionType),
      onClearFilter: () => onChanged(null),
    );
  }
}

/// -----------------------------
/// ACTIVITY VIEW (single scroll view)
/// -----------------------------
class ActivityView extends StatefulWidget {
  const ActivityView({super.key});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  AddressV2? _selectedAddress;
  TransactionType _txFilter = TransactionType.btc;

  void _syncSelectedAddress(AddressIndexSetViewModel vm) {
    switch (vm) {
      case AddressIndexSetSingle(address: final a):
        // Always lock to the single address in this mode.
        _selectedAddress = a;
      case AddressIndexSetMultiple(addresses: final list):
        // If nothing selected or current is no longer present, pick first.
        if (_selectedAddress == null || !list.contains(_selectedAddress)) {
          _selectedAddress = list.isNotEmpty ? list.first : null;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final AddressIndexSetViewModel viewModel =
        session.addressIndexSet.toViewModel();

    // keep selection consistent with the incoming model
    _syncSelectedAddress(viewModel);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ADDRESS PICKER (only when multiple)
          switch (viewModel) {
            AddressIndexSetSingle() => const SizedBox.shrink(),
            AddressIndexSetMultiple(addresses: final addresses) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: HorizonDrawerSelect<AddressV2>(
                  options: addresses,
                  value: _selectedAddress!,
                  labelFor: (addr) => addr.address,
                  onChanged: (addr) {
                    setState(() => _selectedAddress = addr);
                  },
                ),
              ),
          },

          // TRANSACTION TYPE FILTER (BTC / XCP)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 180, // keeps pills compact; adjust as you like
              child: TransactionTypeFilter(
                itemGap: 18,
                current: _txFilter,
                allowDeselect: false, // set true if you want a "none" state
                onChanged: (t) {
                  if (t != null) {
                    setState(() => _txFilter = t);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // CONTENT: render both lists as needed
          if (_selectedAddress != null) ...[
            if (_txFilter == TransactionType.btc)
              _BtcActivityList(address: _selectedAddress!)
            else
              _XcpActivityList(address: _selectedAddress!),
          ] else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No address available.'),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// -----------------------------
/// Stubs for your BTC/XCP activity widgets
/// Replace with your real list views.
/// -----------------------------
class _BtcActivityList extends StatelessWidget {
  const _BtcActivityList({required this.address});
  final AddressV2 address;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with BTC tx list for [address]
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('BTC activity for ${address.address}'),
    );
  }
}

class _XcpActivityList extends StatelessWidget {
  const _XcpActivityList({required this.address});
  final AddressV2 address;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with XCP tx list for [address]
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text('XCP activity for ${address.address}'),
    );
  }
}
