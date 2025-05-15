import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
// import 'package:horizon/common/format.dart' as form;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/fee_option.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/bloc/transaction_state.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_form_page.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/transaction_stepper.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/horizon/redesign_ui.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_bloc.dart';
import 'package:horizon/presentation/screens/transactions/rbf/bloc/rbf_event.dart';
import 'package:horizon/presentation/common/transaction_stepper/view/steps/transaction_compose_page.dart';
import 'package:horizon/presentation/session/bloc/session_state.dart';

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
  final _formKey = GlobalKey<FormState>();

  void _handleOnFormStepNext(
      BuildContext context, TransactionState<RBFData, RBFComposeData> state) {
    final data = state.formState.getDataOrThrow();

    context.read<RBFBloc>().add(RBFTransactionComposed(
          sourceAddress: widget.address,
          params: RBFTransactionParams(
            tx: data.tx,
            hex: data.hex,
            adjustedVirtualSize: data.adjustedSize,
          ),
        ));
  }

  void _handleConfirmationStepNext(BuildContext context,
      {required dynamic decryptionStrategy}) {
    context
        .read<RBFBloc>()
        .add(RBFTransactionBroadcasted(decryptionStrategy: decryptionStrategy));
  }

  void _handleFeeOptionSelected(BuildContext context, FeeOption feeOption) {
    context.read<RBFBloc>().add(FeeOptionSelected(feeOption: feeOption));
  }

  void _handleDependenciesRequested(BuildContext context) {
    context.read<RBFBloc>().add(RBFDependenciesRequested(
          txHash: widget.txHash,
          address: widget.address,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>().state.successOrThrow();

    return BlocProvider(
      create: (context) => RBFBloc(
        address: session.addresses.first, // TODO: slight smell
        httpConfig: session.httpConfig,
        getFeeEstimatesUseCase: GetIt.I<GetFeeEstimatesUseCase>(),
        bitcoinRepository: GetIt.I<BitcoinRepository>(),
        writelocalTransactionUseCase: GetIt.I<WriteLocalTransactionUseCase>(),
        analyticsService: GetIt.I<AnalyticsService>(),
        logger: GetIt.I<Logger>(),
        settingsRepository: GetIt.I<SettingsRepository>(),
        transactionService: GetIt.I<TransactionService>(),
        bitcoindService: GetIt.I<BitcoindService>(),
        transactionLocalRepository: GetIt.I<TransactionLocalRepository>(),
        addressRepository: GetIt.I<UnifiedAddressRepository>(),
        inMemoryKeyRepository: GetIt.I<InMemoryKeyRepository>(),
        encryptionService: GetIt.I<EncryptionService>(),
        addressService: GetIt.I<AddressService>(),
        importedAddressService: GetIt.I<ImportedAddressService>(),
      )..add(RBFDependenciesRequested(
          txHash: widget.txHash, address: widget.address)),
      child: BlocConsumer<RBFBloc, TransactionState<RBFData, RBFComposeData>>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            body: TransactionStepper<RBFData, RBFComposeData>(
              state: state,
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
                        SelectableText(
                          'Transaction Hash:',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.left,
                        ),
                        SelectableText(
                          widget.txHash,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.left,
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
              confirmationStepContent: ConfirmationStepContent<RBFComposeData>(
                title: 'Confirm Transaction',
                buildConfirmationContent: (composeState, onErrorButtonAction) =>
                    TransactionComposePage<RBFComposeData>(
                  composeState: composeState,
                  errorButtonText: 'Go back to transaction',
                  onErrorButtonAction: onErrorButtonAction,
                  buildComposeContent: (
                          {ComposeStateSuccess<RBFComposeData>? composeState,
                          required bool loading}) =>
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        SelectableText(
                          'Replacing:',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                composeState?.composeData.txid ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      overflow: TextOverflow.visible,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        SelectableText(
                          'Fee:',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Row(
                          children: [
                            SelectableText(
                              "${composeState?.composeData.oldFee} sats/vbyte",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                            const SizedBox(width: 8.0),
                            SelectableText(
                              "${composeState?.composeData.makeRBFResponse.fee} sats/vbyte",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.green),
                            ),
                          ],
                        ),
                      ]),
                ),
                onNext: ({required dynamic decryptionStrategy}) =>
                    _handleConfirmationStepNext(context,
                        decryptionStrategy: decryptionStrategy),
              ),
            ),
          );
        },
      ),
    );
  }
}
