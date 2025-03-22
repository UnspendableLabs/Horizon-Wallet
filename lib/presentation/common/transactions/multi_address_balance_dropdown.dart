import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';

class MultiAddressBalanceDropdown extends StatelessWidget {
  final MultiAddressBalance? balances;
  final void Function(MultiAddressBalance?) onChanged;
  final MultiAddressBalance? selectedValue;

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
      return const SizedBox.shrink();
    }
    return HorizonRedesignDropdown<MultiAddressBalance>(
      items: balances!.entries
          .map((addressEntry) => DropdownMenuItem<MultiAddressBalance>(
                value: selectedValue,
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
    );
  }
}
