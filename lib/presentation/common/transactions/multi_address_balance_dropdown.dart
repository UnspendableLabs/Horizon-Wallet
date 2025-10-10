import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

import 'package:horizon/domain/entities/balance_v2.dart';

class BalanceV2Dropdown extends StatelessWidget {
  final List<BalanceV2>? balances;
  final void Function(BalanceV2?) onChanged;
  final BalanceV2? selectedValue;
  final bool loading;
  final bool useModal;
  final Widget Function(BalanceV2)? selectedItemBuilder;

  /// Map of utxoId.toString() -> listed?
  final Map<String, bool>? utxoSwapMap;

  /// Optional filter (e.g. only this asset).
  final bool Function(BalanceV2 b)? filterFn;

  final String hintText;

  const BalanceV2Dropdown({
    super.key,
    required this.balances,
    required this.onChanged,
    required this.selectedValue,
    required this.loading,
    this.useModal = true,
    this.selectedItemBuilder,
    this.utxoSwapMap,
    this.filterFn,
    this.hintText = 'Select source',
  });

  @override
  Widget build(BuildContext context) {
    if (loading || balances == null) {
      return _placeholder(context);
    }

    final items =
        (filterFn == null) ? balances! : balances!.where(filterFn!).toList();
    if (items.isEmpty) {
      return _placeholder(context, text: hintText);
    }

    return HorizonRedesignDropdown<BalanceV2>(
      useModal: useModal,
      items: items
          .map((b) => DropdownMenuItem<BalanceV2>(
                value: b,
                child: _ItemRow(b: b, utxoSwapMap: utxoSwapMap),
              ))
          .toList(),
      onChanged: onChanged,
      selectedValue: selectedValue,
      hintText: hintText,
      selectedItemBuilder: selectedItemBuilder ??
          (b) => Text(
                _labelFor(b),
                style: Theme.of(context).textTheme.bodySmall,
              ),
    );
  }

  Widget _placeholder(BuildContext context, {String? text}) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.fromBorderSide(
          Theme.of(context).inputDecorationTheme.outlineBorder ??
              const BorderSide(),
        ),
        color: Theme.of(context).brightness == Brightness.dark
            ? offBlack
            : offWhite,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(text ?? hintText,
                style: Theme.of(context).textTheme.bodySmall),
          ),
          AppIcons.caretDownIcon(context: context, width: 18, height: 18),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final BalanceV2 b;
  final Map<String, bool>? utxoSwapMap;

  const _ItemRow({required this.b, this.utxoSwapMap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = _labelFor(b);
    final qtyStr = b.quantity.normalizedPretty(); // <-- use AssetQuantity

    final chips = <Widget>[];

    if (!b.confirmed) {
      chips.add(const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Chip(
          label: Text("mempool"),
          labelStyle: TextStyle(fontSize: 8),
          padding: EdgeInsets.zero,
          backgroundColor: black,
        ),
      ));
    }

    if (b is UtxoBalance) {
      chips.add(const Padding(
        padding: EdgeInsets.only(left: 4),
        child: Chip(
          label: Text("utxo"),
          labelStyle: TextStyle(fontSize: 8),
          padding: EdgeInsets.zero,
          backgroundColor: black,
        ),
      ));
      final id = (b as UtxoBalance).utxoId.toString();
      if (utxoSwapMap != null && (utxoSwapMap![id] ?? false)) {
        chips.add(const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Chip(
            label: Text("listed"),
            labelStyle: TextStyle(fontSize: 8),
            padding: EdgeInsets.zero,
            backgroundColor: black,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              qtyStr,
              style: theme.textTheme.titleSmall!
                  .copyWith(fontWeight: FontWeight.normal),
            ),
            Row(children: chips),
          ],
        ),
      ],
    );
  }
}

String _labelFor(BalanceV2 b) {
  if (b is UtxoBalance) return b.utxoId.toString();
  return b.address;
}
