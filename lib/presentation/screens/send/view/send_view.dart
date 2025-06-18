import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:fpdart/fpdart.dart' show Option;
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/forms/send_compose_form.dart';
import 'package:horizon/presentation/screens/send/forms/send_form_balance_handler.dart';
import 'package:horizon/presentation/screens/send/forms/send_form_token_selector.dart';
import 'package:horizon/presentation/screens/send/forms/send_review_form.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SendFlowModel extends Equatable {
  final Option<MultiAddressBalance> balance; // step1
  final Option<String> address; // step2
  final Option<List<SendEntryFormModel>> sendEntries; // step3
  final Option<ComposeResponse> composeResponse; // step3
  final Option<String> signedTxHex; // step4  
  final Option<String> signedTxHash; // step4

  const SendFlowModel({
    required this.balance,
    required this.address,
    required this.sendEntries,
    required this.composeResponse,
    required this.signedTxHex,
    required this.signedTxHash,
  });

  @override
  List<Object?> get props =>
      [balance, address, composeResponse, signedTxHex, signedTxHash];

  SendFlowModel copyWith(
          {Option<MultiAddressBalance>? balance,
          Option<String>? address,
          Option<ComposeResponse>? composeResponse,
          Option<String>? signedTxHex,
          Option<String>? signedTxHash,
          Option<List<SendEntryFormModel>>? sendEntries}) =>
      SendFlowModel(
          balance: balance ?? this.balance,
          address: address ?? this.address,
          composeResponse: composeResponse ?? this.composeResponse,
          signedTxHex: signedTxHex ?? this.signedTxHex,
          signedTxHash: signedTxHash ?? this.signedTxHash,
          sendEntries: sendEntries ?? this.sendEntries);
}

class SendFlowController extends FlowController<SendFlowModel> {
  SendFlowController({required SendFlowModel initialState})
      : super(initialState);
}

class SendView extends StatefulWidget {
  const SendView({super.key});

  @override
  State<SendView> createState() => _SendViewState();
}

class _SendViewState extends State<SendView> {
  late SendFlowController _controller;
  List<MultiAddressBalance>? _cachedBalances;

  @override
  void initState() {
    super.initState();
    _controller = SendFlowController(
        initialState: const SendFlowModel(
            balance: Option.none(),
            address: Option.none(),
            sendEntries: Option.none(),
            composeResponse: Option.none(),
            signedTxHex: Option.none(),
            signedTxHash: Option.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return FlowBuilder<SendFlowModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          Option.of(MaterialPage(child: Builder(builder: (context) {
            return FlowStep(
              title: "Send",
              widthFactor: .2,
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
                    return Builder(builder: (context) {
                      return TokenSelectorFormProvider(
                        balances: balances,
                        child: (actions, state) => Column(
                          children: [
                            TokenSelectorFormSuccessHandler(
                                onTokenSelected: (option) {
                              _cachedBalances = balances;
                              context.flow<SendFlowModel>().update((model) =>
                                  model.copyWith(balance: option.balance));
                            }),
                            SendFormTokenSelector(
                              actions: actions,
                              state: state,
                            )
                          ],
                        ),
                      );
                    });
                  }),
            );
          }))),
          model.balance.map((balance) => MaterialPage(
                child: FlowStep(
                  title: "Choose your Address",
                  widthFactor: .4,
                  body: AssetBalanceFormProvider(
                    multiAddressBalance: balance,
                    child: (actions, state) => Column(
                      children: [
                        Builder(
                          builder: (context) => SendFormBalanceSuccessHandler(
                              onSuccess: (address) {
                            context.flow<SendFlowModel>().update((model) {
                              return model.copyWith(
                                  address: Option.of(address));
                            });
                          }),
                        ),
                        AssetBalanceForm(
                          state: state,
                          actions: actions,
                        ),
                      ],
                    ),
                  ),
                ),
              )),
          model.address.map((address) => MaterialPage(
                child: FlowStep(
                  title: "Receipient & Quantity",
                  widthFactor: .6,
                  body: SendComposeFormProvider(
                    initialEntries: [
                      SendEntryFormModel(
                          destinationInput: const DestinationInput.pure(),
                          balanceSelectorInput: BalanceSelectorInput.dirty(
                              value: model.balance.toNullable()!),
                          quantityInput: QuantityInput.pure(
                            maxQuantity:
                                BigInt.from(model.balance.toNullable()!.total),
                            divisible:
                                model.balance.toNullable()!.assetInfo.divisible,
                          ),
                          memoInput: const MemoInput.pure())
                    ],
                    balances: _cachedBalances!,
                    sourceAddress: model.address
                        .getOrElse(() => throw Exception("Invalid address")),
                    child: (actions, state) => Builder(builder: (context) {
                      return Column(
                        children: [
                          SendComposeSuccessHandler(onComposeResponse: (value) {
                            context.flow<SendFlowModel>().update((model) {
                              print(state.sendEntries);
                              return model.copyWith(
                                sendEntries: fp.Option.of(state.sendEntries),
                                  composeResponse: fp.Option.of(value));
                            });
                          }),
                          SendComposeForm(
                            actions: actions,
                            state: state,
                          )
                        ],
                      );
                    }),
                  ),
                ),
              )),
          model.composeResponse.map((composeResponse) => MaterialPage(
                child: FlowStep(
                  title: "Review Send",
                  widthFactor: 1.0,
                  body: SendReviewFormProvider(
                      composeResponse: switch(composeResponse) {
                        ComposeMpmaSendResponse resp => ComposeSendMpma(resp),
                        ComposeSendResponse resp => ComposeSendSingle(resp),
                        _ => throw Exception("Invalid compose response type: ${composeResponse.runtimeType}"),
                      },
                      sendEntries: model.sendEntries.toNullable()!,
                      child: (actions, state) => Builder(builder: (context) {
                            return Column(
                              children: [
                                SendReviewFormSuccessHandler(
                                  onSuccess: () {
                                    context
                                        .flow<SendFlowModel>()
                                        .update((model) {
                                      return model.copyWith(
                                        signedTxHex: const fp.Option.of(
                                          "02000000xcadxc000000000001976a91462e907b17c1d4b80e28614e46f04f2c4167afee88ac00000000",
                                        ),
                                        signedTxHash: const fp.Option.of(
                                          "6a6890705f4fe6d438983ed65d01452a8a8823f1a187982a1745c6b24e4d3409",
                                        ),
                                      );
                                    });
                                  },
                                ),
                                SendReviewForm(
                                  state: state,
                                  actions: actions,
                                ),
                              ],
                            );
                          })),
                ),
              )),
          model.signedTxHash.map((signedTxHash) => MaterialPage(
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
                              context.go("/dashboard");
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
                      txHex: model.signedTxHex.toNullable()!,
                      txHash: model.signedTxHash.toNullable()!,
                      title: "Send Successful",
                      onClose: () {
                        context.go("/dashboard");
                      },
                    )),
              )))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }
}
