import 'package:horizon/presentation/forms/open_order_form/open_order_form_view.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_bloc.dart';
import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_state.dart';
import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_event.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';

import 'package:horizon/domain/entities/compose_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/presentation/forms/open_order_form/open_order_form_bloc.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeRBFPageWrapper extends StatelessWidget {
  final BalanceRepository balanceRepository;
  final BitcoinRepository bitcoinRepository;

  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;
  final ComposeTransactionUseCase composeTransactionUseCase;

  final String txHash;

  const ComposeRBFPageWrapper({
    required this.bitcoinRepository,
    required this.balanceRepository,
    required this.composeTransactionUseCase,
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.getFeeEstimatesUseCase,
    required this.txHash,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
        success: (state) => BlocProvider(
            key: Key(currentAddress),
            create: (context) => ComposeRBFBloc(
                  bitcoinRepository: bitcoinRepository,
                  balanceRepository: balanceRepository,
                  txHash: txHash,
                  currentAddress: currentAddress,
                  getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
                  // logger: GetIt.I.get<Logger>(),
                  // writelocalTransactionUseCase:
                  //     GetIt.I.get<WriteLocalTransactionUseCase>(),
                  // signAndBroadcastTransactionUseCase:
                  //     GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
                  // composeTransactionUseCase:
                  //     GetIt.I.get<ComposeTransactionUseCase>(),
                  // analyticsService: GetIt.I.get<AnalyticsService>(),
                  // composeRepository: GetIt.I.get<ComposeRepository>(),
                )..add(FetchFormData(currentAddress: currentAddress)),
            child: ComposeRBFPage(
              address: currentAddress,
              dashboardActivityFeedBloc: dashboardActivityFeedBloc,
              getFeeEstimatesUseCase: getFeeEstimatesUseCase,
              balanceRepository: balanceRepository,
              
            )),
        orElse: () => const SizedBox.shrink());
  }
}

class ComposeRBFPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  final BalanceRepository balanceRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  const ComposeRBFPage({
    super.key,
    required this.getFeeEstimatesUseCase,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.balanceRepository,
  });

  @override
  ComposeOrderPageState createState() => ComposeOrderPageState();
}

class ComposeOrderPageState extends State<ComposeRBFPage> {
  void onConfirmationContinue(ComposeOrderResponse composeTransaction, int fee,
      GlobalKey<FormState> formKey) {
    context.read<ComposeRBFBloc>().add(FinalizeTransactionEvent(
        composeTransaction: composeTransaction, fee: fee));
  }

  void onConfirmationBack() {
    context.read<ComposeRBFBloc>().add(ConfirmationBackButtonPressed());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeRBFBloc, ReplaceByFeeState>(
        listener: (context, state) {
      switch (state.submitState) {
        case SubmitSuccess(transactionHex: var txHash):
          widget.dashboardActivityFeedBloc.add(const Load());
          // TODO: is it fine to just reload the activity feed?
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
        SubmitInitial(error: var error) => Text(error.toString()),
        SubmitComposingTransaction(
          composeTransaction: var composeTransaction,
          fee: var fee,
          feeRate: var feeRate,
          virtualSize: var virtualSize,
          adjustedVirtualSize: var adjustedVirtualSize,
        ) =>
          ComposeBaseConfirmationPage(
              composeTransaction: composeTransaction,
              fee: fee,
              feeRate: feeRate,
              virtualSize: virtualSize,
              adjustedVirtualSize: adjustedVirtualSize,
              buildConfirmationFormFields: (composeTransaction, formKey) {
                // final params =
                //     (composeTransaction as ComposeOrderResponse).params;

                return [
                  Text("placeholder")

                  // HorizonUI.HorizonTextFormField(
                  //   label: "Give Asset",
                  //   controller: TextEditingController(text: params.giveAsset),
                  //   enabled: false,
                  // ),
                  // HorizonUI.HorizonTextFormField(
                  //   label: "Give Quantity",
                  //   controller: TextEditingController(
                  //       text: params.giveQuantityNormalized),
                  //   enabled: false,
                  // ),
                  // HorizonUI.HorizonTextFormField(
                  //   label: "Get Asset",
                  //   controller: TextEditingController(text: params.getAsset),
                  //   enabled: false,
                  // ),
                  // HorizonUI.HorizonTextFormField(
                  //   label: "Get Quantity",
                  //   controller: TextEditingController(
                  //       text: params.getQuantityNormalized),
                  //   enabled: false,
                  // ),
                ];
              },
              onBack: () {
                onConfirmationBack();
              },
              onContinue: (composeTransaction, fee, formKey) => {
                    onConfirmationContinue(composeTransaction, fee, formKey),
                  }),
        SubmitFinalizing(
          composeTransaction: var composeTransaction,
          fee: var fee,
          error: var error,
          loading: var loading
        ) =>
          ComposeBaseFinalizePage(
            state: state,
            composeTransaction: composeTransaction,
            fee: fee,
            error: error,
            loading: loading,
            onSubmit: (password, formKey) {
              print("sub");
              // context
              //     .read<ComposeOrderBloc>()
              //     .add(SignAndBroadcastTransactionEvent(password: password));
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
