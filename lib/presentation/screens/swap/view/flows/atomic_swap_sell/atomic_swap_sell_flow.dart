import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';

import "./flows/atomic_swap_sell_attached_flow.dart";
import "./flows/atomic_swap_sell_unattached_flow.dart";

class AtomicSwapSellModel extends Equatable {
  final Option<AtomicSwapSellVariant> atomicSwapSellVariant;

  const AtomicSwapSellModel({required this.atomicSwapSellVariant});

  @override
  List<Object?> get props => [];

  AtomicSwapSellModel copyWith(
          {Option<AtomicSwapSellVariant>? atomicSwapSellVariant}) =>
      AtomicSwapSellModel(
          atomicSwapSellVariant:
              atomicSwapSellVariant ?? this.atomicSwapSellVariant);
}

class AtomicSwapSellFlowController extends FlowController<AtomicSwapSellModel> {
  AtomicSwapSellFlowController({required AtomicSwapSellModel initialState})
      : super(initialState);
}

class AtomicSwapSellFlowView extends StatefulWidget {
  final MultiAddressBalance balances;

  const AtomicSwapSellFlowView({required this.balances, super.key});

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
          const AtomicSwapSellModel(atomicSwapSellVariant: Option.none()),
    );
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
            widthFactor: .3,
            body: AssetBalanceFormProvider(
              multiAddressBalance: widget.balances,
              child: (actions, state) => Column(
                children: [
                  AssetBalanceSuccessHandler(onSubmit: (option) {
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
                AttachedAtomicSwapSell() => MaterialPage(
                    child: AtomicSwapSellAttachedFlowView(params: variant)),
                UnattachedAtomicSwapSell() => MaterialPage(
                    child: AtomicSwapSellUnattachedFlowView(params: variant)),
              })
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
