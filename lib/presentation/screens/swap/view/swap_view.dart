import 'package:equatable/equatable.dart';
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
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/forms/asset_pair_form/asset_pair_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

import "./flows/atomic_swap_buy/atomic_swap_buy_flow.dart";
import "./flows/atomic_swap_sell/atomic_swap_sell_flow.dart";
import "./flows/order/order_flow.dart";
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwapExplainerPopup extends StatefulWidget {
  const SwapExplainerPopup({super.key});

  @override
  State<SwapExplainerPopup> createState() => _SwapExplainerPopupState();
}

class _SwapExplainerPopupState extends State<SwapExplainerPopup> {
  bool _dontShowAgain = false;

  Future<void> _checkPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final skip = prefs.getBool('swap_explainer_skip') ?? false;
    if (skip || !mounted) return;
    Future.delayed(const Duration(milliseconds: 100), _showModal);
  }

  Future<void> _showModal() async {
    if (!mounted) return;
    await WoltModalSheet.show<void>(
      context: context,
      modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
      pageListBuilder: (modalContext) {
        return [
          WoltModalSheetPage(
            hasTopBarLayer: false,
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 32.0),
                      child: Text(
                        "Horizon's Unified Trading Interface",
                        textAlign: TextAlign.center,
                        style: Theme.of(modalContext)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontSize: 36, height: .95),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  "Welcome to Horizon Wallet's unified trading interface.  ",
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: "Trade Counterparty assets",
                              style: Theme.of(modalContext)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: " on Counterparty's Dex, ",
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: "Buy available Horizon Market listings ",
                              style: Theme.of(modalContext)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "with BTC, or for \$2 ",
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                            TextSpan(
                              text: "list an asset for sale",
                              style: Theme.of(modalContext)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: " on Horizon Market.",
                              style: Theme.of(modalContext).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _dontShowAgain,
                            onChanged: (val) {
                              setModalState(() {
                                _dontShowAgain = val ?? false;
                              });
                            },
                          ),
                          SizedBox(width: 4),
                          Text("Don't show this message again",
                              style:
                                  Theme.of(modalContext).textTheme.labelSmall),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: HorizonButton(
                        variant: ButtonVariant.black,
                        onPressed: () async {
                          if (_dontShowAgain) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('swap_explainer_skip', true);
                          }
                          if (Navigator.of(modalContext).canPop()) {
                            Navigator.of(modalContext).pop(); // close modal
                          }
                        },
                        child: TextButtonContent(value: "Got it"),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ];
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPreference();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// class _SwapExplainerPopupState extends State<SwapExplainerPopup> {
//   bool _dontShowAgain = false;
//
//   Future<void> _checkPreference() async {
//     final prefs = await SharedPreferences.getInstance();
//     final skip = prefs.getBool('swap_explainer_skip') ?? false;
//     // if (skip) {
//     //   return;
//     // }
//     Future.delayed(Duration(seconds: 2), _showModal);
//   }
//
//   _setDontShowAgain(bool value) {
//     setState(() {
//       _dontShowAgain = value;
//     });
//   }
//
//   Future<void> _showModal() async {
//     if (!mounted) return;
//     await WoltModalSheet.show<void>(
//       context: context,
//       modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
//       pageListBuilder: (modalContext) {
//         return [
//           WoltModalSheetPage(
//             hasTopBarLayer: false,
//             child: Builder(builder: (context) {
//               return Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 32.0),
//                     child: Text(
//                       textAlign: TextAlign.center,
//                       "Horizon's Unified Trading Interface",
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium!
//                           .copyWith(fontSize: 36, height: .95),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16, vertical: 16),
//                     child: Text.rich(
//                       textAlign: TextAlign.center,
//                       TextSpan(
//                         children: [
//                           TextSpan(
//                             text:
//                                 "Welcome to Horizon Wallet's unified trading interface.  ",
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                           TextSpan(
//                             text: "Trade Counterparty assets",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: " on Counterparty's Dex, ",
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                           TextSpan(
//                             text: "Buy available Horizon Market listings ",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: "with BTC, or for \$2 ",
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                           TextSpan(
//                             text: "list an asset for sale",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .bodySmall
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           TextSpan(
//                             text: " on Horizon Market.",
//                             style: Theme.of(context).textTheme.bodySmall,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: Checkbox(
//                       value: _dontShowAgain,
//                       onChanged: (val) {
//                         _setDontShowAgain(val ?? false);
//                       },
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 32.0),
//                     child: HorizonButton(
//                       variant: ButtonVariant.black,
//                       onPressed: () async {
//                         if (_dontShowAgain) {
//                           final prefs = await SharedPreferences.getInstance();
//                           await prefs.setBool('swap_explainer_skip', true);
//                         }
//                       },
//                       child: TextButtonContent(value: "Got it"),
//                     ),
//                   ),
//                 ],
//               );
//             }),
//           ),
//         ];
//       },
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//
//     _checkPreference();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.shrink();
//   }
// }

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
                  builder: (context, state, refetch) {
                    return state.fold3(
                        onNone: () =>
                            Center(child: CircularProgressIndicator()),
                        onFailure: (error) => Text(error.toString()),
                        onReplete: (data) => AssetPairFormProvider(
                            balancesSet: data,
                            child: (actions, state) => Column(
                                  children: [
                                    SwapExplainerPopup(),
                                    AssetPairForm(
                                        onSubmit: (swapType) {
                                          context
                                              .flow<SwapFlowModel>()
                                              .update((model) => model.copyWith(
                                                    swapType:
                                                        Option.of(swapType),
                                                  ));
                                        },
                                        actions: actions,
                                        state: state),
                                  ],
                                )));
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
