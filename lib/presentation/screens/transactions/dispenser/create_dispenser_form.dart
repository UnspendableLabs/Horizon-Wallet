import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/utils/app_icons.dart';

class CreateDispenserForm {
  // Creates a form for the dispenser creation screens
  // Returns a Form widget that can be used directly in the transaction form
  static Form create({
    required BuildContext context,
    required bool loading,
    required dynamic balances,
    required dynamic btcBalances,
    required MultiAddressBalanceEntry? selectedBalanceEntry,
    required MultiAddressBalanceEntry? selectedBtcBalanceEntry,
    required TextEditingController giveQuantityController,
    required TextEditingController escrowQuantityController,
    required TextEditingController pricePerUnitController,
    required Function(MultiAddressBalanceEntry?) onBalanceChanged,
    required GlobalKey<FormState> formKey,
    List<Dispenser>? openDispensers,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: formKey,
      child: Column(
        children: [
          MultiAddressBalanceDropdown(
            loading: loading,
            balances: balances,
            onChanged: onBalanceChanged,
            selectedValue: selectedBalanceEntry,
          ),
          commonHeightSizedBox,
          if (openDispensers != null && openDispensers.isNotEmpty)
            Row(
              children: [
                AppIcons.warningIcon(
                  color: isDark ? yellow1 : duskGradient2,
                ),
                const SizedBox(width: 4),
                SelectableText('Address has open dispensers',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: isDark ? yellow1 : duskGradient2)),
              ],
            ),
          commonHeightSizedBox,
          TokenNameField(
            loading: loading,
            balance: balances,
            selectedBalanceEntry: selectedBalanceEntry,
          ),
          commonHeightSizedBox,
          GradientQuantityInput(
            enabled: !loading,
            showMaxButton: false,
            balance: balances,
            selectedBalanceEntry: selectedBalanceEntry,
            controller: giveQuantityController,
            label: 'Give Quantity',
            validator: (value) {
              if (value == null || value.isEmpty || value == '.') {
                return 'Please enter a Quantity';
              }
              Decimal input = Decimal.parse(value);
              Decimal max = Decimal.parse(
                  selectedBalanceEntry?.quantityNormalized ?? '0');
              if (input > max) {
                return "Quantity exceeds available balance";
              }
              return null;
            },
          ),
          commonHeightSizedBox,
          GradientQuantityInput(
            enabled: !loading,
            showMaxButton: true,
            balance: balances,
            selectedBalanceEntry: selectedBalanceEntry,
            controller: escrowQuantityController,
            label: 'Escrow Quantity',
            validator: (value) {
              if (value == null || value.isEmpty || value == '.') {
                return 'Please enter an Escrow Quantity';
              }
              Decimal escrowQuantity = Decimal.parse(value);
              Decimal max = Decimal.parse(
                  selectedBalanceEntry?.quantityNormalized ?? '0');
              if (escrowQuantity > max) {
                return "Escrow Quantity exceeds available balance";
              }

              Decimal? giveQuantity = (giveQuantityController.text.isNotEmpty &&
                      giveQuantityController.text != '.')
                  ? Decimal.parse(giveQuantityController.text)
                  : null;
              // Check if the escrow quantity is greater than or equal to the give quantity

              if (giveQuantity != null && escrowQuantity < giveQuantity) {
                return 'Escrow Quantity must be >= to Quantity';
              }
              if (giveQuantity != null &&
                  escrowQuantity % giveQuantity != Decimal.zero) {
                return 'Escrow must be a multiple of Quantity';
              }
              return null;
            },
          ),
          commonHeightSizedBox,
          GradientQuantityInput(
            enabled: !loading || giveQuantityController.text.isNotEmpty,
            showMaxButton: false,
            balance: btcBalances,
            controller: pricePerUnitController,
            label: 'Price per Unit (BTC)',
            emptySelectedBalanceEntryAllowed: true,
            validator: (value) {
              if (value == null || value.isEmpty || value == '.') {
                return 'Per Unit Price is required';
              }

              try {
                final pricePerUnit = Decimal.parse(value);
                final giveQuantity = Decimal.parse(giveQuantityController.text);

                // Calculate total price in BTC
                final totalPriceBtc = pricePerUnit * giveQuantity;

                // Convert to satoshis (1 BTC = 100,000,000 satoshis)
                final totalPriceSatoshis =
                    (totalPriceBtc * Decimal.fromInt(100000000))
                        .toBigInt()
                        .toInt();

                if (totalPriceSatoshis < 546) {
                  return 'Error: total price < dust limit';
                }
              } catch (e) {
                return 'Invalid price format';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }
}
