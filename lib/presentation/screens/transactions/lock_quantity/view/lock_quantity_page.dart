import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/confirmation_field_with_label.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/lock_quantity/bloc/lock_quantity_bloc.dart';
import 'package:horizon/presentation/screens/transactions/lock_quantity/bloc/lock_quantity_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';

class LockQuantityPage extends StatefulWidget {
  final String assetName;
  final List<String> addresses;

  const LockQuantityPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  State<LockQuantityPage> createState() => _LockQuantityPageState();
}

class _LockQuantityPageState extends State<LockQuantityPage> {
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context,
      TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>
          state) {
    final loading = state.formState.isLoading;
    if (loading) {
      return;
    }
    final balances = state.formState.getBalancesOrThrow();
    final ownerBalanceEntry =
        state.formState.getDataOrThrow().ownerBalanceEntry;

    context.read<LockQuantityBloc>().add(LockQuantityTransactionComposed(
          sourceAddress: ownerBalanceEntry.address!,
          params: ComposeIssuanceParams(
            source: ownerBalanceEntry.address!,
            name: displayAssetName(
                widget.assetName, balances.assetInfo.assetLongname),
            quantity: ownerBalanceEntry.quantity,
            divisible: balances.assetInfo.divisible,
            lock: true,
            reset: false,
            description: balances.assetInfo.description,
          ),
        ));
  }

  void _handleConfirmationStepNext(BuildContext context, {String? password}) {
    context
        .read<LockQuantityBloc>()
        .add(LockQuantityTransactionBroadcasted(password: password));
  }

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    context
        .read<LockQuantityBloc>()
        .add(FeeOptionSelected(feeOption: feeOption));
  }

  void _handleDependenciesRequested(BuildContext context) {
    context.read<LockQuantityBloc>().add(LockQuantityDependenciesRequested(
          assetName: widget.assetName,
          addresses: widget.addresses,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LockQuantityBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
        getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
        composeTransactionUseCase: GetIt.I<ComposeTransactionUseCase>(),
        composeRepository: GetIt.I<ComposeRepository>(),
        signAndBroadcastTransactionUseCase:
            GetIt.I<SignAndBroadcastTransactionUseCase>(),
        writelocalTransactionUseCase: GetIt.I<WriteLocalTransactionUseCase>(),
        analyticsService: GetIt.I<AnalyticsService>(),
        logger: GetIt.I<Logger>(),
        settingsRepository: GetIt.I<SettingsRepository>(),
      )..add(LockQuantityDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<LockQuantityBloc,
          TransactionState<LockQuantityData, ComposeIssuanceResponseVerbose>>(
        listener: (context, state) {
          // Listener
        },
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<LockQuantityData,
                ComposeIssuanceResponseVerbose>(
              formStepContent: FormStepContent<LockQuantityData>(
                title: 'Lock Supply',
                formKey: _formKey,
                onNext: () => _handleOnFormStepNext(context, state),
                onFeeOptionSelected: (feeOption) =>
                    _handleFeeOptionSelected(context, feeOption),
                buildForm: (formState) => TransactionFormPage<LockQuantityData>(
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
                        required loading}) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            HorizonTextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: loading
                                      ? ''
                                      : data!.ownerBalanceEntry.address),
                              label: 'Source Address',
                            ),
                            commonHeightSizedBox,
                            TokenNameField(
                              loading: loading,
                              balance: balances,
                              selectedBalanceEntry:
                                  loading ? null : data!.ownerBalanceEntry,
                            ),
                            commonHeightSizedBox,
                            HorizonTextField(
                              enabled: false,
                              controller: TextEditingController(
                                  text: loading
                                      ? ''
                                      : data!.ownerBalanceEntry
                                          .quantityNormalized),
                              label: 'Current Supply',
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              confirmationStepContent:
                  ConfirmationStepContent<ComposeIssuanceResponseVerbose>(
                title: 'Confirm Lock Supply Transaction',
                buildConfirmationContent: (composeState, onErrorButtonAction) =>
                    TransactionComposePage<ComposeIssuanceResponseVerbose>(
                  composeState: composeState,
                  errorButtonText: 'Go back to transaction',
                  onErrorButtonAction: onErrorButtonAction,
                  buildComposeContent: (
                          {ComposeStateSuccess<ComposeIssuanceResponseVerbose>?
                              composeState,
                          required bool loading}) =>
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConfirmationFieldWithLabel(
                        loading: loading,
                        label: 'Token Name',
                        value: composeState?.composeData.params.asset,
                      ),
                      commonHeightSizedBox,
                      ConfirmationFieldWithLabel(
                        loading: loading,
                        label: 'Quantity',
                        value:
                            composeState?.composeData.params.quantityNormalized,
                      ),
                      commonHeightSizedBox,
                      ConfirmationFieldWithLabel(
                        loading: loading,
                        label: 'Locked',
                        value: composeState?.composeData.params.lock.toString(),
                      ),
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
