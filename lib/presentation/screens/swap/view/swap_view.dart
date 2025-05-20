import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/swap_type.dart';

import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;

class SwapFlowModel extends Equatable {
  final Option<SwapType> swapType;

  const SwapFlowModel({required this.swapType});

  @override
  List<Object?> get props => [];

  SwapFlowModel copyWith({Option<SwapType>? swapType}) =>
      SwapFlowModel(swapType: swapType ?? this.swapType);
}

class SwapFlowController extends FlowController<SwapFlowModel> {
  SwapFlowController({required SwapFlowModel initialState})
      : super(initialState);
}

class SwapFlowView extends StatefulWidget {
  const SwapFlowView({super.key});

  @override
  State<SwapFlowView> createState() => _SwapFlowViewState();
}

class _SwapFlowViewState extends State<SwapFlowView> {
  late SwapFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SwapFlowController(
      initialState: const SwapFlowModel(swapType: Option.none()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<SwapFlowModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          MaterialPage(child: Builder(builder: (context) {
            return Text("asset pair view");
          }))
        ];
      },
    );
    return Text("Swap View");
  }
}
