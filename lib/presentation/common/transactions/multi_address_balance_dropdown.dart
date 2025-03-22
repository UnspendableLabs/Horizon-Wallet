import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/transactions/input_loading_scaffold.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class MultiAddressBalanceDropdown extends StatelessWidget {
  final MultiAddressBalance? balances;
  final void Function(MultiAddressBalanceEntry?) onChanged;
  final MultiAddressBalanceEntry? selectedValue;

  const MultiAddressBalanceDropdown({
    super.key,
    required this.balances,
    required this.onChanged,
    required this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    if (balances == null) {
      // add scaffold to show loading
      return const InputLoadingScaffold();
    }
    return HorizonRedesignDropdown<MultiAddressBalanceEntry>(
      items: balances!.entries
          .map((addressEntry) => DropdownMenuItem<MultiAddressBalanceEntry>(
                value: addressEntry,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(addressEntry.address!,
                        style: Theme.of(context).textTheme.bodySmall),
                    Text(addressEntry.quantityNormalized,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.normal)),
                  ],
                ),
              ))
          .toList(),
      onChanged: onChanged,
      selectedValue: selectedValue,
      hintText: 'Select an address',
      selectedItemBuilder: (addressEntry) => Text(
        addressEntry.address!,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
