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
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
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
import 'package:horizon/presentation/common/fee_estimation_v2.dart';
import 'package:horizon/presentation/screens/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/screens/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_text_field.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

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
          bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
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

  bool isDivisible = true;
  bool isLocked = false;
  bool isReset = false;

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
      buildInitialFormFields: (context, state, loading, error) =>
          _buildInitialFormFields(context, state, loading, error),
      onInitialCancel: (context) => _handleInitialCancel(context),
      onInitialSubmit: (context, state) => _handleInitialSubmit(context),
      buildConfirmationFormFields: (composeTransaction) =>
          _buildConfirmationDetails(composeTransaction),
      onConfirmationBack: (context) => _onConfirmationBack(context),
      onConfirmationContinue: (context, composeTransaction, fee) =>
          _onConfirmationContinue(context, composeTransaction, fee),
      onFinalizeSubmit: (context, password) =>
          _onFinalizeSubmit(context, password),
      onFinalizeCancel: (context) => _onFinalizeCancel(context),
    );
  }

  void _handleInitialCancel(BuildContext context) {
    context
        .read<ComposeIssuanceBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _handleInitialSubmit(BuildContext context) {
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
            reset: isReset,
          ),
        ));
  }

  List<Widget> _buildInitialFormFields(BuildContext context,
      ComposeIssuanceState state, bool loading, String? error) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    return state.balancesState.when(
      initial: () => [],
      loading: () => [],
      error: (e) => [SelectableText('An error occurred: $e')],
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

        return [
          HorizonTextFormField(
            onFieldSubmitted: (_) => _handleInitialSubmit(context),
            enabled: false,
            controller: fromAddressController,
            label: "Source",
          ),
          const SizedBox(height: 16.0),
          Stack(
            children: [
              HorizonTextFormField(
                enabled: loading ? false : true,
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
                onFieldSubmitted: (_) => _handleInitialSubmit(context),
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
          ),
          const SizedBox(height: 16.0),
          HorizonTextFormField(
            controller: quantityController,
            label: 'Quantity',
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
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
            onFieldSubmitted: (_) => _handleInitialSubmit(context),
          ),
          const SizedBox(height: 16.0),
          HorizonTextFormField(
            controller: descriptionController,
            label: 'Description (optional)',
            onFieldSubmitted: (_) => _handleInitialSubmit(context),
          ),
          const SizedBox(height: 16.0),
          Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: isDivisible,
                    onChanged: loading
                        ? null
                        : (bool? value) {
                            setState(() {
                              isDivisible = value ?? false;
                              quantityController.text = '';
                            });
                          },
                  ),
                  Text('Divisible',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? mainTextWhite : mainTextBlack)),
                ],
              ),
              const Row(
                children: [
                  SizedBox(width: 30.0),
                  Expanded(
                    child: Text(
                      'Whether this asset is divisible or not. Defaults to true.',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isLocked,
                    onChanged: loading
                        ? null
                        : (bool? value) {
                            setState(() {
                              isLocked = value ?? false;
                            });
                          },
                  ),
                  Text('Lock',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? mainTextWhite : mainTextBlack)),
                ],
              ),
              const Row(
                children: [
                  SizedBox(width: 30.0),
                  Expanded(
                    child: Text(
                      'Whether this issuance should lock supply of this asset forever. Defaults to false.',
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              // Row(
              //   children: [
              //     Checkbox(
              //       value: isReset,
              //       onChanged: (bool? value) {
              //         setState(() {
              //           isReset = value ?? false;
              //         });
              //       },
              //     ),
              //     // Text('Reset',
              //     //     style: TextStyle(
              //     //         fontWeight: FontWeight.bold,
              //     //         color: isDarkMode
              //     //             ? mainTextWhite
              //     //             : mainTextBlack)),
              //   ],
              // ),
              // const Row(
              //   children: [
              //     SizedBox(width: 30.0),
              //     Expanded(
              //       child: Text(
              //         'Whether this issuance should reset any existing supply. Defaults to false.',
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              thickness: 1.0,
            ),
          ),
          FeeSelectionV2(
            value: state.feeOption,
            feeEstimates: state.feeState.maybeWhen(
              success: (feeEsimates) {
                return FeeEstimateSuccess(feeEstimates: feeEsimates);
              },
              orElse: () => FeeEstimateLoading(),
            ),
            onSelected: (fee) {
              context
                  .read<ComposeIssuanceBloc>()
                  .add(ChangeFeeOption(value: fee));
            },
            layout: width > 768
                ? FeeSelectionLayout.row
                : FeeSelectionLayout.column,
            onFieldSubmitted: () => _handleInitialSubmit(context),
          ),
        ];
      },
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeIssuanceVerbose).params;
    return [
      HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Token name",
        controller: TextEditingController(text: composeTransaction.name),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      params.description != ''
          ? HorizonTextFormField(
              label: "Description",
              controller: TextEditingController(text: params.description),
              enabled: false,
            )
          : const SizedBox.shrink(),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Divisible",
        controller: TextEditingController(
            text: params.divisible == true ? 'true' : 'false'),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Lock",
        controller:
            TextEditingController(text: params.lock == true ? 'true' : 'false'),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonTextFormField(
        label: "Reset",
        controller: TextEditingController(
            text: params.reset == true ? 'true' : 'false'),
        enabled: false,
      ),
    ];
  }

  _onConfirmationBack(BuildContext context) {
    context
        .read<ComposeIssuanceBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  _onConfirmationContinue(
      BuildContext context, dynamic composeTransaction, int fee) {
    context.read<ComposeIssuanceBloc>().add(
          FinalizeTransactionEvent<ComposeIssuanceVerbose>(
            composeTransaction: composeTransaction,
            fee: fee,
          ),
        );
  }

  void _onFinalizeSubmit(BuildContext context, String password) {
    context.read<ComposeIssuanceBloc>().add(
          SignAndBroadcastTransactionEvent(
            password: password,
          ),
        );
  }

  void _onFinalizeCancel(BuildContext context) {
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
