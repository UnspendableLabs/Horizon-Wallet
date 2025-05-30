import "./bloc/loader/loader_bloc.dart";
import 'package:formz/formz.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:flutter/material.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/asset_balance_list_item.dart';
import 'package:horizon/utils/app_icons.dart';

import "./bloc/form/asset_pair_form_bloc.dart";
import './view/show_receive_asset_modal.dart';

class AssetPairLoader extends StatelessWidget {
  final HttpConfig httpConfig;
  final List<AddressV2> addresses;
  final Widget Function(RemoteData<SwapFormLoaderData>) child;

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
        return BlocBuilder<SwapFormLoaderBloc, RemoteData<SwapFormLoaderData>>(
            builder: (context, state) {
          return child(state);
        });
      }),
    );
  }
}

class AssetPairFormActions {
  final VoidCallback onInvertClicked;
  final Function(AssetPairFormOption value) onGiveAssetSelected;
  final Function(AssetPairFormOption value) onReceiveAssetSelected;
  final VoidCallback onReceiveAssetInputClicked;
  final Function(String value) onSearchAssetInputChanged;
  final VoidCallback onSubmitClicked;

  const AssetPairFormActions(
      {required this.onInvertClicked,
      required this.onReceiveAssetSelected,
      required this.onGiveAssetSelected,
      required this.onReceiveAssetInputClicked,
      required this.onSearchAssetInputChanged,
      required this.onSubmitClicked});
}

class AssetPairFormProvider extends StatelessWidget {
  final List<MultiAddressBalance> balances;
  final Widget Function(AssetPairFormActions actions, AssetPairFormModel state)
      child;

  const AssetPairFormProvider(
      {required this.child, required this.balances, super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return BlocProvider(create: (context) {
      return AssetPairFormBloc(
        httpConfig: session.httpConfig,
        initialGiveAssets: balances,
      );
    }, child: BlocBuilder<AssetPairFormBloc, AssetPairFormModel>(
        builder: (context, state) {
      return child(
          AssetPairFormActions(
              onInvertClicked: () =>
                  context.read<AssetPairFormBloc>().add(InvertClicked()),
              onGiveAssetSelected: (AssetPairFormOption value) => context
                  .read<AssetPairFormBloc>()
                  .add(GiveAssetSelected(value: value)),
              onReceiveAssetSelected: (AssetPairFormOption value) => context
                  .read<AssetPairFormBloc>()
                  .add(ReceiveAssetSelected(value: value)),
              onReceiveAssetInputClicked: () => context
                  .read<AssetPairFormBloc>()
                  .add(const ReceiveAssetInputClicked()),
              onSubmitClicked: () =>
                  context.read<AssetPairFormBloc>().add(SubmitClicked()),
              onSearchAssetInputChanged: (String value) => context
                  .read<AssetPairFormBloc>()
                  .add(SearchInputChanged(value))),
          state);
    }));
  }
}

class AssetPairForm extends StatefulWidget {
  final Function(SwapType type) onSubmit;
  final AssetPairFormActions actions;
  final AssetPairFormModel state;

  // final List<AssetPairFormOption> giveAssets;
  // final RemoteData<List<AssetSearchResult>> receiveAssets;
  // final GiveAssetInput giveAssetInput;
  // final ReceiveAssetInput receiveAssetInput;
  // final SearchAssetInput searchAssetInput;
  // final Function(AssetPairFormOption option)? onGiveAssetSelected;
  // final Function(AssetPairFormOption option)? onReceiveAssetSelected;
  // final VoidCallback onInvertClicked;
  //
  // final bool receiveAssetModalVisible;
  // final VoidCallback onReceiveAssetInputClicked;
  // final Function(String value) onSearchAssetInputChanged;

  const AssetPairForm(
      {required this.onSubmit,
      required this.actions,
      required this.state,
      //   required this.receiveAssetModalVisible,
      // required this.onReceiveAssetInputClicked,
      // required this.giveAssets,
      // required this.giveAssetInput,
      // required this.receiveAssets,
      // required this.receiveAssetInput,
      // required this.searchAssetInput,
      // required this.onSearchAssetInputChanged,
      // required this.onInvertClicked,
      // this.onGiveAssetSelected,
      // this.onReceiveAssetSelected,
      super.key});

  @override
  State<AssetPairForm> createState() => _AssetPairFormState();
}

class _AssetPairFormState extends State<AssetPairForm> {
  @override
  void didUpdateWidget(covariant AssetPairForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.state.receiveAssetModalVisible &&
        !oldWidget.state.receiveAssetModalVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // when receive assets updates, the modal does not...
        showReceiveAssetModal(
          outerContext: context,
          query: widget.state.searchAssetInput.value,
          onReceiveAssetSelected: widget.actions.onReceiveAssetSelected,
          onQueryChanged: (value) {
            widget.actions.onSearchAssetInputChanged(value);
          },
        ).then((selection) {
          if (selection != null) {
            widget.actions.onReceiveAssetSelected(selection);
          } else {
            widget.actions.onReceiveAssetInputClicked();
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssetPairFormBloc, AssetPairFormModel>(
        listener: (context, state) {
      if (state.submissionStatus.isSuccess) {
        widget.state.swapType.fold(
            (error) => throw Exception(
                "invariant: submissionStatus is success but swapType cannot be derived"),
            (type) => widget.onSubmit(type));
      }
    }, builder: (context, state) {
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
                      HorizonRedesignDropdown<AssetPairFormOption>(
                          itemPadding: const EdgeInsets.all(12),
                          items: widget.state.giveAssets
                              .map((item) => DropdownMenuItem(
                                  value: item,
                                  child:
                                      AssetBalanceListItemWithOptionalBalance(
                                          asset: item.name,
                                          description: item.description,
                                          balance: item.balance)))
                              .toList(),
                          onChanged: (value) {
                            widget.actions.onGiveAssetSelected(value!);
                          },
                          selectedValue: widget.state.giveAssetInput.value,
                          selectedItemBuilder: (AssetPairFormOption item) =>
                              AssetBalanceListItemWithOptionalBalance(
                                  asset: item.name,
                                  description: item.description,
                                  balance: item.balance),
                          hintText: "Select Token"),
                      commonHeightSizedBox,
                      // overlay a transparent mask on top of the
                      // dropdown to get custom behavior
                      Stack(
                        children: [
                          HorizonRedesignDropdown<AssetPairFormOption>(
                              itemPadding: const EdgeInsets.all(12),
                              items: [],
                              onChanged: (value) {},
                              selectedValue:
                                  widget.state.receiveAssetInput.value,
                              selectedItemBuilder: (AssetPairFormOption item) =>
                                  AssetBalanceListItemWithOptionalBalance(
                                      asset: item.name,
                                      description: item.description,
                                      balance: item.balance),
                              hintText: "Select Token"),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap:
                                    widget.actions.onReceiveAssetInputClicked,
                                splashColor: Theme.of(context)
                                    .splashColor
                                    .withOpacity(0.1),
                                highlightColor: Theme.of(context)
                                    .highlightColor
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      )
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
                            onTap: widget.actions.onInvertClicked,
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
                disabled: widget.state.disabled,
                onPressed: () {
                  if (widget.state.disabled) return;
                  widget.actions.onSubmitClicked();
                },
                child: TextButtonContent(value: "Swap"),
                variant: ButtonVariant.green)
          ],
        ),
      );
    });
  }
}
