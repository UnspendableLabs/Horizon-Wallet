import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_event.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/bloc/compose_dispenser_on_new_address_state.dart';
import 'package:horizon/presentation/screens/compose_dispenser_on_new_address/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeDispenserOnNewAddressPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String originalAddress;
  final String asset;
  final int giveQuantity;
  final int escrowQuantity;
  final int mainchainrate;
  final bool divisible;
  final int feeRate;

  const ComposeDispenserOnNewAddressPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.originalAddress,
    required this.divisible,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.feeRate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ComposeDispenserOnNewAddressBloc(
        accountRepository: GetIt.I.get<AccountRepository>(),
        addressRepository: GetIt.I.get<AddressRepository>(),
        walletRepository: GetIt.I.get<WalletRepository>(),
        encryptionService: GetIt.I.get<EncryptionService>(),
        addressService: GetIt.I.get<AddressService>(),
        composeRepository: GetIt.I.get<ComposeRepository>(),
        bitcoindService: GetIt.I.get<BitcoindService>(),
        utxoRepository: GetIt.I.get<UtxoRepository>(),
        composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
        fetchDispenserOnNewAddressFormDataUseCase:
            GetIt.I.get<FetchDispenserOnNewAddressFormDataUseCase>(),
      ),
      child: ComposeDispenserOnNewAddressPage(
        originalAddress: originalAddress,
        asset: asset,
        giveQuantity: giveQuantity,
        escrowQuantity: escrowQuantity,
        mainchainrate: mainchainrate,
        divisible: divisible,
        feeRate: feeRate,
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
  final int feeRate;
  const ComposeDispenserOnNewAddressPage({
    required this.originalAddress,
    required this.asset,
    required this.giveQuantity,
    required this.escrowQuantity,
    required this.mainchainrate,
    required this.divisible,
    required this.feeRate,
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
    context.read<ComposeDispenserOnNewAddressBloc>().add(FetchFormData());
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
        // TODO: implement listener
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
            confirm: (composeSendTransaction1,
                    composeSendTransaction2,
                    composeDispenserTransaction,
                    fee,
                    feeRate,
                    totalVirtualSize,
                    totalAdjustedVirtualSize) =>
                const Center(
              child: SelectableText('Confirming transaction...'),
            ),
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
      // Decimal giveInput = Decimal.parse(widget.giveQuantity);
      // Decimal escrowInput = Decimal.parse(widget.escrowQuantity);
      // Decimal mainchainrateBtc = Decimal.parse(widget.mainchainrate); // Price in BTC

      // int giveQuantity;
      // int escrowQuantity;

      // // Handle divisibility for the give quantity
      // if (widget.divisible) {
      //   giveQuantity = (giveInput * Decimal.fromInt(100000000)).toBigInt().toInt();
      //   escrowQuantity = (escrowInput * Decimal.fromInt(100000000)).toBigInt().toInt();
      // } else {
      //   giveQuantity = giveInput.toBigInt().toInt();
      //   escrowQuantity = escrowInput.toBigInt().toInt();
      // }

      // int mainchainrate = (mainchainrateBtc * Decimal.fromInt(100000000)).toBigInt().toInt();

      // // Dispatch the event with the calculated values

      context.read<ComposeDispenserOnNewAddressBloc>().add(ComposeTransactions(
            password: passwordController.text,
            originalAddress: widget.originalAddress,
            divisible: widget.divisible,
            asset: widget.asset,
            giveQuantity: widget.giveQuantity,
            escrowQuantity: widget.escrowQuantity,
            mainchainrate: widget.mainchainrate,
            status: 0,
            feeRate: widget.feeRate,
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
