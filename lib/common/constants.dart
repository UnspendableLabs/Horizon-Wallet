import 'package:flutter/services.dart';

enum ImportFormat {
  horizon("Horizon", "Horizon Native"),
  // legacy("Legacy", "BIP44,P2PKH,Base58"),
  freewallet("Freewallet", "Freewallet (BIP39)"),

  counterwallet("Counterwallet", "Freewallet / Counterwallet");

  const ImportFormat(this.name, this.description);
  final String name;
  final String description;
}

enum IssuanceActionType {
  reset,
  lockDescription,
  lockQuantity,
  changeDescription,
  issueMore,
  issueSubasset,
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only allow digits and at most one decimal point
    final RegExp regExp = RegExp(r'^\d*\.?\d*$');
    if (!regExp.hasMatch(newValue.text)) {
      return oldValue;
    }

    String newText = newValue.text;
    TextSelection newSelection = newValue.selection;

    // Check if the new value has more than one decimal point
    if (newText.split('.').length > 2) {
      return oldValue; // Return the old value if there's more than one decimal point
    }

    if (newText.contains('.')) {
      String decimalPart = newText.substring(newText.indexOf('.') + 1);
      if (decimalPart.length > decimalRange) {
        newText = newText.substring(0, newText.indexOf('.') + decimalRange + 1);
        newSelection = TextSelection.collapsed(offset: newText.length);
      }
    }

    return TextEditingValue(
      text: newText,
      selection: newSelection,
    );
  }
}
