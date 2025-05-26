import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:go_router/go_router.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/extensions.dart';

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

  const AtomicSwapSellFlowView({
    required this.balances,
    super.key});

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
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return FlowBuilder<AtomicSwapSellModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(
                  child: FlowStep(
            title: "Choose your asset / address",
            widthFactor: .3,
            body: AssetBalanceFormProvider(
              multiAddressBalance: widget.balances,
              child: (actions, state) => Column(
                children: [
                  AssetBalanceSuccessHandler(onSubmit: (option) {
                    print(option);
                  }),
                  AssetBalanceForm(
                    state: state,
                    actions: actions,
                  ),
                ],
              ),
            ),
          ))),
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
