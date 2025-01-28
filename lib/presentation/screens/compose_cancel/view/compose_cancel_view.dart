import 'package:horizon/presentation/forms/cancel_order_form/cancel_order_form_view.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/session/bloc/session_cubit.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_cancel/bloc/compose_cancel_bloc.dart';
import 'package:horizon/presentation/screens/compose_cancel/bloc/compose_cancel_state.dart';
import 'package:horizon/presentation/screens/compose_cancel/bloc/compose_cancel_event.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';

import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/order_repository.dart';
import 'package:horizon/presentation/forms/cancel_order_form/cancel_order_form_bloc.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeCancelPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;

  final String? initialGiveAsset;
  final int? initialGiveQuantity;
  final String? initialGetAsset;
  final int? initialGetQuantity;

  const ComposeCancelPageWrapper({
    required this.composeTransactionUseCase,
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.getFeeEstimatesUseCase,
    required this.assetRepository,
    this.initialGiveAsset,
    this.initialGiveQuantity,
    this.initialGetAsset,
    this.initialGetQuantity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
        success: (state) => BlocProvider(
              key: Key(currentAddress),
              create: (context) => ComposeCancelBloc(
                getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
                logger: GetIt.I.get<Logger>(),
                writelocalTransactionUseCase:
                    GetIt.I.get<WriteLocalTransactionUseCase>(),
                signAndBroadcastTransactionUseCase:
                    GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
                composeTransactionUseCase:
                    GetIt.I.get<ComposeTransactionUseCase>(),
                analyticsService: GetIt.I.get<AnalyticsService>(),
                composeRepository: GetIt.I.get<ComposeRepository>(),
              )..add(AsyncFormDependenciesRequested(
                  currentAddress: currentAddress)),
              child: BlocProvider(
                create: (context) => CancelOrderFormBloc(
                    orderRepository: GetIt.I.get<OrderRepository>(),
                    composeRepository: GetIt.I.get<ComposeRepository>(),
                    onSubmitSuccess: (success) {
                      context
                          .read<ComposeCancelBloc>()
                          .add(ComposeResponseReceived(
                            response: success.response,
                            virtualSize: success.virtualSize,
                            feeRate: success.feeRate,
                          ));
                    },
                    onFormCancelled: () {
                      // TODO: could move this up the tree
                      Navigator.of(context).pop();
                    },
                    getFeeEstimatesUseCase: getFeeEstimatesUseCase,
                    composeTransactionUseCase: composeTransactionUseCase,
                    assetRepository: assetRepository,
                    balanceRepository: GetIt.I.get<BalanceRepository>(),
                    currentAddress: currentAddress)
                  ..add(InitializeForm()),
                child: ComposeCancelPage(
                    getFeeEstimatesUseCase: getFeeEstimatesUseCase,
                    address: currentAddress,
                    dashboardActivityFeedBloc: dashboardActivityFeedBloc,
                    balanceRepository: GetIt.I.get<BalanceRepository>(),
                    assetRepository: GetIt.I.get<AssetRepository>(),
                    initialGiveAsset: initialGiveAsset,
                    initialGiveQuantity: initialGiveQuantity,
                    initialGetAsset: initialGetAsset,
                    initialGetQuantity: initialGetQuantity),
              ),
            ),
        orElse: () => const SizedBox.shrink());
  }
}

class ComposeCancelPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  final String? initialGiveAsset;
  final int? initialGiveQuantity;
  final String? initialGetAsset;
  final int? initialGetQuantity;
  const ComposeCancelPage({
    super.key,
    required this.getFeeEstimatesUseCase,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.balanceRepository,
    required this.assetRepository,
    this.initialGiveAsset,
    this.initialGiveQuantity,
    this.initialGetAsset,
    this.initialGetQuantity,
  });

  @override
  ComposeCancelPageState createState() => ComposeCancelPageState();
}

class ComposeCancelPageState extends State<ComposeCancelPage> {
  void onConfirmationContinue(ComposeCancelResponse composeTransaction, int fee,
      GlobalKey<FormState> formKey) {
    context
        .read<ComposeCancelBloc>()
        .add(ReviewSubmitted(composeTransaction: composeTransaction, fee: fee));
  }

  void onConfirmationBack() {
    context.read<ComposeCancelBloc>().add(ConfirmationBackButtonPressed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeCancelBloc, ComposeCancelState>(
        listener: (context, state) {
      switch (state.submitState) {
        case SubmitSuccess(transactionHex: var txHash):
          widget.dashboardActivityFeedBloc.add(const Load());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txHash));
                },
              ),
              content: Text(txHash),
              behavior: SnackBarBehavior.floating));
        case _:
          break;
      }
    }, builder: (context, state) {
      return switch (state.submitState) {
        FormStep(error: var error) => CancelOrderForm(
            submissionError: error,
          ),
        ReviewStep(
          composeTransaction: var composeTransaction,
          fee: var fee,
          feeRate: var feeRate,
          virtualSize: var virtualSize,
          adjustedVirtualSize: var adjustedVirtualSize,
        ) =>
          ReviewStepView(
              composeTransaction: composeTransaction,
              fee: fee,
              feeRate: feeRate,
              virtualSize: virtualSize,
              adjustedVirtualSize: adjustedVirtualSize,
              buildConfirmationFormFields: (composeTransaction, formKey) {
                final params =
                    (composeTransaction as ComposeCancelResponse).params;

                return [
                  HorizonUI.HorizonTextFormField(
                    label: "Offer Hash",
                    controller: TextEditingController(text: params.offerHash),
                    enabled: false,
                  ),
                ];
              },
              onBack: () {
                onConfirmationBack();
              },
              onContinue: (composeTransaction, fee, formKey) => {
                    onConfirmationContinue(composeTransaction, fee, formKey),
                  }),
        PasswordStep(
          composeTransaction: var composeTransaction,
          fee: var fee,
          error: var error,
          loading: var loading
        ) =>
          PasswordStepView(
            state: state,
            composeTransaction: composeTransaction,
            fee: fee,
            error: error,
            loading: loading,
            onSubmit: (password, formKey) {
              context
                  .read<ComposeCancelBloc>()
                  .add(SignAndBroadcastFormSubmitted(password: password));
            },
            onCancel: () {
              // for now we just go all the way back to step 1
              onConfirmationBack();
            },
          ),
        _ => const SizedBox.shrink(),
      };
    });
  }
}
