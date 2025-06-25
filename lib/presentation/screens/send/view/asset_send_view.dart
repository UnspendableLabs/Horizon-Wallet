import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' show FpdartOnIterable, Option;
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/address_v2.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/forms/send_compose_form.dart';
import 'package:horizon/presentation/screens/send/forms/send_review_form.dart';
import 'package:horizon/presentation/screens/send/send_form_loader.dart';
import 'package:horizon/presentation/screens/send/view/send_view.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class AssetSendFlowModel extends Equatable {
  final Option<AddressV2> address;
  final Option<SendFlowComposeStep> composeStep;
  final Option<SendFlowConfirmationStep> confirmationStep;

  const AssetSendFlowModel({
    required this.address,
    required this.composeStep,
    required this.confirmationStep,
  });

  @override
  List<Object?> get props => [address];

  AssetSendFlowModel copyWith({
    Option<AddressV2>? address,
    Option<SendFlowComposeStep>? composeStep,
    Option<SendFlowConfirmationStep>? confirmationStep,
  }) {
    return AssetSendFlowModel(
      address: address ?? this.address,
      composeStep: composeStep ?? this.composeStep,
      confirmationStep: confirmationStep ?? this.confirmationStep,
    );
  }
}

class AssetSendFlowController extends FlowController<AssetSendFlowModel> {
  AssetSendFlowController({required AssetSendFlowModel initialState})
      : super(initialState);
}

class AssetSendView extends StatefulWidget {
  final String assetName;
  const AssetSendView({super.key, required this.assetName});

  @override
  State<AssetSendView> createState() => _AssetSendViewState();
}

class _AssetSendViewState extends State<AssetSendView> {
  late AssetSendFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AssetSendFlowController(
        initialState: const AssetSendFlowModel(
            address: Option.none(),
            composeStep: Option.none(),
            confirmationStep: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    late MultiAddressBalance _balance;
    return FlowBuilder<AssetSendFlowModel>(
        controller: _controller,
        onGeneratePages: (model, pages) {
          return [
            Option.of(MaterialPage(child: Builder(builder: (context) {
              return FlowStep(
                title: "Choose your address",
                widthFactor: .3,
                leading: IconButton(
                    onPressed: () {
                      context.pop();
                    },
                    icon: AppIcons.closeIcon(
                      context: context,
                      width: 24,
                      height: 24,
                      fit: BoxFit.fitHeight,
                    )),
                body: SendFormLoader(
                    httpConfig: session.httpConfig,
                    addresses: session.addresses,
                    child: (balances) {
                      _balance = balances.firstWhere(
                          (balance) => balance.asset == widget.assetName);
                      return Builder(builder: (context) {
                        return AssetBalanceFormProvider(
                            child: (actions, state) => Column(
                                  children: [
                                    SendFormBalanceSuccessHandler(
                                        onSuccess: (address) {
                                          final addressV2 = session.addresses.firstWhere(
                                              (element) => element.address == address);
                                          _controller.update((model) =>
                                              model.copyWith(
                                                  address: Option.of(addressV2)));
                                    }),
                                    AssetBalanceForm(
                                      state: state,
                                      actions: actions,
                                    ),
                                  ],
                                ),
                            multiAddressBalance: _balance);
                      });
                    }),
              );
            }))),
            model.address.map(
              (address) => MaterialPage(
                  child: FlowStep(
                title: "Recipient & Quantity",
                widthFactor: .6,
                body: SendComposeFormProvider(
                  balances: const [],
                  initialEntries: [
                    SendEntryFormModel(
                      destinationInput: const DestinationInput.pure(),
                      balanceSelectorInput:
                          BalanceSelectorInput.dirty(value: _balance),
                      quantityInput: QuantityInput.pure(
                        maxQuantity: BigInt.from(_balance.total),
                        divisible: _balance.assetInfo.divisible,
                      ),
                      memoInput: const MemoInput.pure(),
                    )
                  ],
                  sourceAddress: address.address,
                  child: (actions, state) => Builder(builder: (context) {
                    return Column(
                      children: [
                        SendComposeSuccessHandler(onComposeResponse: (value) {
                          context.flow<AssetSendFlowModel>().update((model) =>
                              model.copyWith(
                                  composeStep: Option.of(SendFlowComposeStep(
                                      composeResponse: value,
                                      sendEntries: state.sendEntries))));
                        }),
                        SendComposeForm(
                          actions: actions,
                          state: state,
                          mpmaMode: false,
                          disableBalanceSelector: true,
                        )
                      ],
                    );
                  }),
                ),
              )),
            ),
            model.composeStep.map(
              (composeStep) => MaterialPage(
                  child: FlowStep(
                title: "Review Send",
                widthFactor: 1.0,
                body: SendReviewFormProvider(
                  httpConfig: session.httpConfig,
                  sourceAddress: model.address.getOrThrow(),
                  composeResponse: switch (composeStep.composeResponse) {
                    ComposeMpmaSendResponse resp => ComposeSendMpma(resp),
                    ComposeSendResponse resp => ComposeSendSingle(resp),
                    _ => throw Exception(
                        "Invalid compose response type: ${composeStep.composeResponse.runtimeType}"),
                  },
                  sendEntries: composeStep.sendEntries,
                  child: (actions, state) => Builder(builder: (context)=> Column(
                    children: [
                      SendReviewFormSuccessHandler(onSuccess: (value) {
                        context
                            .flow<AssetSendFlowModel>()
                            .update((model) => model.copyWith(
                                  confirmationStep: Option.of(value),
                                ));
                      }),
                      SendReviewForm(state: state, actions: actions)
                    ],
                  )),
                ),
              )),
            ),
            model.confirmationStep.map((confirmationStep) => MaterialPage(
                    child: Scaffold(
                  appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(72),
                      child: Container(
                        height: 46,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            left: 12, top: 0, bottom: 0, right: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
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
                          ],
                        ),
                      )),
                  body: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TransactionSuccessful(
                        txHex: confirmationStep.signedTxHex,
                        txHash: confirmationStep.signedTxHash,
                        title: "Send Successful",
                        onClose: () {
                          context.pop();
                        },
                      )),
                )))
          ]
              .filter((page) => page.isSome())
              .map((page) => page.getOrThrow())
              .toList();
        });
  }
}
