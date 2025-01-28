import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

enum WalletType {
  horizon("Horizon", "Horizon Native"),
  bip32("BIP32", "Freewallet / Counterwallet / Rare Pepe Wallet");

  const WalletType(this.name, this.description);
  final String name;
  final String description;
}

class ImportFormatDropdown extends StatelessWidget {
  final Function(String) onChanged;
  final String selectedFormat;
  const ImportFormatDropdown(
      {super.key, required this.onChanged, required this.selectedFormat});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SelectableText('Wallet Type'),
        ),
        HorizonUI.HorizonDropdownMenu(
          controller: TextEditingController(),
          onChanged: (String? value) {
            if (value != null) {
              onChanged(value);
            }
          },
          selectedValue: selectedFormat,
          items: [
            HorizonUI.buildDropdownMenuItem(
                WalletType.horizon.name, WalletType.horizon.description),
            HorizonUI.buildDropdownMenuItem(
              WalletType.bip32.name,
              WalletType.bip32.description,
            ),
          ],
        ),
      ],
    );
  }
}
