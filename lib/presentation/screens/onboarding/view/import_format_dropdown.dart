import 'package:flutter/material.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

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
                ImportFormat.horizon.name, ImportFormat.horizon.description),
            HorizonUI.buildDropdownMenuItem(
              ImportFormat.counterwallet.name,
              ImportFormat.counterwallet.description,
            ),
            HorizonUI.buildDropdownMenuItem(
              ImportFormat.freewallet.name,
              ImportFormat.freewallet.description,
            ),
          ],
        ),
      ],
    );
  }
}
