import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import './bloc/asset_balance_form_bloc.dart';

class AssetBalanceFormActions {
  final Function(AssetBalanceFormOption value) onBalanceSelected;
  final VoidCallback onSubmitClicked;

  AssetBalanceFormActions({
    required this.onBalanceSelected,
    required this.onSubmitClicked,
  });
}

class AssetBalanceFormProvider extends StatelessWidget {
  final MultiAddressBalance multiAddressBalance;

  final Widget Function(
      AssetBalanceFormActions actions, AssetBalanceFormModel state) child;

  const AssetBalanceFormProvider({
    super.key,
    required this.child,
    required this.multiAddressBalance,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return AssetBalanceFormBloc(multiAddressBalance: multiAddressBalance);
    }, child: BlocBuilder<AssetBalanceFormBloc, AssetBalanceFormModel>(
      builder: (context, state) {
        return child(
          AssetBalanceFormActions(
            onBalanceSelected: (value) {
              context.read<AssetBalanceFormBloc>().add(
                    AssetBalanceSelected(option: value),
                  );
            },
            onSubmitClicked: () {
              context.read<AssetBalanceFormBloc>().add(const SubmitClicked());
            },
          ),
          state,
        );
      },
    ));
  }
}

class AssetBalanceSuccessHandler extends StatelessWidget {
  final Function(AtomicSwapSellVariant option) onSuccess;

  const AssetBalanceSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<AssetBalanceFormBloc, AssetBalanceFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            state.atomicSwapSellVariant.fold(
              (_) => throw Exception("invariant"),
              (value) => onSuccess(value),
            );
          }
        },
        child: const SizedBox.shrink());
  }
}

class AssetBalanceForm extends StatelessWidget {
  final AssetBalanceFormModel state;
  final AssetBalanceFormActions actions;

  const AssetBalanceForm(
      {required this.state, required this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(children: [
      Text("Choose the source of your funds",
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w400,
              )),
      commonHeightSizedBox,
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: MultiAddressBalanceDropdown(
              balances: state.multiAddressBalance,
              selectedItemBuilder: (entry) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${entry.quantityNormalized} ${state.multiAddressBalance.asset}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()
                              ?.mutedDescriptionTextColor,
                        ),
                      ),
                      Text(
                        // TODO: i don't love this, period
                        entry.address ?? entry.utxo!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme
                              .extension<CustomThemeExtension>()
                              ?.offColorText,
                        ),
                      ),
                    ],
                  ),
              onChanged: (value) {
                actions.onBalanceSelected(
                  AssetBalanceFormOption(
                    entry: value!,
                  ),
                );
              },
              selectedValue: state.balanceInput.value?.entry,
              loading: false)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: HorizonButton(
            disabled: state.isNotValid,
            variant: ButtonVariant.green,
            onPressed: () {
              actions.onSubmitClicked();
            },
            child: TextButtonContent(
              value: "Continue",
            )),
      )
    ]);
  }
}
