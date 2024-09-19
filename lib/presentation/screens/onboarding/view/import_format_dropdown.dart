import 'package:flutter/material.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dropdown_menu.dart';

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
        HorizonDropdownMenu(
          controller: TextEditingController(),
          onChanged: (String? value) {
            if (value != null) {
              onChanged(value);
            }
          },
          selectedValue: selectedFormat,
          items: [
            buildDropdownMenuItem(
                ImportFormat.horizon.name, ImportFormat.horizon.description),
            buildDropdownMenuItem(
              ImportFormat.freewallet.name,
              ImportFormat.freewallet.description,
            ),
            buildDropdownMenuItem(
              ImportFormat.counterwallet.name,
              ImportFormat.counterwallet.description,
            ),
          ],
        ),
      ],
    );
  }
}
