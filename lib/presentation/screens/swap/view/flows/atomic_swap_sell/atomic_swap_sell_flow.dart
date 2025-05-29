import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/forms/asset_attach_form/asset_attach_form_view.dart';
import 'package:horizon/presentation/screens/atomic_swap/forms/create_swap_listing.dart';
import 'package:horizon/presentation/forms/create_psbt_form/create_psbt_form_view.dart';

class AtomicSwapSellModel extends Equatable {
  final Option<AtomicSwapSellVariant> atomicSwapSellVariant;

  const AtomicSwapSellModel({required this.atomicSwapSellVariant});

  @override
  List<Object?> get props => [];

  AtomicSwapSellModel copyWith({
    Option<AtomicSwapSellVariant>? atomicSwapSellVariant,
  }) =>
      AtomicSwapSellModel(
        atomicSwapSellVariant:
            atomicSwapSellVariant ?? this.atomicSwapSellVariant,
      );
}

class AtomicSwapSellFlowController extends FlowController<AtomicSwapSellModel> {
  AtomicSwapSellFlowController({required AtomicSwapSellModel initialState})
      : super(initialState);
}

class AtomicSwapSellFlowView extends StatefulWidget {
  final AddressV2 address;

  final MultiAddressBalance balances;

  const AtomicSwapSellFlowView(
      {required this.address, required this.balances, super.key});

  @override
  State<AtomicSwapSellFlowView> createState() => _AtomicSwapSellFlowViewState();
}

class _AtomicSwapSellFlowViewState extends State<AtomicSwapSellFlowView> {
  late AtomicSwapSellFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtomicSwapSellFlowController(
        initialState:
            AtomicSwapSellModel(atomicSwapSellVariant: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapSellModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(
              child: FlowStep(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: AppIcons.backArrowIcon(
                context: context,
                width: 24,
                height: 24,
                fit: BoxFit.fitHeight,
              ),
            ),
            title: "Choose your asset / address",
            widthFactor: .4,
            body: AssetBalanceFormProvider(
              multiAddressBalance: widget.balances,
              child: (actions, state) => Column(
                children: [
                  AssetBalanceSuccessHandler(onSuccess: (option) {
                    _controller.update(
                      (model) => model.copyWith(
                        atomicSwapSellVariant: Option.of(option),
                      ),
                    );
                  }),
                  AssetBalanceForm(
                    state: state,
                    actions: actions,
                  ),
                ],
              ),
            ),
          ))),
          model.atomicSwapSellVariant.map((variant) => switch (variant) {
                UnattachedAtomicSwapSell() => MaterialPage(
                      child: FlowStep(
                    leading: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: AppIcons.backArrowIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                    title: "Attach assets to swap",
                    widthFactor: .5,
                    body: AssetAttachFormProvider(
                        // TODO: this is pretty gross
                        address: variant.address == widget.address.address
                            ? widget.address
                            : throw Exception("invariant: address mismatch"),
                        asset: variant.asset,
                        quantity: variant.quantity,
                        quantityNormalized: variant.quantityNormalized,
                        description: variant.description,
                        divisible: variant.divisible,
                        child: (actions, state) => Column(
                              children: [
                                AssetAttachSuccessHandler(
                                    onSuccess: (attachedAtomicSwapSell) {
                                  _controller.update(
                                    (model) => model.copyWith(
                                      atomicSwapSellVariant:
                                          Option.of(attachedAtomicSwapSell),
                                    ),
                                  );
                                }),
                                AssetAttachForm(state: state, actions: actions),
                              ],
                            )),
                  )),
                AttachedAtomicSwapSell() => MaterialPage(
                    child: FlowStep(
                        title: "Create PSBT",
                        widthFactor: .8,
                        body: CreatePsbtFormProvider(
                          utxoID: variant.utxo,
                          address: variant.utxoAddress == widget.address.address
                              ? widget.address
                              : throw Exception("invariant: address mismatch"),
                          child: (actions, state) => CreatePsbtForm(
                            actions: actions,
                            state: state,
                            asset: variant.asset,
                            quantity: variant.quantity,
                            quantityNormalized: variant.quantityNormalized,
                            utxo: variant.utxo,
                            utxoAddress: variant.utxoAddress,
                          ),
                        ))),
              })
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
