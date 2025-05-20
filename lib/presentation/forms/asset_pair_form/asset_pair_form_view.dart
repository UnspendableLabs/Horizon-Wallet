import 'package:horizon/domain/entities/multi_address_balance_entry.dart';

import "./bloc/loader/loader_bloc.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import 'package:horizon/presentation/common/redesign_colors.dart';
import "package:horizon/presentation/forms/base/base_form_state.dart";
export "package:horizon/presentation/forms/base/base_form_state.dart";
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/asset_balance_list_item.dart';
import 'package:horizon/utils/app_icons.dart';

import "./bloc/form/asset_pair_form_bloc.dart";

class AssetPairLoader extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;
  final Widget Function(BaseFormState<SwapFormLoaderData>) child;

  const AssetPairLoader({
    super.key,
    required this.httpConfig,
    required this.addresses,
    required this.child,
  });
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SwapFormLoaderBloc(
        loader: SwapFormLoaderFn(),
      )..load(SwapFormLoaderArgs(
          httpConfig: httpConfig,
          addresses: addresses,
        )),
      child: Builder(builder: (context) {
        return BlocBuilder<SwapFormLoaderBloc,
            BaseFormState<SwapFormLoaderData>>(builder: (context, state) {
          return child(state);
        });
      }),
    );
  }
}

class AssetPairFormActions {
  final Function(MultiAddressBalance multiAddressBalance) onGiveAssetChanged;

  const AssetPairFormActions({required this.onGiveAssetChanged});
}

class AssetPairFormProvider extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final MultiAddressBalance? initialMultiAddressBalanceEntry;
  final Widget Function(AssetPairFormActions actions, AssetPairFormModel state)
      child;

  const AssetPairFormProvider(
      {required this.child,
      required this.balances,
      required this.initialMultiAddressBalanceEntry,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AssetPairFormBloc(
            initialGiveAssets: balances,
            initialMultiAddressBalanceEntry: initialMultiAddressBalanceEntry),
        child: BlocBuilder<AssetPairFormBloc, AssetPairFormModel>(
            builder: (context, state) {
          return child(
              AssetPairFormActions(
                onGiveAssetChanged: (MultiAddressBalance value) => context
                    .read<AssetPairFormBloc>()
                    .add(GiveAssetChanged(value: value)),
              ),
              state);
        }));
  }
}

class AssetPairForm extends StatelessWidget {
  final List<MultiAddressBalance> giveAssets;
  final GiveAssetInput giveAssetInput;
  final Function(MultiAddressBalance multiAddressBalance)? onGiveAssetChanged;

  const AssetPairForm(
      {required this.giveAssets,
      required this.giveAssetInput,
      this.onGiveAssetChanged,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    HorizonRedesignDropdown<MultiAddressBalance>(
                        itemPadding: const EdgeInsets.all(12),
                        items: giveAssets
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: AssetBalanceListItem(balance: e)))
                            .toList(),
                        onChanged: (value) {
                          if (onGiveAssetChanged != null && value != null) {
                            onGiveAssetChanged!(value);
                          }
                        },
                        selectedValue: giveAssetInput.value,
                        selectedItemBuilder: (MultiAddressBalance item) =>
                            AssetBalanceListItem(balance: item),
                        hintText: "Select Token"),
                    commonHeightSizedBox,
                    HorizonRedesignDropdown<MultiAddressBalance>(
                        itemPadding: const EdgeInsets.all(12),
                        items: [],
                        onChanged: (value) {},
                        selectedValue: null,
                        selectedItemBuilder: (MultiAddressBalance item) =>
                            AssetBalanceListItem(balance: item),
                        hintText: "Select Token")
                  ],
                ),
                Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          hoverColor: transparentPurple8,
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            // setState(() {
                            //   if (_fromToken == null || _toToken == null) {
                            //     return;
                            //   }
                            //   final temp = _fromToken;
                            //   _fromToken = _toToken;
                            //   _toToken = temp;
                            // });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: transparentWhite8, width: 1),
                            ),
                            padding: const EdgeInsets.all(10),
                            child: AppIcons.arrowDownIcon(
                                context: context, width: 24, height: 24),
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          HorizonButton(
              onPressed: () {},
              child: TextButtonContent(value: "Create Listing"),
              variant: ButtonVariant.green)
        ],
      ),
    );
  }
}
