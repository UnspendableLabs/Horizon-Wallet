import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/entities/multi_address_balance_entry.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_form.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/bloc/create_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/transactions/dispenser/create_dispenser_on_new_address/bloc/create_dispenser_on_new_address_event.dart';

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
  bool sendExtraBtcToDispenser = false;
  TextEditingController giveQuantityController = TextEditingController();
  TextEditingController escrowQuantityController = TextEditingController();
  TextEditingController pricePerUnitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context,
      TransactionState<CreateDispenserOnNewAddressData,
              ComposeChainedDispenserResponse>
          state) async {
    final requirePassword =
        GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations;
    DecryptionStrategy? decryptionStrategy;

    if (requirePassword) {
      bool isAuthenticated = false;
      String? errorText;
      bool isLoading = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return HorizonPasswordPrompt(
                onPasswordSubmitted: (password) async {
                  setState(() {
                    isLoading = true;
                    errorText = null;
                  });
                  try {
                    final wallet =
                        await GetIt.I<WalletRepository>().getCurrentWallet();
                    await GetIt.I<EncryptionService>()
                        .decrypt(wallet!.encryptedPrivKey, password);
                  } catch (e) {
                    if (dialogContext.mounted) {
                      setState(() {
                        errorText = 'Invalid Password';
                        isLoading = false;
                      });
                    }
                    return;
                  }

                  decryptionStrategy = Password(password);

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                onCancel: () {
                  setState(() {
                    errorText = null;
                    isLoading = false;
                  });
                  Navigator.of(dialogContext).pop();
                },
                buttonText: 'Continue',
                title: 'Enter Password',
                errorText: errorText,
                isLoading: isLoading,
              );
            },
          );
        },
      ).then((value) {
        isAuthenticated = (value == true);
      });

      if (!isAuthenticated) {
        return;
      }
    } else {
      decryptionStrategy = InMemoryKey();
    }
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

    if (decryptionStrategy == null) {
      throw Exception("invariant: invalid state"); // TODO: fix this
    }

    // ignore: use_build_context_synchronously
    context
        .read<CreateDispenserOnNewAddressBloc>()
        .add(CreateDispenserOnNewAddressComposed(
          decryptionStrategy: decryptionStrategy!,
          sourceAddress: selectedBalanceEntry?.address ?? "",
          params: CreateDispenserOnNewAddressParams(
            divisible: balances.assetInfo.divisible,
            asset: widget.assetName,
            giveQuantity: giveQuantity,
            escrowQuantity: escrowQuantity,
            mainchainrate: mainchainrate,
            sendExtraBtcToDispenser: sendExtraBtcToDispenser,
          ),
        ));
  }

  void _handleConfirmationStepNext(BuildContext context,
      {String? decryptionStrategy}) {
    // context
    //     .read<SendBloc>()
    //     .add(SendTransactionBroadcasted(password: password));
  }

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    context
        .read<CreateDispenserOnNewAddressBloc>()
        .add(FeeOptionSelected(feeOption: feeOption));
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
        walletRepository: GetIt.I<WalletRepository>(),
        addressRepository: GetIt.I<AddressRepository>(),
        accountRepository: GetIt.I<AccountRepository>(),
        encryptionService: GetIt.I<EncryptionService>(),
        addressService: GetIt.I<AddressService>(),
        dispenserRepository: GetIt.I<DispenserRepository>(),
        transactionService: GetIt.I<TransactionService>(),
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        utxoRepository: GetIt.I<UtxoRepository>(),
        bitcoindService: GetIt.I<BitcoindService>(),
        errorService: GetIt.I<ErrorService>(),
        signChainedTransactionUseCase: GetIt.I<SignChainedTransactionUseCase>(),
      )..add(CreateDispenserOnNewAddressDependenciesRequested(
          assetName: widget.assetName, addresses: widget.addresses)),
      child: BlocConsumer<
          CreateDispenserOnNewAddressBloc,
          TransactionState<CreateDispenserOnNewAddressData,
              ComposeChainedDispenserResponse>>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<CreateDispenserOnNewAddressData,
                ComposeChainedDispenserResponse>(
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
                    showSendExtraBtcToDispenserCheckbox: true,
                    sendExtraBtcToDispenser: sendExtraBtcToDispenser,
                    onSendExtraBtcToDispenserChanged: (value) {
                      setState(() {
                        sendExtraBtcToDispenser = value ?? false;
                      });
                    },
                    onBalanceChanged: (value) {
                      setState(() {
                        selectedBalanceEntry = value;
                        selectedBtcBalanceEntry = data?.btcBalances.entries
                            .firstWhere(
                                (entry) => entry.address == value?.address);
                      });
                    },
                  ),
                ),
              ),
              confirmationStepContent:
                  ConfirmationStepContent<ComposeChainedDispenserResponse>(
                title: 'Confirm Transaction',
                buildConfirmationContent: (composeState, onErrorButtonAction) =>
                    TransactionComposePage<ComposeChainedDispenserResponse>(
                  composeState: composeState,
                  errorButtonText: 'Go back to transaction',
                  onErrorButtonAction: onErrorButtonAction,
                  buildComposeContent: (
                          {ComposeStateSuccess<ComposeChainedDispenserResponse>?
                              composeState,
                          required bool loading}) =>
                      const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [],
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
