import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';

class MultiAddressBalanceEntryFilter {
  bool Function(MultiAddressBalanceEntry entry) filterFn;
  MultiAddressBalanceEntryFilter({required this.filterFn});
}

class MultiAddressBalanceDropdown extends StatelessWidget {
  final MultiAddressBalance? balances;
  final void Function(MultiAddressBalanceEntry?) onChanged;
  final MultiAddressBalanceEntry? selectedValue;
  final bool loading;
  final bool useModal;
  final Widget Function(MultiAddressBalanceEntry)? selectedItemBuilder;
  final Map<String, bool>? utxoSwapMap;

  const MultiAddressBalanceDropdown({
    super.key,
    this.utxoSwapMap,
    required this.balances,
    required this.onChanged,
    required this.selectedValue,
    required this.loading,
    this.useModal = true,
    this.selectedItemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (loading || balances == null) {
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Select source address',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            AppIcons.caretDownIcon(
              context: context,
              width: 18,
              height: 18,
            ),
          ],
        ),
      );
    }

    return HorizonRedesignDropdown<MultiAddressBalanceEntry>(
      useModal: useModal,
      items: balances!.entries
          .map((addressEntry) => DropdownMenuItem<MultiAddressBalanceEntry>(
                value: addressEntry,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addressEntry.address ?? addressEntry.utxo!,
                        style: Theme.of(context).textTheme.bodySmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(addressEntry.quantityNormalized,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.normal)),
                        utxoSwapMap != null &&
                                addressEntry.utxo != null &&
                                utxoSwapMap!.containsKey(addressEntry.utxo!) &&
                                utxoSwapMap![addressEntry.utxo!] == true
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: red2, width: 1)),
                                child: const Text("Listed",
                                    style: TextStyle(color: red1)))
                            : const SizedBox.shrink()
                      ],
                    ),

                    // utxoSwapMap.fold3(
                    //      onNone: () => const Text("none"),
                    //      onFailure: (_) => const Text("failuire"),
                    //      onReplete: (utxoSwapMap) {
                    //        return entry.utxo != null &&
                    //                utxoSwapMap.containsKey(entry.utxo!) &&
                    //                utxoSwapMap[entry.utxo!] == true
                    //            ? const Text("Swap exists")
                    //            : const Text("huh");
                    //      })
                  ],
                ),
              ))
          .toList(),
      onChanged: onChanged,
      selectedValue: selectedValue,
      hintText: 'Select source address',
      selectedItemBuilder: selectedItemBuilder ??
          (addressEntry) => Text(
                addressEntry.address!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
    );
  }
}
