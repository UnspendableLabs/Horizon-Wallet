import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/balance_v2.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/swap_type.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/usecases/get_all_balances.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/forms/asset_pair_form/asset_pair_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

import "./flows/atomic_swap_buy/atomic_swap_buy_flow.dart";
import "./flows/atomic_swap_sell/atomic_swap_sell_flow.dart";
import "./flows/order/order_flow.dart";

class SwapFlowController extends FlowController<SwapFlowModel> {
  SwapFlowController({required SwapFlowModel initialState})
      : super(initialState);
}

class SwapFlowModel extends Equatable {
  final Option<SwapType> swapType;

  const SwapFlowModel({required this.swapType});

  @override
  List<Object?> get props => [];

  SwapFlowModel copyWith({Option<SwapType>? swapType}) =>
      SwapFlowModel(swapType: swapType ?? this.swapType);
}

class SwapFlowView extends StatefulWidget {
  final Config _config;
  final GetAllBalancesUseCase _getAllBalancesUseCase;

  SwapFlowView({
    super.key,
    Config? config,
    GetAllBalancesUseCase? getAllBalancesUseCase,
  })  : _getAllBalancesUseCase =
            getAllBalancesUseCase ?? GetIt.I.get<GetAllBalancesUseCase>(),
        _config = config ?? GetIt.I.get<Config>();

  @override
  State<SwapFlowView> createState() => _SwapFlowViewState();
}

class _SwapFlowViewState extends State<SwapFlowView> {
  late SwapFlowController _controller;

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
              body: RemoteDataTaskEitherBuilder(
                  task: widget._getAllBalancesUseCase.call(
                      GetAllBalancesUseCaseParams(
                          httpConfig: session.httpConfig,
                          addresses: session.addressIndexSet.list
                              .map((e) => e.address)
                              .toList())),
                  builder: (context, state, __refetch) {
                    return state.fold3(
                        onNone: () =>
                            Center(child: CircularProgressIndicator()),
                        onFailure: (error) => Text(error.toString()),
                        onReplete: (data) => AssetPairFormProvider(
                            balances:
                                data.projected.summarize().values.toList(),
                            child: (actions, state) => AssetPairForm(
                                onSubmit: (swapType) {
                                  context
                                      .flow<SwapFlowModel>()
                                      .update((model) => model.copyWith(
                                            swapType: Option.of(swapType),
                                          ));
                                },
                                actions: actions,
                                state: state)));
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
                      httpConfig: session.httpConfig,
                      addresses: session.addressIndexSet.list,
                      balances: balance,
                    ),
                  ),
                AtomicSwapBuy(
                  btcBalance: var btcBalance,
                  receiveAsset: var receiveAsset
                ) =>
                  MaterialPage(
                    child: AtomicSwapBuyFlowView(
                        // TODO: this is a little messy, for sure
                        addresses: session.addressIndexSet.list,
                        receiveAsset: receiveAsset,
                        balances: btcBalance,
                        onExitFlow: () {
                          Navigator.of(context).pop();
                        }),
                  ),
                CounterpartyOrder(
                  giveBalance: var giveBalance,
                  receiveAsset: var receiveAsset,
                ) =>
                  MaterialPage(
                      child: OrderFlowView(
                    addresses: session.addressIndexSet.list,
                    receiveAsset: receiveAsset,
                    giveBalance: giveBalance,
                  )),
                _ => throw UnimplementedError("Swap type not implemented")
              })
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = SwapFlowController(
        // initialState: const SwapFlowModel(swapType: Option.none()),
        initialState: const SwapFlowModel(swapType: Option.none()));
  }
}
