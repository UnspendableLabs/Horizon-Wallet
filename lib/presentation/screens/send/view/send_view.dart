import 'package:equatable/equatable.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:flutter/services.dart';
import 'package:horizon/presentation/common/transactions/success_animation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:fpdart/fpdart.dart' show Option;
import 'package:go_router/go_router.dart';
import 'package:horizon/domain/entities/compose_response.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/remote_data.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';
import 'package:horizon/extensions.dart';
import 'package:horizon/presentation/common/transactions/transaction_successful.dart';
import 'package:horizon/presentation/common/transactions/transaction_error.dart';
import 'package:horizon/presentation/common/remote_data_builder.dart';
import 'package:horizon/presentation/forms/asset_balance_form/asset_balance_form_view.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/screens/send/bloc/send_compose_form_bloc.dart';
import 'package:horizon/presentation/screens/send/bloc/send_entry_form_bloc.dart';
import 'package:horizon/presentation/screens/send/forms/send_compose_form.dart';
import 'package:horizon/presentation/screens/send/forms/send_form_token_selector.dart';
import 'package:horizon/presentation/screens/send/forms/send_review_form.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/utils/app_icons.dart';

class SendFlowComposeStep {
  final List<SendEntryFormModel> sendEntries;
  final ComposeResponse composeResponse;

  const SendFlowComposeStep({
    required this.sendEntries,
    required this.composeResponse,
  });
}

class SendFlowConfirmationStep {
  final String psbtHex;

  const SendFlowConfirmationStep({
    required this.psbtHex,
  });
}

class SendFlowModel extends Equatable {
  final Option<MultiAddressBalance> balance; // step1
  final Option<String> address; // step2
  final Option<SendFlowComposeStep> composeStep; // step3
  final Option<SendFlowConfirmationStep> confirmationStep; // step4

  const SendFlowModel({
    required this.balance,
    required this.address,
    required this.composeStep,
    required this.confirmationStep,
  });

  @override
  List<Object?> get props => [balance, address, composeStep, confirmationStep];

  SendFlowModel copyWith(
          {Option<MultiAddressBalance>? balance,
          Option<String>? address,
          Option<SendFlowComposeStep>? composeStep,
          Option<SendFlowConfirmationStep>? confirmationStep}) =>
      SendFlowModel(
          balance: balance ?? this.balance,
          address: address ?? this.address,
          composeStep: composeStep ?? this.composeStep,
          confirmationStep: confirmationStep ?? this.confirmationStep);
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
  SvgPicture? _preloadedSvg;

