import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_review_form_bloc.dart';
import 'package:horizon/presentation/screens/send/flows/send_compose_form.dart';
import 'package:horizon/presentation/screens/send/flows/send_form_balance_handler.dart';
import 'package:horizon/presentation/screens/send/flows/send_form_token_selector.dart';
import 'package:horizon/presentation/screens/send/flows/send_review_form.dart';
import 'package:horizon/presentation/screens/send/loader/loader_bloc.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/utils/app_icons.dart';

class SendType extends Equatable {
  final MultiAddressBalance selectedBalance;
  final MultiAddressBalanceEntry? selectedBalanceEntry;
  final ComposeResponse? composeResponse;
  final List<SendEntryFormModel>? sendEntries;
  final String? signedTxHex;
  final String? signedTxHash;
  const SendType(
      {required this.selectedBalance,
      this.selectedBalanceEntry,
      this.composeResponse,
      this.sendEntries,
      this.signedTxHex,
      this.signedTxHash});

  SendType copyWith({String? signedTxHex, String? signedTxHash}) => SendType(
      selectedBalance: selectedBalance,
      selectedBalanceEntry: selectedBalanceEntry,
      composeResponse: composeResponse,
      sendEntries: sendEntries,
      signedTxHex: signedTxHex,
      signedTxHash: signedTxHash);

  @override
  List<Object?> get props =>
      [selectedBalance, selectedBalanceEntry, composeResponse];
}

class SendFlowModel extends Equatable {
  final fp.Option<SendType> sendType;

  const SendFlowModel({required this.sendType});

  @override
  List<Object?> get props => [sendType];

  SendFlowModel copyWith({fp.Option<SendType>? sendType}) =>
      SendFlowModel(sendType: sendType ?? this.sendType);

  fp.Either<String, String> get sourceAddress => switch (sendType) {
        fp.Some(value: var type) => type.selectedBalanceEntry == null
            ? fp.left("No source address")
            : fp.right(type.selectedBalanceEntry!.address!),
        fp.None() => fp.left("No source address"),
      };

  bool get isBalanceSelected =>
      sendType.isSome() && sendType.toNullable()?.selectedBalanceEntry != null;

  bool get isComposeSuccess =>
      sendType.isSome() && sendType.toNullable()?.composeResponse != null;
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
        initialState:
            const SendFlowModel(sendType: fp.Option<SendType>.none()));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();
    return FlowBuilder<SendFlowModel>(
      controller: _controller,
      onGeneratePages: (model, pages) {
        return [
          MaterialPage(child: Builder(builder: (context) {
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
                  child: (state) {
                    return switch (state) {
                      Initial() => const SizedBox.shrink(),
                      Refreshing() => const SizedBox.shrink(),
                      Loading() =>
                        const Center(child: CircularProgressIndicator()),
                      Success(value: var data) => TokenSelectorFormProvider(
                          balances: data.balances,
                          child: (actions, state) => SendFormTokenSelector(
                              actions: actions,
                              state: state,
                              onSubmit: (sendType) {
                                _cachedBalances = data.balances;
                                context.flow<SendFlowModel>().update((model) =>
                                    model.copyWith(
                                        sendType: fp.Option.of(sendType)));
                              }),
                        ),
                      Failure<SendFormLoaderData>() =>
                        throw UnimplementedError(),
                    };
                  }),
            );
          })),
          if (model.sendType.isSome())
            model.sendType
                .map((sendType) => MaterialPage(
                      child: FlowStep(
                        title: "Choose your Address",
                        widthFactor: .4,
                        body: AssetBalanceFormProvider(
                          multiAddressBalance: sendType.selectedBalance,
                          child: (actions, state) => Column(
                            children: [
                              Builder(
                                builder: (context) =>
                                    SendFormBalanceSuccessHandler(
                                        onSuccess: (_) {
                                  context.flow<SendFlowModel>().update((model) {
                                    final newSendType = SendType(
                                        selectedBalance:
                                            sendType.selectedBalance,
                                        selectedBalanceEntry:
                                            state.balanceInput.value!.entry);
                                    return model.copyWith(
                                        sendType: fp.Option.of(newSendType));
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
                    ))
                .getOrThrow(),
          if (model.sourceAddress.isRight() && _cachedBalances != null)
            MaterialPage(
              child: FlowStep(
                title: "Receipient & Quantity",
                widthFactor: .6,
                body: SendComposeFormProvider(
                  initialEntries: [
                    SendEntryFormModel(
                        destinationInput: const DestinationInput.pure(),
                        quantityInput: const QuantityInput.pure(),
                        balanceSelectorInput: BalanceSelectorInput.dirty(
                            value:
                                model.sendType.toNullable()!.selectedBalance),
                        memoInput: const MemoInput.pure())
                  ],
                  balances: _cachedBalances!,
                  sourceAddress:
                      model.sourceAddress.getOrElse((l) => throw Exception(l)),
                  child: (actions, state) => Builder(builder: (context) {
                    return SendComposeForm(
                      actions: actions,
                      state: state,
                      onComposeResponse: (value) {
                        context.flow<SendFlowModel>().update((model) {
                          return model.copyWith(
                              sendType: fp.Option.of(SendType(
                                  selectedBalance: model.sendType
                                      .toNullable()!
                                      .selectedBalance,
                                  selectedBalanceEntry: model.sendType
                                      .toNullable()!
                                      .selectedBalanceEntry,
                                  composeResponse: value,
                                  sendEntries: state.sendEntries)));
                        });
                      },
                    );
                  }),
                ),
              ),
            ),
          if (model.sendType.isSome() &&
              model.sendType.toNullable()?.composeResponse != null)
            MaterialPage(
              child: FlowStep(
                  title: "Review Send",
                  widthFactor: 1.0,
                  body: BlocProvider(
                      create: (context) => SendReviewFormBloc(),
                      child: Builder(builder: (context) {
                        return SendReviewForm(
                          sendType: model.sendType.toNullable()!,
                          onSignSuccess: () {
                            context.flow<SendFlowModel>().update((model) {
                              return model.copyWith(
                                sendType: fp.Option.of(
                                  // TODO: implement signing
                                  model.sendType.toNullable()!.copyWith(
                                        signedTxHex:
                                            "02000000xcadxc000000000001976a91462e907b17c1d4b80e28614e46f04f2c4167afee88ac00000000",
                                        signedTxHash:
                                            "6a6890705f4fe6d438983ed65d01452a8a8823f1a187982a1745c6b24e4d3409",
                                      ),
                                ),
                              );
                            });
                          },
                        );
                      }))),
            ),
          if (model.sendType.isSome() &&
              model.sendType.toNullable()?.signedTxHex != null)
            MaterialPage(

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
              body: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: TransactionSuccessful(
                txHex: model.sendType.toNullable()!.signedTxHex!,
                txHash: model.sendType.toNullable()!.signedTxHash!,
                title: "Send Successful",
                onClose: () {
                  context.go("/dashboard");
                },
              )),
            )),
        ];
      },
    );
  }
}
