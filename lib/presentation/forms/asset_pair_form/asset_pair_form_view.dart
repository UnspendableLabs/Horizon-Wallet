import "./bloc/loader/loader_bloc.dart";
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/entities/asset_search_result.dart';
import 'package:flutter/material.dart';

import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/remote_data.dart';

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
  final Function(MultiAddressBalance multiAddressBalance) onGiveAssetChanged;
  final VoidCallback onReceiveAssetInputClicked;
  final Function(String value) onReceiveAssetInputChanged;

  const AssetPairFormActions(
      {required this.onGiveAssetChanged,
      required this.onReceiveAssetInputClicked,
      required this.onReceiveAssetInputChanged});
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
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return BlocProvider(
        create: (context) => AssetPairFormBloc(
            httpConfig: session.httpConfig,
            initialGiveAssets: balances,
            initialMultiAddressBalanceEntry: initialMultiAddressBalanceEntry),
        child: BlocBuilder<AssetPairFormBloc, AssetPairFormModel>(
            builder: (context, state) {
          return child(
              AssetPairFormActions(
                  onGiveAssetChanged: (MultiAddressBalance value) => context
                      .read<AssetPairFormBloc>()
                      .add(GiveAssetChanged(value: value)),
                  onReceiveAssetInputClicked: () => context
                      .read<AssetPairFormBloc>()
                      .add(const ReceiveAssetInputClicked()),
                  onReceiveAssetInputChanged: (String value) => context
                      .read<AssetPairFormBloc>()
                      .add(ReceiveAssetInputChanged(value))),
              state);
        }));
  }
}

class AssetPairForm extends StatefulWidget {
  final List<MultiAddressBalance> giveAssets;
  final RemoteData<List<AssetSearchResult>> receiveAssets;
  final GiveAssetInput giveAssetInput;
  final ReceiveAssetInput receiveAssetInput;
  final Function(MultiAddressBalance multiAddressBalance)? onGiveAssetChanged;

  final bool receiveAssetModalVisible;
  final VoidCallback onReceiveAssetInputClicked;
  final Function(String value) onReceiveAssetInputChanged;

  const AssetPairForm(
      {required this.receiveAssetModalVisible,
      required this.onReceiveAssetInputClicked,
      required this.giveAssets,
      required this.giveAssetInput,
      required this.receiveAssets,
      required this.receiveAssetInput,
      required this.onReceiveAssetInputChanged,
      this.onGiveAssetChanged,
      super.key});

  @override
  State<AssetPairForm> createState() => _AssetPairFormState();
}

class _AssetPairFormState extends State<AssetPairForm> {
  bool _hasShownModal = false;

  @override
  void didUpdateWidget(covariant AssetPairForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.receiveAssetModalVisible &&
        !_hasShownModal &&
        !oldWidget.receiveAssetModalVisible) {
      _hasShownModal = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // when receive assets updates, the modal does not...
        showReceiveAssetModal(
          context: context,
          query: widget.receiveAssetInput.value,
          onQueryChanged: (value) {
            widget.onReceiveAssetInputChanged(value);
          },
        ).then((_) {
          widget.onReceiveAssetInputClicked();
        });
      });
    }

    if (!widget.receiveAssetModalVisible) {
      _hasShownModal = false;
    }
  }

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
                        items: widget.giveAssets
                            .map((e) => DropdownMenuItem(
                                value: e,
                                child: AssetBalanceListItem(balance: e)))
                            .toList(),
                        onChanged: (value) {
                          if (widget.onGiveAssetChanged != null &&
                              value != null) {
                            widget.onGiveAssetChanged!(value);
                          }
                        },
                        selectedValue: widget.giveAssetInput.value,
                        selectedItemBuilder: (MultiAddressBalance item) =>
                            AssetBalanceListItem(balance: item),
                        hintText: "Select Token"),
                    commonHeightSizedBox,
                    // overlay a transparent mask on top of the
                    // dropdown to get custom behavior
                    Stack(
                      children: [
                        HorizonRedesignDropdown<MultiAddressBalance>(
                            itemPadding: const EdgeInsets.all(12),
                            items: [],
                            onChanged: (value) {},
                            selectedValue: null,
                            selectedItemBuilder: (MultiAddressBalance item) =>
                                AssetBalanceListItem(balance: item),
                            hintText: "Select Token"),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: widget.onReceiveAssetInputClicked,
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
