import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_chained_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';

class ComposeDispenserOnNewAddressPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String originalAddress;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final bool divisible;
  final num feeRate;
  final bool sendExtraBtcToDispenser;
  const ComposeDispenserOnNewAddressPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.feeRate,
    required this.sendExtraBtcToDispenser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComposeDispenserOnNewAddressBloc(
        asset: asset,
        giveQuantity: giveQuantity,
        escrowQuantity: escrowQuantity,
        mainchainrate: mainchainrate,
        divisible: divisible,
        feeRate: feeRate,
        sendExtraBtcToDispenser: sendExtraBtcToDispenser,
        passwordRequired:
            GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
        inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
        accountRepository: GetIt.I.get<AccountRepository>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
        addressService: GetIt.I.get<AddressService>(),
        composeRepository: GetIt.I.get<ComposeRepository>(),
        dispenserRepository: GetIt.I.get<DispenserRepository>(),
        bitcoindService: GetIt.I.get<BitcoindService>(),
        utxoRepository: GetIt.I.get<UtxoRepository>(),
        balanceRepository: GetIt.I.get<BalanceRepository>(),
        composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
        signChainedTransactionUseCase:
            GetIt.I.get<SignChainedTransactionUseCase>(),
        transactionService: GetIt.I.get<TransactionService>(),
        fetchDispenseFormDataUseCase:
            GetIt.I.get<FetchDispenseFormDataUseCase>(),
        writeLocalTransactionUseCase:
            GetIt.I.get<WriteLocalTransactionUseCase>(),
        errorService: GetIt.I.get<ErrorService>(),
      )..add(FormOpened(originalAddress: originalAddress)),
      child: ComposeDispenserOnNewAddressPage(
        originalAddress: originalAddress,
        asset: asset,
        giveQuantity: giveQuantity,
        escrowQuantity: escrowQuantity,
        mainchainrate: mainchainrate,
        divisible: divisible,
        feeRate: feeRate,
        sendExtraBtcToDispenser: sendExtraBtcToDispenser,
      ),
    );
  }
}

class ComposeDispenserOnNewAddressPage extends StatefulWidget {
  final String originalAddress;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final bool divisible;
  final num feeRate;
  final bool sendExtraBtcToDispenser;
  const ComposeDispenserOnNewAddressPage({
    required this.originalAddress,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.divisible,
    required this.feeRate,
    required this.sendExtraBtcToDispenser,
    super.key,
  });

  @override
  State<ComposeDispenserOnNewAddressPage> createState() =>
      _ComposeDispenserOnNewAddressPageState();
}

