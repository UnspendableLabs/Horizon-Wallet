import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/confirmation_field_with_label.dart';
import 'package:horizon/presentation/common/transactions/quantity_display.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/bloc/create_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser/bloc/create_dispenser_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_form.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';

class CreateDispenserPage extends StatefulWidget {
  final String assetName;
  final List<String> addresses;

  const CreateDispenserPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  State<CreateDispenserPage> createState() => _CreateDispenserPageState();
}

class _CreateDispenserPageState extends State<CreateDispenserPage> {
  MultiAddressBalanceEntry? selectedBalanceEntry;
  MultiAddressBalanceEntry? selectedBtcBalanceEntry;
  TextEditingController giveQuantityController = TextEditingController();
  TextEditingController escrowQuantityController = TextEditingController();
  TextEditingController pricePerUnitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context,
      TransactionState<CreateDispenserData, ComposeDispenserResponseVerbose>
          state) {
    final balances = state.formState.getBalancesOrThrow();

    final giveQuantity = getQuantityForDivisibility(
      divisible: balances.assetInfo.divisible,
      inputQuantity: giveQuantityController.text,
    );

    final escrowQuantity = getQuantityForDivisibility(
      divisible: balances.assetInfo.divisible,
      inputQuantity: escrowQuantityController.text,
    );

    final mainchainrate = getQuantityForDivisibility(
      divisible: true,
      inputQuantity: pricePerUnitController.text,
    );

    context.read<CreateDispenserBloc>().add(CreateDispenserComposed(
          sourceAddress: selectedBalanceEntry?.address ?? "",
          params: CreateDispenserParams(
            asset: widget.assetName,
            giveQuantity: giveQuantity,
            escrowQuantity: escrowQuantity,
            mainchainrate: mainchainrate,
            status: 0,
          ),
        ));
  }

  void _handleConfirmationStepNext(BuildContext context,
      {DecryptionStrategy? decryptionStrategy}) {
    context.read<CreateDispenserBloc>().add(
        CreateDispenserTransactionBroadcasted(
            decryptionStrategy: decryptionStrategy!));
  }

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    context
        .read<CreateDispenserBloc>()
        .add(FeeOptionSelected(feeOption: feeOption));
  }

  void _handleDependenciesRequested(BuildContext context) {
    context
        .read<CreateDispenserBloc>()
        .add(CreateDispenserDependenciesRequested(
          assetName: widget.assetName,
          addresses: widget.addresses,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateDispenserBloc(
        balanceRepository: GetIt.I<BalanceRepository>(),
        getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
        composeTransactionUseCase: GetIt.I<ComposeTransactionUseCase>(),
        composeRepository: GetIt.I<ComposeRepository>(),
        signAndBroadcastTransactionUseCase:
            GetIt.I<SignAndBroadcastTransactionUseCase>(),
        writeLocalTransactionUseCase: GetIt.I<WriteLocalTransactionUseCase>(),
        analyticsService: GetIt.I<AnalyticsService>(),
        logger: GetIt.I<Logger>(),
        settingsRepository: GetIt.I<SettingsRepository>(),
        dispenserRepository: GetIt.I<DispenserRepository>(),
      )..add(CreateDispenserDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<
          CreateDispenserBloc,
          TransactionState<CreateDispenserData,
              ComposeDispenserResponseVerbose>>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<CreateDispenserData,
                ComposeDispenserResponseVerbose>(
              formStepContent: FormStepContent<CreateDispenserData>(
                title: 'Create Dispenser',
                formKey: _formKey,
                onNext: () => _handleOnFormStepNext(context, state),
                onFeeOptionSelected: (feeOption) =>
                    _handleFeeOptionSelected(context, feeOption),
                buildForm: (formState) =>
                    TransactionFormPage<CreateDispenserData>(
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
                      CreateDispenserForm.create(
                    context: context,
                    loading: loading,
                    balances: balances,
                    btcBalances: data?.btcBalances,
                    selectedBalanceEntry: selectedBalanceEntry,
                    selectedBtcBalanceEntry: selectedBtcBalanceEntry,
                    giveQuantityController: giveQuantityController,
                    escrowQuantityController: escrowQuantityController,
                    pricePerUnitController: pricePerUnitController,
                    formKey: _formKey,
                    openDispensers: data?.openDispensers,
                    onBalanceChanged: (value) {
                      setState(() {
                        selectedBalanceEntry = value;
                        selectedBtcBalanceEntry = data?.btcBalances.entries
                            .firstWhere(
                                (entry) => entry.address == value?.address);
                        context.read<CreateDispenserBloc>().add(
                            CreateDispenserAddressSelected(
                                address: value?.address ?? ""));
                      });
                    },
                  ),
                ),
              ),
              confirmationStepContent:
                  ConfirmationStepContent<ComposeDispenserResponseVerbose>(
                title: 'Confirm Transaction',
                buildConfirmationContent: (composeState, onErrorButtonAction) =>
                    TransactionComposePage<ComposeDispenserResponseVerbose>(
                  composeState: composeState,
                  errorButtonText: 'Go back to transaction',
                  onErrorButtonAction: onErrorButtonAction,
                  buildComposeContent: (
                          {ComposeStateSuccess<ComposeDispenserResponseVerbose>?
                              composeState,
                          required bool loading}) =>
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConfirmationFieldWithLabel(
                        label: "Source Address",
                        value: composeState?.composeData.params.source,
                      ),
                      commonHeightSizedBox,
                      ConfirmationFieldWithLabel(
                        label: "Asset",
                        value: composeState?.composeData.params.asset,
                      ),
                      commonHeightSizedBox,
                      QuantityDisplay(
                        label: "Give Quantity",
                        loading: loading,
                        quantity: composeState
                            ?.composeData.params.giveQuantityNormalized,
                      ),
                      commonHeightSizedBox,
                      QuantityDisplay(
                        label: "Escrow Quantity",
                        loading: loading,
                        quantity: composeState
                            ?.composeData.params.escrowQuantityNormalized,
                      ),
                      commonHeightSizedBox,
                      QuantityDisplay(
                        label: "Price Per Unit (BTC)",
                        loading: loading,
                        quantity: satoshisToBtc(composeState
                                    ?.composeData.params.mainchainrate ??
                                0) // won't be null
                            .toStringAsFixed(8),
                      ),
                    ],
                  ),
                ),
                onNext: ({required dynamic decryptionStrategy}) =>
                    _handleConfirmationStepNext(context,
                        decryptionStrategy: decryptionStrategy),
              ),
              state: state,
            ),
          );
        },
      ),
    );
  }
}
