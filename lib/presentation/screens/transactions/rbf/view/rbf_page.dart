import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_bloc.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';

class RBFPage extends StatefulWidget {
  final String txHash;
  final String address;

  const RBFPage({
    super.key,
    required this.txHash,
    required this.address,
  });

  @override
  State<RBFPage> createState() => _RBFPageState();
}

class _RBFPageState extends State<RBFPage> {
  MultiAddressBalanceEntry? selectedBalanceEntry;
  TextEditingController quantityController = TextEditingController();
  TextEditingController destinationAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context, TransactionState<RBFData, MakeRBFResponse> state) {
    //   final balances = state.formState.getBalancesOrThrow();
    //   final quantity = getQuantityForDivisibility(
    //     divisible: balances.assetInfo.divisible,
    //     inputQuantity: quantityController.text,
    //   );
    //   context.read<SendBloc>().add(SendTransactionComposed(
    //         sourceAddress: selectedBalanceEntry?.address ?? "",
    //         params: SendTransactionParams(
    //           destinationAddress: destinationAddressController.text,
    //           asset: widget.assetName,
    //           quantity: quantity,
    //         ),
    //       ));
  }

  void _handleConfirmationStepNext(BuildContext context, {String? password}) {
    // context
    //     .read<SendBloc>()
    //     .add(SendTransactionBroadcasted(password: password));
  }

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    // context.read<SendBloc>().add(FeeOptionSelected(feeOption: feeOption));
  }

  void _handleDependenciesRequested(BuildContext context) {
    // context.read<SendBloc>().add(SendDependenciesRequested(
    //       assetName: widget.assetName,
    //       addresses: widget.addresses,
    //     ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RBFBloc(
        getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
        bitcoinRepository: GetIt.I<BitcoinRepository>(),
        signAndBroadcastTransactionUseCase:
            GetIt.I<SignAndBroadcastTransactionUseCase>(),
        writelocalTransactionUseCase: GetIt.I<WriteLocalTransactionUseCase>(),
        analyticsService: GetIt.I<AnalyticsService>(),
        logger: GetIt.I<Logger>(),
        settingsRepository: GetIt.I<SettingsRepository>(),
        transactionService: GetIt.I<TransactionService>(),
      )..add(RBFDependenciesRequested(
          txHash: widget.txHash, address: widget.address)),
      child: BlocConsumer<RBFBloc, TransactionState<RBFData, MakeRBFResponse>>(
        listener: (context, state) {
          // TODO: Implement listener
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<RBFData, MakeRBFResponse>(
              formStepContent: FormStepContent<RBFData>(
                title: 'Accelerate Transaction',
                formKey: _formKey,
                onNext: () => _handleOnFormStepNext(context, state),
                onFeeOptionSelected: (feeOption) =>
                    _handleFeeOptionSelected(context, feeOption),
                buildForm: (formState) => TransactionFormPage<RBFData>(
                  errorButtonText: 'Reload',
                  formState: formState,
                  onErrorButtonAction: () =>
                      _handleDependenciesRequested(context),
                  onFeeOptionSelected: (feeOption) =>
                      _handleFeeOptionSelected(context, feeOption),
                  form: (
                          {balances,
                          feeEstimates,
                          data,
                          feeOption,
                          required loading}) =>
                      Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        HorizonTextField(
                          enabled: false,
                          label: 'Transaction Hash',
                          controller:
                              TextEditingController(text: data?.tx.txid),
                        ),
                        commonHeightSizedBox,
                        HorizonTextField(
                          enabled: false,
                          label: 'Fee',
                          controller: TextEditingController(
                              text: data?.tx.fee.toString()),
                        ),
                        commonHeightSizedBox,
                        HorizonTextField(
                          enabled: false,
                          label: 'Fee Rate',
                          controller: TextEditingController(
                              text: data != null
                                  ? "${(data.tx.fee / data.adjustedSize).toStringAsFixed(2)} sats/vB"
                                  : ""),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              confirmationStepContent: ConfirmationStepContent<MakeRBFResponse>(
                title: 'Confirm Transaction',
                buildConfirmationContent: (composeState, onErrorButtonAction) =>
                    TransactionComposePage<MakeRBFResponse>(
                  composeState: composeState,
                  errorButtonText: 'Go back to transaction',
                  onErrorButtonAction: onErrorButtonAction,
                  buildComposeContent: (
                          {ComposeStateSuccess<MakeRBFResponse>? composeState,
                          required bool loading}) =>
                      const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // QuantityDisplay(
                      //   loading: loading,
                      //   quantity:
                      //       composeState?.composeData.params.quantityNormalized,
                      // ),
                      // commonHeightSizedBox,
                      // ConfirmationFieldWithLabel(
                      //   loading: loading,
                      //   label: 'Token Name',
                      //   value: composeState?.composeData.params.asset != null
                      //       ? displayAssetName(
                      //           composeState!.composeData.params.asset,
                      //           composeState
                      //               .composeData.params.assetInfo.assetLongname)
                      //       : null,
                      // ),
                      // commonHeightSizedBox,
                      // ConfirmationFieldWithLabel(
                      //   loading: loading,
                      //   label: 'Source Address',
                      //   value: composeState?.composeData.params.source,
                      // ),
                      // commonHeightSizedBox,
                      // ConfirmationFieldWithLabel(
                      //   loading: loading,
                      //   label: 'Recipient Address',
                      //   value: composeState?.composeData.params.destination,
                      // ),
                    ],
                  ),
                ),
                onNext: ({String? password}) =>
                    _handleConfirmationStepNext(context, password: password),
              ),
              state: state,
            ),
          );
        },
      ),
    );
  }
}
