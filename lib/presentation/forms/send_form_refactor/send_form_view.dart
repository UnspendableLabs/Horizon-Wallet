import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import "package:fpdart/fpdart.dart" as fp;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import "package:horizon/presentation/forms/base/base_form_state.dart";
// TODO: not sure if this should live here

import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/utils/app_icons.dart';

import "./loader/loader_bloc.dart";
import "./form/bloc/form_bloc.dart";
import 'package:horizon/domain/entities/compose_send.dart';

// TODO: do something with transaction error;

import "./form/form_view.dart";
import 'package:horizon/presentation/forms/base/flow/view/flow_step.dart';
import 'package:horizon/presentation/forms/base/flow/view/flow.dart';
import 'package:horizon/presentation/forms/base/review/review_view.dart';
import 'package:horizon/presentation/forms/base/sign/sign_provider.dart';

import "./sign/sign_view.dart";
import 'package:horizon/domain/entities/asset.dart';

extension OptionGetOrThrow<T> on fp.Option<T> {
  T getOrThrow([String? message = "invariant: isNone"]) {
    return match(
      () => throw Exception(message),
      (value) => value,
    );
  }
}

class SendFormProvider extends StatelessWidget {
  final String assetName;
  final List<String> addresses;

  const SendFormProvider({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SendAssetFormLoaderBloc(
        loader: SendAssetFormLoader(
          balanceRepository: GetIt.I<BalanceRepository>(),
          feeEstimatesRepository: GetIt.I<FeeEstimatesRespository>(),
        ),
      )..load(SendAssetFormLoaderArgs(
          assetName: assetName,
          addresses: addresses,
        )),
      child: const SendAssetFlow(),
    );
  }
}

class SendAssetFlow extends StatelessWidget {
  const SendAssetFlow({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SendAssetFormLoaderBloc,
            BaseFormState<SendAssetFormLoaderData>>(
        listener: (context, state) {},
        builder: (context, state) {
          return switch (state) {
            Loading() => const Center(child: CircularProgressIndicator()),
            Success(value: var data) => BlocProvider(
                create: (context) => SendAssetFormBloc(
                    feeEstimates: data.feeEstimates,
                    asset: Asset(
                        asset: data.multiAddressBalance.asset,
                        divisible:
                            data.multiAddressBalance.assetInfo.divisible),
                    initialAddressBalanceValue:
                        data.multiAddressBalance.entries.first),
                child: TransactionFlowView<ComposeSendResponse>(
                  formView: (context) => FlowStep(
                    title: "Send asset",
                    widthFactor: .33,
                    leading: AppIcons.iconButton(
                        context: context,
                        width: 32,
                        height: 32,
                        icon: AppIcons.backArrowIcon(
                          context: context,
                          width: 24,
                          height: 24,
                          fit: BoxFit.fitHeight,
                        ),
                        onPressed: () {
                          context
                              .go("/asset/${data.multiAddressBalance.asset}");
                        }),
                    body: SendAssetFormBody(
                      multiAddressBalance: data.multiAddressBalance,
                      feeEstimates: data.feeEstimates,
                      onSubmitSuccess: (formState) {
                        context
                            .flow<TransactionFlowModel<ComposeSendResponse>>()
                            .update((model) => model.copyWith(
                                composeResponse: fp.Option.fromNullable(
                                    formState.composeResponse)));
                      },
                    ),
                  ),
                  signView: (context) => FlowStep(
                      title: "Sign And Submit",
                      widthFactor: .66,
                      leading: AppIcons.iconButton(
                          context: context,
                          width: 32,
                          height: 32,
                          icon: AppIcons.backArrowIcon(
                            context: context,
                            width: 24,
                            height: 24,
                            fit: BoxFit.fitHeight,
                          ),
                          onPressed: () {
                            context
                                .flow<
                                    TransactionFlowModel<ComposeSendResponse>>()
                                .update((model) => model.copyWith(
                                      composeResponse: const fp.Option.none(),
                                    ));
                          }),
                      body: SignProvider(
                          name: "send",
                          composeResponse: context
                              .flow<TransactionFlowModel<ComposeSendResponse>>()
                              .state
                              .composeResponse
                              .getOrThrow(),
                          getSource: (composeResponse) =>
                              composeResponse.params.source,
                          child: SignView(
                              composeResponse: context
                                  .flow<
                                      TransactionFlowModel<
                                          ComposeSendResponse>>()
                                  .state
                                  .composeResponse
                                  .getOrThrow(),
                              onSubmitSuccess: (txHex, txHash) {
                                context
                                    .flow<
                                        TransactionFlowModel<
                                            ComposeSendResponse>>()
                                    .update((model) => model.copyWith(
                                          submitSuccess: fp.Option.of(
                                            SubmitSuccess(
                                              hex: txHex,
                                              hash: txHash,
                                            ),
                                          ),
                                        ));
                              }))),
                  reviewView: (context) => FlowStep(
                      title: "Review",
                      widthFactor: .66,
                      leading: AppIcons.iconButton(
                          context: context,
                          width: 32,
                          height: 32,
                          icon: AppIcons.backArrowIcon(
                            context: context,
                            width: 24,
                            height: 24,
                            fit: BoxFit.fitHeight,
                          ),
                          onPressed: () {
                            context
                                .go("/asset/${data.multiAddressBalance.asset}");
                          }),
                      body: Builder(builder: (context) {
                        final submitSuccess = context
                            .flow<TransactionFlowModel<ComposeSendResponse>>()
                            .state
                            .submitSuccess
                            .getOrThrow();
                        return ReviewView(
                            txHex: submitSuccess.hex,
                            txHash: submitSuccess.hash);
                      })),
                )),
            _ => Text(state.toString())
          };
        });
  }
}