class _ComposeDispenserOnNewAddressPageState
    extends State<ComposeDispenserOnNewAddressPage> {
  final passwordController = TextEditingController();
  final initialFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ComposeDispenserOnNewAddressBloc,
        ComposeDispenserOnNewAddressStateBase>(
      listener: (context, state) {
        state.composeDispenserOnNewAddressState.maybeWhen(
          success: () async {
            Navigator.of(context).pop();
            context.read<SessionStateCubit>().refreshAndSelectNewAddress(
                state.newAddress!.address, state.newAccount!.uuid);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Success',
                  onPressed: () {
                    // Clipboard.setData(ClipboardData(text: txHash));
                  },
                ),
                content: const Text('Success'),
                behavior: SnackBarBehavior.floating));
            await Future.delayed(const Duration(milliseconds: 500));
          },
          orElse: () {},
        );
      },
      child: BlocBuilder<ComposeDispenserOnNewAddressBloc,
          ComposeDispenserOnNewAddressStateBase>(
        builder: (context, state) {
          return state.composeDispenserOnNewAddressState.maybeWhen(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            collectPassword: (error, loading) => Form(
              key: passwordFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    HorizonUI.HorizonTextFormField(
                      enabled: !loading,
                      controller: passwordController,
                      obscureText: true,
                      label: 'Password',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _handleContinue(),
                    ),
                    if (error != null)
                      SelectableText(error,
                          style: const TextStyle(color: redErrorText)),
                    _buildBackContinueButtons(
                      loading: loading,
                      onBack: () {
                        Navigator.of(context).pop();
                      },
                      onContinue: loading ? () {} : _handleContinue,
                    ),
                  ],
                ),
              ),
            ),
            confirm: (
              newAccountName,
              newAddress,
              composeSendTransaction,
              composeDispenserTransaction,
              btcQuantity,
              feeRate,
            ) {
              final sendParams =
                  (composeSendTransaction as ComposeSendResponse).params;
              final dispenserParams = (composeDispenserTransaction
                      as ComposeDispenserResponseVerbose)
                  .params;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: SelectableText(
                          'New Address $newAddress',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      HorizonUI.HorizonTextFormField(
                        controller: TextEditingController(
                            text: "at new account \"$newAccountName\""),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      const Center(
                        child: SelectableText(
                          'Confirm Send',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      HorizonUI.HorizonTextFormField(
                        label: "Source Address",
                        controller:
                            TextEditingController(text: sendParams.source),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Destination Address",
                        controller:
                            TextEditingController(text: sendParams.destination),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: HorizonUI.HorizonTextFormField(
                              label: "Asset Quantity",
                              controller: TextEditingController(
                                  text: sendParams.quantityNormalized),
                              enabled: false,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: HorizonUI.HorizonTextFormField(
                              label: "Asset",
                              controller:
                                  TextEditingController(text: sendParams.asset),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "BTC Quantity",
                        controller: TextEditingController(
                            text:
                                satoshisToBtc(btcQuantity).toStringAsFixed(8)),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Fee",
                        controller: TextEditingController(
                            text:
                                "${composeSendTransaction.btcFee.toStringAsFixed(8)} sats"),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      const Center(
                        child: SelectableText(
                          'Confirm Compose Dispenser',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      HorizonUI.HorizonTextFormField(
                        label: "Source Address",
                        controller:
                            TextEditingController(text: dispenserParams.source),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Asset",
                        controller:
                            TextEditingController(text: dispenserParams.asset),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Give Quantity",
                        controller: TextEditingController(
                            text: dispenserParams.giveQuantityNormalized),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Escrow Quantity",
                        controller: TextEditingController(
                            text: dispenserParams.escrowQuantityNormalized),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: 'Price Per Unit (BTC)',
                        controller: TextEditingController(
                            text: satoshisToBtc(dispenserParams.mainchainrate)
                                .toStringAsFixed(8)),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      HorizonUI.HorizonTextFormField(
                        label: "Fee",
                        controller: TextEditingController(
                          text:
                              "${composeDispenserTransaction.btcFee.toStringAsFixed(8)} sats",
                        ),
                        enabled: false,
                      ),
                      const SizedBox(height: 16.0),
                      _buildBackContinueButtons(
                          loading: false,
                          onBack: () {
                            Navigator.of(context).pop();
                          },
                          onContinue: () {
                            context
                                .read<ComposeDispenserOnNewAddressBloc>()
                                .add(SubmitPressed());
                          }),
                    ],
                  ),
                ),
              );
            },
            error: (error) => Center(
              child: SelectableText(error),
            ),
            orElse: () => const SizedBox.shrink(),
          );
        },
      ),
    );
  }

  void _handleContinue() {
    if (passwordFormKey.currentState!.validate()) {
      context.read<ComposeDispenserOnNewAddressBloc>().add(PasswordEntered(
            password: passwordController.text,
            originalAddress: widget.originalAddress,
            divisible: widget.divisible,
            asset: widget.asset,
            giveQuantity: widget.giveQuantity,
            escrowQuantity: widget.escrowQuantity,
            mainchainrate: widget.mainchainrate,
            status: 0,
            feeRate: widget.feeRate,
            sendExtraBtcToDispenser: widget.sendExtraBtcToDispenser,
          ));
    }
  }

  Widget _buildBackContinueButtons(
      {required VoidCallback onBack,
      required VoidCallback onContinue,
      required bool loading}) {
    return Column(
      children: [
        const HorizonUI.HorizonDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HorizonUI.HorizonCancelButton(
              onPressed: onBack,
              buttonText: 'BACK',
            ),
            HorizonUI.HorizonContinueButton(
              loading: loading,
              onPressed: onContinue,
              buttonText: 'CONTINUE',
            ),
          ],
        ),
      ],
    );
  }
}
