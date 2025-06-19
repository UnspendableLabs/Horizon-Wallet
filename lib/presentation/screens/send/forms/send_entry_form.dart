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

class SendEntryFormActions {
  final Function(String value) onDestinationChanged;
  final Function(String value) onQuantityChanged;
  final Function(MultiAddressBalance value) onBalanceSelected;
  final Function(String value) onMemoChanged;
  final Function() onMaxAmountSelected;
  const SendEntryFormActions(
      {required this.onDestinationChanged,
      required this.onQuantityChanged,
      required this.onMemoChanged,
      required this.onMaxAmountSelected,
      required this.onBalanceSelected});
}

class SendEntryFormProvider extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final MultiAddressBalance? initialBalance;
  final Function(SendEntryFormModel) onFormChanged;
  final Widget Function(SendEntryFormActions actions, SendEntryFormModel state)
      child;
  const SendEntryFormProvider(
      {super.key,
      required this.balances,
      this.initialBalance,
      required this.onFormChanged,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendEntryFormBloc(
        initialBalance: initialBalance,
        initialQuantity: "",
        initialDestination: "",
        initialMemo: "",
      ),
      child: BlocListener<SendEntryFormBloc, SendEntryFormModel>(
        listener: (context, state) {
          onFormChanged(state);
        },
        child: BlocBuilder<SendEntryFormBloc, SendEntryFormModel>(
          builder: (context, state) => child(
            SendEntryFormActions(
              onDestinationChanged: (value) {
                context
                    .read<SendEntryFormBloc>()
                    .add(DestinationInputChanged(value));
              },
              onQuantityChanged: (value) {
                context
                    .read<SendEntryFormBloc>()
                    .add(QuantityInputChanged(value));
              },
              onMemoChanged: (value) {
                context.read<SendEntryFormBloc>().add(MemoInputChanged(value));
              },
              onMaxAmountSelected: () {
                context
                    .read<SendEntryFormBloc>()
                    .add(const MaxAmountSelected());
              },
              onBalanceSelected: (value) {
                context
                    .read<SendEntryFormBloc>()
                    .add(AddressBalanceInputChanged(value));
              },
            ),
            state,
          ),
        ),
      ),
    );
  }
}

class SendEntryForm extends StatefulWidget {
  final SendEntryFormModel state;
  final SendEntryFormActions actions;
  final List<MultiAddressBalance> balances;
  const SendEntryForm(
      {super.key,
      required this.state,
      required this.actions,
      required this.balances});

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
    return Column(
      children: [
        HorizonTextField(
          controller: _destinationController,
          label: 'Recipient Wallet Address',
          onChanged: (value) {
            widget.actions.onDestinationChanged(value);
          },
          validator: (value) {
            if (widget.state.destinationInput.isPure) {
              return null;
            }
            return switch (widget.state.destinationInput.error) {
              SendEntryFormInputError.destinationRequired =>
                'Value is required',
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
                    widget.actions
                        .onDestinationChanged(_destinationController.text);
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
            selectorPadding: widget.state.balanceSelectorInput.value == null
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
                widget.actions.onBalanceSelected(value);
              }
            },
            selectedValue: widget.state.balanceSelectorInput.value,
            selectedItemBuilder: (MultiAddressBalance item) => TokenNameField(
                  loading: false,
                  decoration: const BoxDecoration(),
                  balance: widget.state.balanceSelectorInput.value,
                  selectedBalanceEntry:
                      widget.state.balanceSelectorInput.value?.entries.first,
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _quantityController.text = quantityRemoveTrailingZeros(
                        widget.state.assetQuantityNormalized,
                      );
                      widget.actions.onMaxAmountSelected();
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
          assetIsDivisible: widget.state.assetIsDivisible,
          assetQuantityNormalized: widget.state.assetQuantityNormalized,
          controller: _quantityController,
          showMaxButton: false,
          enabled: widget.state.balanceSelectorInput.isValid,
          onChanged: (value) {
            widget.actions.onQuantityChanged(value);
          },
          validator: (value) {
            if (widget.state.quantityInput.isPure) {
              return null;
            }
            return switch (widget.state.quantityInput.error) {
              SendEntryFormInputError.quantityRequired => 'Value is required',
              SendEntryFormInputError.quantityExceedsMax => 'Value exceeds max',
              SendEntryFormInputError.quantityIsZero => 'Value is zero',
              _ => null
            };
          },
        ),
        commonHeightSizedBox,
        HorizonTextField(
            controller: _memoController,
            label: 'Description (Optional)',
            onChanged: (value) {
              widget.actions.onMemoChanged(value);
            }),
        commonHeightSizedBox,
      ],
    );
  }
}
