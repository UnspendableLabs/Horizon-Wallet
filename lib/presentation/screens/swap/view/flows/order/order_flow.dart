import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:horizon/utils/app_icons.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import "package:fpdart/fpdart.dart" hide State;
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/bloc/asset_balance_form_bloc.dart';
import 'package:horizon/extensions.dart';

import 'package:horizon/presentation/forms/swap_order_form/swap_order_form_view.dart';
import "package:horizon/presentation/forms/asset_pair_form/bloc/form/asset_pair_form_bloc.dart";
import 'package:horizon/presentation/forms/create_psbt_form/create_psbt_form_view.dart';
import 'package:horizon/presentation/forms/swap_create_listing_confirmation_form/swap_create_listing_confirmation_form_view.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class OrderModel extends Equatable {
  Option<MultiAddressBalanceEntry> giveBalance;

  OrderModel({
    required this.giveBalance,
  });

  @override
  List<Object?> get props => [];

  OrderModel copyWith({
    // TODO: this really just needs to be address...
    Option<MultiAddressBalanceEntry>? giveBalance,
  }) {
    return OrderModel(
      giveBalance: giveBalance ?? this.giveBalance,
    );
  }
}

class OrderFlowController extends FlowController<OrderModel> {
  OrderFlowController({required OrderModel initialState}) : super(initialState);
}

class OrderFlowView extends StatefulWidget {
  final List<AddressV2> addresses;
  final MultiAddressBalance giveBalance;
  final AssetPairFormOption receiveAsset;

  const OrderFlowView({
    super.key,
    required this.addresses,
    required this.giveBalance,
    required this.receiveAsset,
  });

  @override
  State<OrderFlowView> createState() => _OrderFlowViewState();
}

class _OrderFlowViewState extends State<OrderFlowView> {
  late OrderFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = OrderFlowController(
        initialState: OrderModel(giveBalance: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return FlowBuilder<OrderModel>(
      controller: _controller,
      onGeneratePages: (model, _) {
        return [
          Option.of(
            MaterialPage(
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
                title: "Open Order",
                widthFactor: .4,
                body: AssetBalanceFormProvider(
                    multiAddressBalance: widget.giveBalance,
                    child: (actions, state) => Column(children: [
                          AssetBalanceSuccessHandler<MultiAddressBalanceEntry>(
                            mapSuccess: (state) =>
                                Either.of(state.balanceInput.value!.entry),
                            onSuccess: (value) =>
                                _controller.update((model) => model.copyWith(
                                      giveBalance: Option.of(value),
                                    )),
                          ),
                          AssetBalanceForm(
                            state: state,
                            actions: actions,
                          ),
                        ])),
              ),
            ),
          ),
          model.giveBalance.map((giveBalanceEntry) => MaterialPage(
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
                  title: "Limit Order",
                  widthFactor: .4,
                  body: SwapOrderFormProvider(
                      address: widget.addresses.firstWhere((address) =>
                          address.address ==
                          (giveBalanceEntry.address ??
                              giveBalanceEntry.utxoAddress!)),
                      httpConfig: session.httpConfig,
                      getAsset: "pepecash",
                      giveAsset: "xcp",
                      child: (actions, state) =>
                          SwapOrderForm(actions: actions, state: state)))))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