  @override
  void initState() {
    super.initState();
    _controller = SendFlowController(
        initialState: const SendFlowModel(
            balance: Option.none(),
            address: Option.none(),
            composeStep: Option.none(),
            confirmationStep: Option.none()));
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
              trailing: IconButton(
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
                  leading: Builder(builder: (context) {
                    return IconButton(
                        onPressed: () {
                          context.flow<SendFlowModel>().update((model) =>
                              model.copyWith(balance: Option.none()));
                        },
                        icon: AppIcons.backArrowIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        ));
                  }),
                  trailing: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: AppIcons.closeIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      )),
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
                  title: "Recipient & Quantity",
                  widthFactor: .6,
                  leading: Builder(builder: (context) {
                    return IconButton(
                        onPressed: () {
                          context.flow<SendFlowModel>().update((model) =>
                              model.copyWith(address: Option.none()));
                        },
                        icon: AppIcons.backArrowIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        ));
                  }),
                  trailing: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: AppIcons.closeIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      )),
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
                              return model.copyWith(
                                composeStep: Option.of(SendFlowComposeStep(
                                  sendEntries: state.sendEntries,
                                  composeResponse: value,
                                )),
                              );
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
          model.composeStep.map((composeStep) => MaterialPage(
                child: FlowStep(
                  title: "Review Send",
                  leading: Builder(builder: (context) {
                    return IconButton(
                        onPressed: () {
                          context.flow<SendFlowModel>().update((model) =>
                              model.copyWith(composeStep: const Option.none()));
                        },
                        icon: AppIcons.backArrowIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        ));
                  }),
                  trailing: IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: AppIcons.closeIcon(
                        context: context,
                        width: 24,
                        height: 24,
                        fit: BoxFit.fitHeight,
                      )),
                  widthFactor: 1.0,
                  body: SendReviewFormProvider(
                      composeResponse: switch (composeStep.composeResponse) {
                        ComposeMpmaSendResponse resp => ComposeSendMpma(resp),
                        ComposeSendResponse resp => ComposeSendSingle(resp),
                        _ => throw Exception(
                            "Invalid compose response type: ${composeStep.composeResponse.runtimeType}"),
                      },
                      sendEntries: composeStep.sendEntries,
                      child: (actions, state) => Builder(builder: (context) {
                            return Column(
                              children: [
                                SendReviewSignHandler(
                                    onSuccess: (signedPsbt) {
                                      context
                                          .flow<SendFlowModel>()
                                          .update((model) {
                                        return model.copyWith(
                                          confirmationStep: Option.of(
                                            SendFlowConfirmationStep(
                                                psbtHex: signedPsbt),
                                          ),
                                        );
                                      });
                                    },
                                    onClose: () {
                                      actions.onCloseSignModalClicked();
                                    },
                                    address: model.address.getOrThrow()),

                                // SendReviewFormSuccessHandler(
                                //   onSuccess: (confirmationStep) {
                                //     context
                                //         .flow<SendFlowModel>()
                                //         .update((model) {
                                //       return model.copyWith(
                                //         confirmationStep:
                                //             fp.Option.of(confirmationStep),
                                //       );
                                //     });
                                //   },
                                // ),
                                SendReviewForm(
                                  state: state,
                                  actions: actions,
                                ),
                              ],
                            );
                          })),
                ),
              )),
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
                      child: RemoteDataTaskEitherBuilder(
                          task: TaskEither<String, String>.Do(($) async {
                        final finalizedTx = await $(TaskEither.fromEither(
                            GetIt.I<TransactionService>()
                                .finalizePsbtAndExtractTransactionT(
                                    psbtHex: confirmationStep.psbtHex,
                                    onError: (e, _) => e.toString())));

                        final hash = $(GetIt.I<BitcoindService>()
                            .sendrawtransactionT(
                                signedHex: finalizedTx,
                                httpConfig: session.httpConfig,
                                onError: (e, _) => e.toString())
                            .minimumDuration(Duration(seconds: 2)));

                        return hash;
                      }), builder: (context, state, retry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: state.fold3(
                                  onNone: () => Center(
                                    child:  Lottie.asset(
                                            "assets/lottie/txn_success_anim.json",
                                            width: 127,
                                            key: const ValueKey('lottie'),
                                          )
                                  ),
                                  onReplete: (_) => Center(
                                    child: TxnSuccessAnimation()
                                    // SvgPicture.asset(
                                    //   "assets/icons/txn_success_check.svg",
                                    //   width: 127,
                                    //   key: const ValueKey('svg'),
                                    //   colorBlendMode: BlendMode.srcOver,
                                    //   fit: BoxFit.contain,
                                    // ),
                                  ),
                                  onFailure: (err) => TransactionError(
                                    errorMessage: err.toString(),
                                    onErrorButtonAction: retry,
                                    buttonText: "Retry",
                                  ),
                                )),
                            commonHeightSizedBox,
                            state.fold3(
                              onNone: () => Text(
                                "Broadcasting...",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              onFailure: (_) => SizedBox.shrink(),
                              onReplete: (hash) => Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Broadcast Success",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!),
                                ],
                              ),
                            ),
                            commonHeightSizedBox,
                            commonHeightSizedBox,
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14.0),
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: Theme.of(context)
                                          .inputDecorationTheme
                                          .outlineBorder
                                          ?.color ??
                                      transparentBlack8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Transaction id: ',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.color,
                                                  ),
                                            ),
                                            TextSpan(
                                              text: state.fold3(
                                                  onNone: () => '',
                                                  onFailure: (_) => '',
                                                  onReplete: (hash) =>
                                                      hash.replaceRange(
                                                          6,
                                                          hash.length - 6,
                                                          '...')),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.color,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.visible,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: TextButton(
                                      style: Theme.of(context)
                                          .textButtonTheme
                                          .style
                                          ?.copyWith(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                              transparentPurple8,
                                            ),
                                            padding: WidgetStateProperty.all(
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 12),
                                            ),
                                          ),
                                      onPressed: state.fold3(
                                          onNone: () => () {},
                                          onFailure: (_) => () {},
                                          onReplete: (hash) => () {
                                                Clipboard.setData(
                                                    ClipboardData(text: hash));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Tx id copied to clipboard'),
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ),
                                                );
                                              }),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AppIcons.copyIcon(
                                            context: context,
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'COPY',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            HorizonButton(
                              onPressed: state.fold3(
                                  onNone: () => () {},
                                  onFailure: (_) => () {},
                                  onReplete: (hash) => () {
                                        _launchExplorer(
                                            hash, session.httpConfig);
                                      }),
                              disabled: state.fold3(
                                onNone: () => true,
                                onFailure: (_) => true,
                                onReplete: (_) => false,
                              ),
                              child:
                                  TextButtonContent(value: "View Transaction"),
                              variant: ButtonVariant.black,
                            ),
                            commonHeightSizedBox,
                            HorizonButton(
                              onPressed: () {
                                print("asf");
                              },
                              child: TextButtonContent(value: "Close"),
                              disabled: state.fold3(
                                onNone: () => true,
                                onFailure: (_) => true,
                                onReplete: (_) => false,
                              ),
                              variant: ButtonVariant.black,
                            ),
                          ],
                        );

                        // return switch (state) {
                        //   Loading() => AnimatedSwitcher(
                        //         child: Lottie.asset(
                        //       "assets/lottie/txn_success_anim.json",
                        //       width: 127,
                        //       key: const ValueKey('lottie'),
                        //     )),
                        //   _ => Text(state.toString())
                        // };
                        return Text(state.toString());
                      })))))
        ]
            .filter((page) => page.isSome())
            .map((page) => page.getOrThrow())
            .toList();
      },
    );
  }

  Future<void> _launchExplorer(
    String hash,
    HttpConfig httpConfig,
  ) async {
    final uri = Uri.parse("${httpConfig.btcExplorer}/tx/$hash");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }
}
