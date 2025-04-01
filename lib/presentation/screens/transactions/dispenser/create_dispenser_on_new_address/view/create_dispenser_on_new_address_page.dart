import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/transactions/gradient_quantity_input.dart';
import 'package:horizon/presentation/common/transactions/token_name_field.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/bloc/create_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/bloc/create_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/dispenser_mult_address_balance_dropdown.dart';

class CreateDispenserOnNewAddressPage extends StatefulWidget {
  final String assetName;
  final List<String> addresses;

  const CreateDispenserOnNewAddressPage({
    super.key,
    required this.assetName,
    required this.addresses,
  });

  @override
  State<CreateDispenserOnNewAddressPage> createState() =>
      _CreateDispenserOnNewAddressPageState();
}

class _CreateDispenserOnNewAddressPageState
    extends State<CreateDispenserOnNewAddressPage> {
  MultiAddressBalanceEntry? selectedBalanceEntry;
  MultiAddressBalanceEntry? selectedBtcBalanceEntry;
  TextEditingController giveQuantityController = TextEditingController();
  TextEditingController escrowQuantityController = TextEditingController();
  // TextEditingController destinationAddressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context,
      TransactionState<CreateDispenserOnNewAddressData,
              ComposeDispenserResponseVerbose>
          state) {
    // final balances = state.formState.getBalancesOrThrow();
    // final quantity = getQuantityForDivisibility(
    //   divisible: balances.assetInfo.divisible,
    //   inputQuantity: quantityController.text,
    // );
    // context.read<SendBloc>().add(SendTransactionComposed(
    //       sourceAddress: selectedBalanceEntry?.address ?? "",
    //       params: SendTransactionParams(
    //         destinationAddress: destinationAddressController.text,
    //         asset: widget.assetName,
    //         quantity: quantity,
    //       ),
    //     ));
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
      create: (context) => CreateDispenserOnNewAddressBloc(
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
      )..add(CreateDispenserOnNewAddressDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<
          CreateDispenserOnNewAddressBloc,
          TransactionState<CreateDispenserOnNewAddressData,
              ComposeDispenserResponseVerbose>>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<CreateDispenserOnNewAddressData,
                ComposeDispenserResponseVerbose>(
              formStepContent: FormStepContent<CreateDispenserOnNewAddressData>(
                title: 'Create Dispenser on New Address',
                formKey: _formKey,
                onNext: () => _handleOnFormStepNext(context, state),
                onFeeOptionSelected: (feeOption) =>
                    _handleFeeOptionSelected(context, feeOption),
                buildForm: (formState) =>
                    TransactionFormPage<CreateDispenserOnNewAddressData>(
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
                        DispenserMultiAddressBalanceDropdown(
                          loading: loading,
                          balances: balances,
                          btcBalances: data?.btcBalances,
                          onChanged: (value) {
                            setState(() {
                              selectedBalanceEntry = value;
                              selectedBtcBalanceEntry = data
                                  ?.btcBalances.entries
                                  .firstWhere((entry) =>
                                      entry.address == value?.address);
                            });
                          },
                          selectedValue: selectedBalanceEntry,
                        ),
                        commonHeightSizedBox,
                        TokenNameField(
                          loading: loading,
                          balance: balances,
                          selectedBalanceEntry: selectedBalanceEntry,
                        ),
                        commonHeightSizedBox,
                        GradientQuantityInput(
                          enabled: !loading,
                          showMaxButton: true,
                          balance: balances,
                          selectedBalanceEntry: selectedBalanceEntry,
                          controller: giveQuantityController,
                          label: 'Give Quantity',
                        ),
                        commonHeightSizedBox,
                        GradientQuantityInput(
                          enabled: !loading,
                          showMaxButton: true,
                          balance: balances,
                          selectedBalanceEntry: selectedBalanceEntry,
                          controller: escrowQuantityController,
                          label: 'Escrow Quantity',
                        ),
                        // MultiAddressBalanceDropdown(
                        //   loading: loading,
                        //   balances: balances,
                        //   onChanged: (value) {
                        //     setState(() {
                        //       selectedBalanceEntry = value;
                        //       quantityController.clear();
                        //     });
                        //   },
                        //   selectedValue: selectedBalanceEntry,
                        // ),
                        // commonHeightSizedBox,
                        // HorizonTextField(
                        //   enabled: !loading,
                        //   controller: destinationAddressController,
                        //   label: 'Destination Address',
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter a destination address';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // commonHeightSizedBox,
                        // TokenNameField(
                        //   loading: loading,
                        //   balance: balances,
                        //   selectedBalanceEntry: selectedBalanceEntry,
                        // ),
                        // commonHeightSizedBox,
                        // GradientQuantityInput(
                        //   enabled: !loading,
                        //   showMaxButton: true,
                        //   balance: balances,
                        //   selectedBalanceEntry: selectedBalanceEntry,
                        //   controller: quantityController,
                        //   validator: (value) {
                        //     if (balances == null) {
                        //       return null;
                        //     }
                        //     if (value == null || value.isEmpty) {
                        //       return 'Please enter an amount';
                        //     }

                        //     if (selectedBalanceEntry != null) {
                        //       try {
                        //         final enteredQuantity =
                        //             getQuantityForDivisibility(
                        //           divisible: balances.assetInfo.divisible,
                        //           inputQuantity: value,
                        //         );

                        //         if (enteredQuantity >
                        //             selectedBalanceEntry!.quantity) {
                        //           return 'Insufficient balance';
                        //         }
                        //       } catch (e) {
                        //         return 'Invalid amount';
                        //       }
                        //     }

                        //     return null;
                        //   },
                        // ),
                      ],
                    ),
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
