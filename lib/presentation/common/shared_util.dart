import 'package:flutter/services.dart';
import 'package:horizon/domain/entities/account.dart';

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

String displayAssetName(String? assetName, String? assetLongname) {
  return assetLongname != '' && assetLongname != null
      ? assetLongname
      : assetName!;
}

Account getHighestIndexAccount(List<Account> accounts) {
  if (accounts.isEmpty) {
    throw Exception("invariant: no accounts found");
  }

  Account highestAccount = accounts.first;
  int maxIndex = int.parse(highestAccount.accountIndex.replaceAll("'", ""));

  for (var account in accounts) {
    int currentIndex = int.parse(account.accountIndex.replaceAll("'", ""));
    if (currentIndex > maxIndex) {
      maxIndex = currentIndex;
      highestAccount = account;
    }
  }

  return highestAccount;
}

bool addressIsSegwit(String sourceAddress) {
  return sourceAddress.startsWith("bc") || sourceAddress.startsWith("tb");
}

String quantityRemoveTrailingZeros(String quantity) {
  return quantity
      .replaceAll(RegExp(r'(?<=\d)0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
}
