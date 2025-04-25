import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import "package:horizon/domain/repositories/fee_estimates_repository.dart";
import 'package:horizon/domain/entities/fee_estimates.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import "package:horizon/presentation/forms/base/base_form_state.dart";
import "package:horizon/presentation/forms/base/view/base_form_view.dart";
import "package:horizon/presentation/forms/base/base_form_event.dart";
import 'package:horizon/presentation/common/redesign_colors.dart';
import 'package:horizon/presentation/common/transactions/multi_address_balance_dropdown.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
// TODO: not sure if this should live here
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/domain/entities/multi_address_balance.dart';

import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/utils/app_icons.dart';

import "./loader/loader_bloc.dart";
import "./form/bloc/form_bloc.dart";
import "./form/bloc/form_state.dart";
import "./form/bloc/form_event.dart";
import 'package:horizon/domain/entities/compose_send.dart';

// TODO: do something with transaction error;
import 'package:horizon/presentation/common/transactions/transaction_fee_selection.dart';
import 'package:horizon/domain/entities/compose_send.dart';

import "generic.dart";
import "./form/form_view.dart";
import "./review/review_view.dart";
import 'package:horizon/domain/entities/asset.dart';

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
                                context.go(
                                    "/asset/${data.multiAddressBalance.asset}");
                              }),
                          body: SendAssetFormBody(
                            multiAddressBalance: data.multiAddressBalance,
                            feeEstimates: data.feeEstimates,
                            onSubmitSuccess: (formState) {
                              context
                                  .flow<
                                      TransactionFlowModel<
                                          ComposeSendResponse>>()
                                  .update((_model) => TransactionFlowModel(
                                        composeResponse:
                                            formState.composeResponse,
                                      ));
                            },
                          ),
                        ),
                    reviewView: (context) => FlowStep(
                        title: "Review Transaction",
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
                                      TransactionFlowModel<
                                          ComposeSendResponse>>()
                                  .update((_model) => TransactionFlowModel(
                                      composeResponse: null));
                            }),
                        body: ReviewView(
                            composeResponse: context
                                .flow<
                                    TransactionFlowModel<ComposeSendResponse>>()
                                .state
                                .composeResponse!))),
              ),
            _ => Text(state.toString())
          };
        });
  }
}
