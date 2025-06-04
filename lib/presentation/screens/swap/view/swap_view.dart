import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:horizon/domain/entities/asset_info.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
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
import 'package:horizon/extensions.dart';

import "./flows/atomic_swap_sell/atomic_swap_sell_flow.dart";

final fakeUnattachedSell = AtomicSwapSell(
    giveBalance: MultiAddressBalance(
  assetInfo: const AssetInfo(
    assetLongname: null,
    description: "",
    divisible: false,
    locked: false,
  ),
  asset: "A17385292979323683364",
  assetLongname: null,
  entries: [
    MultiAddressBalanceEntry(
      address: "bc1q4sh3sfkpplg5v80ga907z7gnmhktyqqve7y5n2",
      quantity: 1,
      quantityNormalized: "1",
    ),
  ],
  total: 0,
  totalNormalized: "0",
));

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
        // initialState: const SwapFlowModel(swapType: Option.none()),
        initialState: SwapFlowModel(swapType: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return FlowBuilder<SwapFlowModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(child: Builder(builder: (context) {
            return FlowStep(
              title: "Swap",
              // TODO: this needs to be dynamic based on current step / estimated number of steps
              widthFactor: .2,
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
                          child: (actions, state) => AssetPairForm(
                              onSubmit: (swapType) {
                                context
                                    .flow<SwapFlowModel>()
                                    .update((model) => model.copyWith(
                                          swapType: Option.of(swapType),
                                        ));
                              },
                              actions: actions,
                              state: state)),
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
          }))),
          model.swapType.map((swapType) => switch (swapType) {
                AtomicSwapSell(giveBalance: var balance) => MaterialPage(
                    child: AtomicSwapSellFlowView(
                      // TODO: this is a little messy, for sure
                      address: session.addresses.first,
                      balances: balance,
                    ),
                  ),
                // AtomicSwapSell(giveBalance: var balance) => MaterialPage(
                //       child: FlowStep(
                //     title: "Choose your asset / address",
                //     widthFactor: .3,
                //     body: AssetBalanceFormProvider(
                //       multiAddressBalance: balance,
                //       child: (actions, state) => Column(
                //         children: [
                //           AssetBalanceSuccessHandler(onSubmit: (option) {
                //             print(option);
                //           }),
                //           AssetBalanceForm(
                //             state: state,
                //             actions: actions,
                //           ),
                //         ],
                //       ),
                //     ),
                //   )),
                _ => throw UnimplementedError("Swap type not implemented")
              })
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
