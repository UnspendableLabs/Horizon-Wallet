import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/forms/asset_attach_form/asset_attach_form_view.dart';

class AtomicSwapSellUnattachedModel extends Equatable {
  final UnattachedAtomicSwapSell params;

  const AtomicSwapSellUnattachedModel({required this.params});

  @override
  List<Object?> get props => [];

  // AtomicSwapSellUnattachedModel copyWith(
  //         {Option<AtomicSwapSellVariant>? atomicSwapSellVariant}) =>
  //     AtomicSwapSellUnattachedModel(
  //         atomicSwapSellVariant:
  //             atomicSwapSellVariant ?? this.atomicSwapSellVariant);
}

class AtomicSwapSellUnattachedFlowController
    extends FlowController<AtomicSwapSellUnattachedModel> {
  AtomicSwapSellUnattachedFlowController(
      {required AtomicSwapSellUnattachedModel initialState})
      : super(initialState);
}

class AtomicSwapSellUnattachedFlowView extends StatefulWidget {
  final UnattachedAtomicSwapSell params;

  const AtomicSwapSellUnattachedFlowView({required this.params, super.key});

  @override
  State<AtomicSwapSellUnattachedFlowView> createState() =>
      _AtomicSwapSellUnattachedFlowViewState();
}

class _AtomicSwapSellUnattachedFlowViewState
    extends State<AtomicSwapSellUnattachedFlowView> {
  late AtomicSwapSellUnattachedFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtomicSwapSellUnattachedFlowController(
      initialState: AtomicSwapSellUnattachedModel(params: widget.params),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapSellUnattachedModel>(
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
            title: "Attach assets to swap",
            widthFactor: .5,
            body: AssetAttachFormProvider(
                asset: model.params.asset,
                quantity: model.params.quantity,
                quantityNormalized: model.params.quantityNormalized,
                description: model.params.description,
                divisible: model.params.divisible,
                child: (actions, state) =>
                    AssetAttachForm(state: state, actions: actions)),
          ))),
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
