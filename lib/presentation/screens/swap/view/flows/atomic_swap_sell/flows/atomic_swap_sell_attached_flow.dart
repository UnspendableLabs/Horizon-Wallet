import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/utils/app_icons.dart';

class AtomicSwapSellAttachedModel extends Equatable {
  final AttachedAtomicSwapSell params;

  const AtomicSwapSellAttachedModel({required this.params});

  @override
  List<Object?> get props => [];

  // AtomicSwapSellAttachedModel copyWith(
  //         {Option<AtomicSwapSellVariant>? atomicSwapSellVariant}) =>
  //     AtomicSwapSellAttachedModel(
  //         atomicSwapSellVariant:
  //             atomicSwapSellVariant ?? this.atomicSwapSellVariant);
}

class AtomicSwapSellAttachedFlowController
    extends FlowController<AtomicSwapSellAttachedModel> {
  AtomicSwapSellAttachedFlowController(
      {required AtomicSwapSellAttachedModel initialState})
      : super(initialState);
}

class AtomicSwapSellAttachedFlowView extends StatefulWidget {
  final AttachedAtomicSwapSell params;

  const AtomicSwapSellAttachedFlowView({required this.params, super.key});

  @override
  State<AtomicSwapSellAttachedFlowView> createState() =>
      _AtomicSwapSellAttachedFlowViewState();
}

class _AtomicSwapSellAttachedFlowViewState
    extends State<AtomicSwapSellAttachedFlowView> {
  late AtomicSwapSellAttachedFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AtomicSwapSellAttachedFlowController(
      initialState: AtomicSwapSellAttachedModel(params: widget.params),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AtomicSwapSellAttachedModel>(
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
            title: "TMP: attached atomic swap sell flow",
            widthFactor: .4,
            body: Text("attached atomc swap flow placeholder view"),
          ))),
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
