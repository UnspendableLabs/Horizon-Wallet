import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class AssetDropdownLoading extends StatelessWidget {
  const AssetDropdownLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      DropdownMenu(
        expandedInsets: const EdgeInsets.all(0),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        initialSelection: "",
        label: const Text('Asset'),
        dropdownMenuEntries:
            [const DropdownMenuEntry<String>(value: "", label: "")].toList(),
        menuStyle: MenuStyle(
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 8.0),
          ),
        ),
      ),
      const Positioned(
        left: 12,
        top: 0,
        bottom: 0,
        child: Center(
          child: SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ]);
  }
}

class AssetDropdown extends StatefulWidget {
  final String? asset;
  final List<Balance> balances;
  final TextEditingController controller;
  final void Function(String?) onSelected;
  final bool loading;

  const AssetDropdown(
      {super.key,
      this.asset,
      required this.balances,
      required this.controller,
      required this.onSelected,
      required this.loading});

  @override
  State<AssetDropdown> createState() => _AssetDropdownState();
}

class _AssetDropdownState extends State<AssetDropdown> {
  late List<Balance> orderedBalances;

  @override
  void initState() {
    super.initState();
    orderedBalances = _orderBalances(widget.balances);
  }

  List<Balance> _orderBalances(List<Balance> balances) {
    final Balance? btcBalance =
        balances.where((b) => b.asset == 'BTC').firstOrNull;

    final Balance? xcpBalance =
        balances.where((b) => b.asset == 'XCP').firstOrNull;

    final otherBalances =
        balances.where((b) => b.asset != 'BTC' && b.asset != 'XCP').toList();

    return [
      if (btcBalance != null) btcBalance,
      if (xcpBalance != null) xcpBalance,
      ...otherBalances,
    ];
  }

  String _getDisplayString(String? asset) {
    if (asset == null) return orderedBalances[0].asset;
    final balance = orderedBalances.firstWhere((b) => b.asset == asset);
    return displayAssetName(balance.asset, balance.assetInfo.assetLongname);
  }

  String _getSelectedValue() {
    if (widget.asset == null) return orderedBalances[0].asset;
    return widget.asset!;
  }

  @override
  Widget build(BuildContext context) {
    return HorizonUI.HorizonDropdownMenu<String>(
      enabled: !widget.loading,
      controller: widget.controller,
      label: 'Asset',
      onChanged: widget.onSelected,
      selectedValue: _getSelectedValue(),
      items: orderedBalances.map<DropdownMenuItem<String>>((balance) {
        return HorizonUI.buildDropdownMenuItem(
          balance.asset,
          _getDisplayString(balance.asset),
        );
      }).toList(),
      displayStringForOption: _getDisplayString,
    );
  }
}
