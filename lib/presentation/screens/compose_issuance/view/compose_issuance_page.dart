import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/transaction_repository.dart';
import 'package:horizon/domain/repositories/utxo_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/issuance_checkboxes.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'dart:math';

class ComposeIssuancePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeIssuancePageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeIssuanceBloc(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          addressRepository: GetIt.I.get<AddressRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          utxoRepository: GetIt.I.get<UtxoRepository>(),
          accountRepository: GetIt.I.get<AccountRepository>(),
          walletRepository: GetIt.I.get<WalletRepository>(),
          encryptionService: GetIt.I.get<EncryptionService>(),
          addressService: GetIt.I.get<AddressService>(),
          transactionService: GetIt.I.get<TransactionService>(),
          bitcoindService: GetIt.I.get<BitcoindService>(),
          transactionRepository: GetIt.I.get<TransactionRepository>(),
          transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeIssuancePage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeIssuancePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const ComposeIssuancePage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeIssuancePageState createState() => ComposeIssuancePageState();
}

class ComposeIssuancePageState extends State<ComposeIssuancePage> {
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController nameController = UpperCaseTextEditingController();
  TextEditingController descriptionController = TextEditingController();

  final balanceRepository = GetIt.I.get<BalanceRepository>();

  String? asset;

  bool isDivisible = false;
  bool isLocked = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeIssuanceBloc, ComposeIssuanceState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeIssuanceBloc>().add(ChangeFeeOption(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
      buildConfirmationFormFields: (composeTransaction, formKey) =>
          _buildConfirmationDetails(composeTransaction),
      onConfirmationBack: () => _onConfirmationBack(),
      onConfirmationContinue: (composeTransaction, fee, formKey) {
        _onConfirmationContinue(composeTransaction, fee, formKey);
      },
      onFinalizeSubmit: (password, formKey) {
        _onFinalizeSubmit(password, formKey);
      },
      onFinalizeCancel: () => _onFinalizeCancel(),
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // TODO: wrap this in function and write some tests
      Decimal input = Decimal.parse(quantityController.text);

      int quantity;

      if (isDivisible) {
        quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
      } else {
        quantity = (input).toBigInt().toInt();
      }

      context.read<ComposeIssuanceBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: ComposeIssuanceEventParams(
              name: nameController.text,
              quantity: quantity,
              description: descriptionController.text,
              divisible: isDivisible,
              lock: isLocked,
              reset: false,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(
      ComposeIssuanceState state, bool loading, GlobalKey<FormState> formKey) {
    final Widget assetNameField = state.balancesState.when(
      initial: () => HorizonUI.HorizonTextFormField(
          enabled: false, controller: nameController, label: "Token name"),
      loading: () => Stack(
        children: [
          TextFormField(
            enabled: false,
            controller: nameController,
            decoration: InputDecoration(
              fillColor: noBackgroundColor,
              labelText: "Token name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(14.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      error: (e) => SelectableText('An error occurred: $e'),
      success: (balances) {
        bool hasXCPBalance = balances.isNotEmpty &&
            balances.any((balance) => balance.asset == 'XCP');
        Balance? xcpBalance = hasXCPBalance
            ? balances.firstWhere((element) => element.asset == 'XCP')
            : null;
        bool isNamedAssetEnabled =
            xcpBalance != null && xcpBalance.quantity >= 50000000;
        String quantity =
            xcpBalance != null ? xcpBalance.quantityNormalized : '0';

        return Stack(
          children: [
            HorizonUI.HorizonTextFormField(
              enabled: !loading,
              controller: nameController,
              label: "Token name",
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name for your asset';
                }
                if (!isNamedAssetEnabled &&
                    !RegExp(r'^A\d+$').hasMatch(value)) {
                  return 'You must have at least 0.5 XCP to create a named asset. Your balance is: $quantity';
                }
                return null;
              },
              onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.autorenew),
                onPressed: () {
                  setState(() {
                    nameController.text = generateNumericAssetName();
                  });
                },
              ),
            ),
          ],
        );
      },
    );

    return [
      HorizonUI.HorizonTextFormField(
        onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
        enabled: false,
        controller: fromAddressController,
        label: "Source",
      ),
      const SizedBox(height: 16.0),
      assetNameField,
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        controller: quantityController,
        label: 'Quantity',
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: [
          isDivisible == true
              ? DecimalTextInputFormatter(decimalRange: 8)
              : FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a quantity';
          }
          return null;
        },
        onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
      ),
      const SizedBox(height: 16.0),
      LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (loading) {
            final isDarkMode = Theme.of(context).brightness == Brightness.dark;
            final fillColor = isDarkMode
                ? dialogBackgroundColorDarkTheme
                : dialogBackgroundColorLightTheme;

            return InputDecorator(
              decoration: InputDecoration(
                fillColor: fillColor,
                labelText: 'Description (optional)',
              ),
              child: Text(
                descriptionController.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? mainTextWhite : mainTextBlack,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }

          return HorizonUI.HorizonTextFormField(
            controller: descriptionController,
            label: 'Description (optional)',
            onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
            // keyboardType: TextInputType.multiline,
          );
        },
      ),
      const SizedBox(height: 16.0),
      IssuanceCheckboxes(
        isDivisible: isDivisible,
        isLocked: isLocked,
        onDivisibleChanged: loading
            ? null
            : (bool? value) {
                setState(() {
                  isDivisible = value ?? false;
                  quantityController.text = '';
                });
              },
        onLockChanged: loading
            ? null
            : (bool? value) {
                setState(() {
                  isLocked = value ?? false;
                });
              },
      ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params =
        (composeTransaction as ComposeIssuanceResponseVerbose).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Token name",
        controller: TextEditingController(text: composeTransaction.name),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
      params.description != ''
          ? Column(
              children: [
                const SizedBox(height: 16.0),
                HorizonUI.HorizonTextFormField(
                  label: "Description",
                  controller: TextEditingController(text: params.description),
                  enabled: false,
                ),
              ],
            )
          : const SizedBox.shrink(),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Divisible",
        controller: TextEditingController(
            text: params.divisible == true ? 'true' : 'false'),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Lock",
        controller:
            TextEditingController(text: params.lock == true ? 'true' : 'false'),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Reset",
        controller: TextEditingController(
            text: params.reset == true ? 'true' : 'false'),
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeIssuanceBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            FinalizeTransactionEvent<ComposeIssuanceResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeIssuanceBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}

class UpperCaseTextEditingController extends TextEditingController {
  @override
  set value(TextEditingValue newValue) {
    super.value = newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: newValue.composing,
    );
  }
}

String generateNumericAssetName() {
  final min = BigInt.from(26).pow(12) + BigInt.one;
  final max = BigInt.from(256).pow(8);
  final range = max - min;
  final random = Random.secure();

  // Generate random bytes
  final randomBytes = List<int>.generate(32, (i) => random.nextInt(256));
  final randomBigInt = BigInt.parse(
      randomBytes.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
      radix: 16);

  // Ensure the generated number is within the desired range
  final scaledRandomBigInt = (randomBigInt % range) + min;

  return 'A${scaledRandomBigInt.toString()}';
}
