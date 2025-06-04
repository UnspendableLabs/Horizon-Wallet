import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/common/asset_balance_list_item.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/utils/app_icons.dart';

class SendEntryForm extends StatefulWidget {
  final List<MultiAddressBalance> balances;
  final Function(SendEntryFormModel) onFormChanged;
  const SendEntryForm(
      {super.key, required this.balances, required this.onFormChanged});

  @override
  State<SendEntryForm> createState() => _SendEntryFormState();
}

class _SendEntryFormState extends State<SendEntryForm> {
  late TextEditingController _destinationController;
  late TextEditingController _quantityController;
  late TextEditingController _memoController;
  @override
  void initState() {
    super.initState();
    _destinationController = TextEditingController();
    _quantityController = TextEditingController();
    _memoController = TextEditingController();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _quantityController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return BlocConsumer<SendEntryFormBloc, SendEntryFormModel>(
      listener: (context, state) {
        widget.onFormChanged(state);
      },
      builder: (context, state) => Column(
        children: [
          HorizonTextField(
            controller: _destinationController,
            label: 'Recipient Wallet Address',
            onChanged: (value) {
              context
                  .read<SendEntryFormBloc>()
                  .add(DestinationInputChanged(value));
            },
            validator: (value) {
              if (state.destinationInput.isPure) {
                return null;
              }
              return switch (state.destinationInput.error) {
                SendEntryFormInputError.destinationRequired => 'Value is required',
                _ => null
              };
            },
            suffixIcon: SizedBox(
              height: 32,
              width: 86,
              child: HorizonButton(
                borderRadius: 12,
                variant: ButtonVariant.purple,
                onPressed: () {
                  Clipboard.getData(Clipboard.kTextPlain).then((value) {
                    if (value?.text != null && value!.text!.trim().isNotEmpty) {
                      _destinationController.text = value.text!;
                      context.read<SendEntryFormBloc>().add(
                          DestinationInputChanged(_destinationController.text));
                    }
                  });
                },
                icon: AppIcons.pasteIcon(
                  context: context,
                  width: 24,
                  height: 24,
                ),
                child: TextButtonContent(
                    value: "Paste",
                    style: theme.textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
          ),
          commonHeightSizedBox,
          HorizonRedesignDropdown<MultiAddressBalance>(
              itemPadding: const EdgeInsets.all(12),
              selectorPadding: state.balanceSelectorInput.value == null
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                  : const EdgeInsets.only(right: 10),
              items: widget.balances
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: AssetBalanceListItemWithOptionalBalance(
                            asset: item.asset,
                            description: item.assetInfo.description,
                            balance: fp.Option.of(item)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<SendEntryFormBloc>()
                      .add(AddressBalanceInputChanged(value));
                  _quantityController.text = "";
                  context.read<SendEntryFormBloc>().add(
                      QuantityInputChanged(_quantityController.text));
                }
              },
              selectedValue: state.balanceSelectorInput.value,
              selectedItemBuilder: (MultiAddressBalance item) => TokenNameField(
                    loading: false,
                    decoration: const BoxDecoration(),
                    balance: state.balanceSelectorInput.value,
                    selectedBalanceEntry:
                        state.balanceSelectorInput.value?.entries?.first,
                    suffixIcon: GestureDetector(
                      onTap: () {
                        _quantityController.text = quantityRemoveTrailingZeros(
                          state.assetQuantityNormalized,
                        );
                        context.read<SendEntryFormBloc>().add(
                            QuantityInputChanged(_quantityController.text));
                      },
                      child: Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? transparentYellow8
                              : transparentPurple33,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Max',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                              color: isDarkMode ? yellow1 : duskGradient2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              hintText: "Select Token"),
          commonHeightSizedBox,
          GradientQuantityInputV2(
            assetIsDivisible: state.assetIsDivisible,
            assetQuantityNormalized: state.assetQuantityNormalized,
            controller: _quantityController,
            showMaxButton: false,
            onChanged: (value) {
              context
                  .read<SendEntryFormBloc>()
                  .add(QuantityInputChanged(value));
            },
            validator: (value) {
              if (state.quantityInput.isPure) {
                return null;
              }
              return switch (state.quantityInput.error) {
                SendEntryFormInputError.quantityRequired => 'Value is required',
                SendEntryFormInputError.invalidQuantity => 'Invalid value',
                _ => null
              };
            },
          ),
          commonHeightSizedBox,
          HorizonTextField(controller: _memoController, label: 'Description (Optional)', onChanged: (value) {
            context.read<SendEntryFormBloc>().add(MemoInputChanged(value));
          }),
          commonHeightSizedBox,
        ],
      ),
    );
  }
}
