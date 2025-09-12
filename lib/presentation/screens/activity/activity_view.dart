import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/dashboard/view/activity_feed.dart';
import 'package:fpdart/fpdart.dart' hide State;

import 'package:horizon/domain/entities/activity_feed_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/remote_data.dart';

import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import "package:get_it/get_it.dart";
import 'package:horizon/presentation/common/filter_bar.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/domain/entities/address_index_set.dart';
import 'package:horizon/domain/entities/address_v2.dart';

import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import './btc/btc_view.dart';

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
/// BTC activity (uses the builder)
/// -----------------------------

/// -----------------------------
/// ACTIVITY VIEW (single scroll view)
/// -----------------------------
class ActivityView extends StatefulWidget {
  final AddressV2 initialAddress;

  const ActivityView({super.key, required this.initialAddress});

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  late AddressV2 _selectedAddress;
  TransactionType _txFilter = TransactionType.btc;

  @override
  void initState() {
    _selectedAddress = widget.initialAddress;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    final vm = session.addressIndexSet.toViewModel();
    return CustomScrollView(
      slivers: [
        // Address picker
        switch (vm) {
          AddressIndexSetSingle() =>
            const SliverToBoxAdapter(child: SizedBox.shrink()),
          AddressIndexSetMultiple(addresses: final addresses) =>
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: HorizonDrawerSelect<AddressV2>(
                  options: addresses,
                  value: _selectedAddress!,
                  labelFor: (addr) => addr.address,
                  onChanged: (addr) => setState(() => _selectedAddress = addr),
                ),
              ),
            ),
        },

        // Tx type filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 180,
              child: TransactionTypeFilter(
                itemGap: 18,
                current: _txFilter,
                onChanged: (t) {
                  if (t != null) setState(() => _txFilter = t);
                },
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        if (_selectedAddress == null)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No address available.'),
            ),
          )
        else if (_txFilter == TransactionType.btc)
          SliverToBoxAdapter(
            child: BTCActivityProvider(
              httpConfig: session.httpConfig,
              address: _selectedAddress!,
              builder: (actions) => BTCActivityView(address: _selectedAddress!),
            ),
          )
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'XCP activity for ${_selectedAddress!.address}',
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}
