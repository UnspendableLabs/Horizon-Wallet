import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/balance_v2.dart';

import 'package:formz/formz.dart';
import "package:fpdart/fpdart.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/common/theme_extension.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';

class AssetBalanceFormActions {
  final Function(AssetBalanceFormOption value) onBalanceSelected;
  final VoidCallback onSubmitClicked;

  AssetBalanceFormActions({
    required this.onBalanceSelected,
    required this.onSubmitClicked,
  });
}

class AssetBalanceFormProvider extends StatelessWidget {
  final List<String> addresses;
  final HttpConfig httpConfig;
  final List<DisallowSelection> disallowSelections;

  final AssetBalanceSummary assetBalanceSummary;
  // final AssetBalanceSummary assetBalanceSummary;

  final Widget Function(
      AssetBalanceFormActions actions, AssetBalanceFormModel state) child;

  const AssetBalanceFormProvider({
    super.key,
    required this.httpConfig,
    required this.addresses,
    required this.child,
    required this.assetBalanceSummary,
    required this.disallowSelections,
    // required this.assetBalanceSummary,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) {
      return AssetBalanceFormBloc(
          disallowSelections: disallowSelections,
          addresses: addresses,
          httpConfig: httpConfig,
          assetBalanceSummary: assetBalanceSummary);
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

class SendFormBalanceSuccessHandler extends StatelessWidget {
  final Function(String) onSuccess;
  const SendFormBalanceSuccessHandler({super.key, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetBalanceFormBloc, AssetBalanceFormModel>(
      listener: (context, state) {
        if (state.submissionStatus.isSuccess &&
            state.balanceInput.value?.entry.address != null) {
          onSuccess(state.balanceInput.value!.entry.address);
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class AssetBalanceSuccessHandler<T> extends StatelessWidget {
  final Either<String, T> Function(AssetBalanceFormModel state) mapSuccess;
  final Function(T option) onSuccess;

  const AssetBalanceSuccessHandler(
      {super.key, required this.mapSuccess, required this.onSuccess});

  @override
  Widget build(context) {
    return BlocListener<AssetBalanceFormBloc, AssetBalanceFormModel>(
        listener: (context, state) {
          if (state.submissionStatus.isSuccess) {
            mapSuccess(state)
                .fold((_) => throw ("invariant"), (t) => onSuccess(t));
          }
        },
        child: const SizedBox.shrink());
  }
}

class AssetBalanceForm extends StatelessWidget {
  final AssetBalanceFormModel state;
  final AssetBalanceFormActions actions;
  final Widget Function(UtxoID utxoID) balanceIsUTXOError;

  const AssetBalanceForm(
      {this.balanceIsUTXOError = _defaultBalanceIsUTXOError,
      required this.state,
      required this.actions,
      super.key});

  static Widget _defaultBalanceIsUTXOError(UtxoID utxoID) {
    return const Text("Cannot use UTX asset");
  }

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
          child: state.utxoSwapMap.fold3(
              onNone: () => BalanceV2Dropdown(
                  utxoSwapMap: {},
                  balances: null,
                  selectedItemBuilder: (entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${entry.quantity.normalized()} ${state.assetBalanceSummary.asset}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme
                                  .extension<CustomThemeExtension>()
                                  ?.mutedDescriptionTextColor,
                            ),
                          ),
                          switch (entry) {
                            UtxoBalance(utxoId: var utxoId) => Text(
                                utxoId.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme
                                      .extension<CustomThemeExtension>()
                                      ?.offColorText,
                                ),
                              ),
                            AddressBalance(address: var address) => Text(
                                address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme
                                      .extension<CustomThemeExtension>()
                                      ?.offColorText,
                                ),
                              ),
                          }
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
                  loading: true),
              onFailure: (_) => const Text("Failed to load UTXO swaps"),
              onReplete: (utxoSwapMap) => BalanceV2Dropdown(
                  utxoSwapMap: utxoSwapMap,
                  balances: state.assetBalanceSummary.balances,
                  selectedItemBuilder: (entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${entry.quantity.normalizedPretty()} ${state.assetBalanceSummary.asset}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme
                                  .extension<CustomThemeExtension>()
                                  ?.mutedDescriptionTextColor,
                            ),
                          ),
                          switch (entry) {
                            UtxoBalance(utxoId: var utxoId) => Text(
                                utxoId.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme
                                      .extension<CustomThemeExtension>()
                                      ?.offColorText,
                                ),
                              ),
                            AddressBalance(address: var address) => Text(
                                address,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  color: theme
                                      .extension<CustomThemeExtension>()
                                      ?.offColorText,
                                ),
                              ),
                          }
                          // Text(
                          //   // TODO: i don't love this, period
                          //   entry.address ?? entry.utxo!,
                          //   style: theme.textTheme.bodySmall?.copyWith(
                          //     fontSize: 10,
                          //     color: theme
                          //         .extension<CustomThemeExtension>()
                          //         ?.offColorText,
                          //   ),
                          // ),
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
                  loading: false))),
      coalescedError(state),
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

  Widget coalescedError(AssetBalanceFormModel state) {
    if (state.disallowSelections.contains(DisallowSelection.listingExists) &&
        state.swapExistsInput.error is UtxoSwapInputErrorListed) {
      return const Text("Listing exists", style: TextStyle(color: red1));
    } else if (state.disallowSelections
            .contains(DisallowSelection.balanceIsUtxo) &&
        state.assetIsUtxoInput.error == AssetIsUtxoInputError.isUtxo) {
      return balanceIsUTXOError(UtxoID.fromString(
          (state.balanceInput.value!.entry as UtxoBalance).utxoId.toString()));
    } else {
      return const SizedBox.shrink();
    }
  }
}
