import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:go_router/go_router.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/presentation/forms/asset_pair_form/asset_pair_form_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/entities/remote_data.dart';

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
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return FlowBuilder<SwapFlowModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          MaterialPage(child: Builder(builder: (context) {
            return FlowStep(
              title: "Swap",
              widthFactor: .25,
              // TODO: rename to AssetPairForm
              body: AssetPairLoader(
                  addresses: session.addresses,
                  httpConfig: session.httpConfig,
                  child: (state) {
                    return switch (state) {
                      Initial() => const SizedBox.shrink(),
                      Loading() =>
                        const Center(child: CircularProgressIndicator()),
                      Success(value: var data) => AssetPairFormProvider(
                          balances: data.balances,
                          initialMultiAddressBalanceEntry: null,
                          child: (actions, state) => AssetPairForm(
                            receiveAssets: state.receiveAssets,
                            giveAssets: state.giveAssets,
                            giveAssetInput: state.giveAssetInput,
                            onGiveAssetChanged: actions.onGiveAssetChanged,
                            receiveAssetModalVisible:
                                state.receiveAssetModalVisible,
                            receiveAssetInput: state.receiveAssetInput,
                            onReceiveAssetInputClicked:
                                actions.onReceiveAssetInputClicked,
                            onReceiveAssetInputChanged:
                                actions.onReceiveAssetInputChanged,
                          ),
                        ),
                      Failure(error: var error) => Text(error.toString()),
                      Refreshing() => throw UnimplementedError(),
                    };
                  }),
              leading: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: AppIcons.closeIcon(
                  context: context,
                  width: 24,
                  height: 24,
                  fit: BoxFit.fitHeight,
                ),
              ),
            );
          }))
        ];
      },
    );
    return Text("Swap View");
  }
}
