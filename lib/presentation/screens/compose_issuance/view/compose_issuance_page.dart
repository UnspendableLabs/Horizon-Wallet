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
import 'package:horizon/presentation/screens/compose_base/bloc/submit_base_state.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_event.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";
import 'package:horizon/presentation/screens/shared/colors.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_cancel_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_continue_button.dart';
import 'package:horizon/presentation/screens/shared/view/horizon_dialog.dart';
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
    required this.address,
    required this.dashboardActivityFeedBloc,
  });

  @override
  ComposeIssuancePageState createState() => ComposeIssuancePageState();
}

class ComposeIssuancePageState extends State<ComposeIssuancePage> {
  final balanceRepository = GetIt.I.get<BalanceRepository>();
  final _formKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();
  TextEditingController nameController = UpperCaseTextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? asset;

  bool isDivisible = true;
  bool isLocked = false;
  bool isReset = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  Widget _buildFinalizingForm(
      BuildContext context,
      ComposeIssuanceVerbose composeIssuance,
      int fee,
      bool loading,
      String? error) {
    TextEditingController passwordController = TextEditingController();

    void handlePasswordSubmit() {
      if (passwordFormKey.currentState!.validate()) {
        context.read<ComposeIssuanceBloc>().add(
              SignAndBroadcastTransactionEvent(
                password: passwordController.text,
              ),
            );
      }
    }

    return Form(
        key: passwordFormKey,
        child: Column(
          children: [
            HorizonTextFormField(
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              controller: passwordController,
              label: "Password",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              onFieldSubmitted: (_) => handlePasswordSubmit(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(
                thickness: 1.0,
              ),
            ),
            const SizedBox(height: 16.0),
            error != null
                ? Text(error, style: const TextStyle(color: Colors.red))
                : const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HorizonCancelButton(
                  onPressed: () {
                    context
                        .read<ComposeIssuanceBloc>()
                        .add(FetchFormData(currentAddress: widget.address));
                  },
                  buttonText: 'BACK',
                ),
                HorizonContinueButton(
                  loading: loading,
                  onPressed: handlePasswordSubmit,
                  buttonText: 'SIGN AND BROADCAST',
                ),
              ],
            ),
          ],
        ));
  }

  Widget _buildInitialForm(BuildContext context, ComposeIssuanceState state,
      String? error, bool loading) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final width = MediaQuery.of(context).size.width;

    void handleInitialSubmit() {
      if (_formKey.currentState!.validate()) {
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
              name: nameController.text,
              quantity: quantity,
              description: descriptionController.text,
              divisible: isDivisible,
              lock: isLocked,
              reset: isReset,
            ));
      }
    }

    return state.balancesState.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
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

        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                HorizonTextFormField(
                  onFieldSubmitted: (_) => handleInitialSubmit(),
                  enabled: false,
                  controller: fromAddressController,
                  label: "Source",
                ),
                const SizedBox(height: 16.0),
                Stack(
                  children: [
                    HorizonTextFormField(
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
                      onFieldSubmitted: (_) => handleInitialSubmit(),
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
                  onFieldSubmitted: (_) => handleInitialSubmit(),
                ),
                const SizedBox(height: 16.0),
                HorizonTextFormField(
                    controller: descriptionController,
                    label: 'Description (optional)',
                    onFieldSubmitted: (_) => handleInitialSubmit()),
                const SizedBox(height: 16.0),
                Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isDivisible,
                          onChanged: (bool? value) {
                            setState(() {
                              isDivisible = value ?? false;
                              quantityController.text = '';
                            });
                          },
                        ),
                        Text('Divisible',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? mainTextWhite
                                    : mainTextBlack)),
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
                          onChanged: (bool? value) {
                            setState(() {
                              isLocked = value ?? false;
                            });
                          },
                        ),
                        Text('Lock',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode
                                    ? mainTextWhite
                                    : mainTextBlack)),
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
                      onFieldSubmitted: () => handleInitialSubmit(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child:
                        Text(error, style: const TextStyle(color: Colors.red)),
                  ),
                HorizonDialogSubmitButton(
                  loading: loading,
                  onPressed: handleInitialSubmit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeIssuanceBloc, ComposeIssuanceState>(
        listener: (context, state) {
      switch (state.submitState) {
        case SubmitSuccess(transactionHex: var txHash):
          widget.dashboardActivityFeedBloc
              .add(const Load()); // show "N more transactions".

          // 1) close modal
          Navigator.of(context).pop();
          // 2) show snackbar with copy tx action
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: txHash));
                },
              ),
              content: Text(txHash),
              behavior: SnackBarBehavior.floating));

        case _:
          break;
      }
    }, builder: (context, state) {
      return switch (state.submitState) {
        SubmitInitial(error: var error, loading: var loading) =>
          _buildInitialForm(context, state, error, loading),
        SubmitError(error: var msg) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText('An error occurred: $msg'),
          ),
        SubmitComposingIssuance(
          composeIssuance: var composeIssuance,
          fee: var fee,
          feeRate: var feeRate,
          virtualSize: var virtualSize,
        ) =>
          ComposeIssuanceConfirmationPage(
            composeIssuance: composeIssuance,
            address: widget.address,
            fee: fee,
            feeRate: feeRate,
            virtualSize: virtualSize,
          ),
        SubmitFinalizing(
          composeIssuance: var composeIssuance,
          fee: var fee,
          loading: var loading,
          error: var error,
        ) =>
          _buildFinalizingForm(context, composeIssuance, fee, loading, error),
        SubmitSuccess() => const SizedBox.shrink(),
        _ => const SizedBox.shrink(),
      };
    });
  }
}

class ComposeIssuanceConfirmationPage extends StatefulWidget {
  final ComposeIssuanceVerbose composeIssuance;
  final Address address;
  final int fee;
  final int feeRate;
  final int virtualSize;

  const ComposeIssuanceConfirmationPage(
      {super.key,
      required this.composeIssuance,
      required this.address,
      required this.fee,
      required this.feeRate,
      required this.virtualSize});

  @override
  State<ComposeIssuanceConfirmationPage> createState() =>
      _ComposeIssuanceConfirmationPageState();
}

class _ComposeIssuanceConfirmationPageState
    extends State<ComposeIssuanceConfirmationPage> {
  late int fee;
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    fee = widget.fee;
  }

  @override
  Widget build(BuildContext context) {
    final issueParams = widget.composeIssuance.params;
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Please review your transaction details.',
              style: TextStyle(
                  fontSize: 16.0,
                  color: mainTextWhite,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Source Address",
              controller: TextEditingController(text: issueParams.source),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Token name",
              controller:
                  TextEditingController(text: widget.composeIssuance.name),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Quantity",
              controller: TextEditingController(
                  text: widget.composeIssuance.params.quantityNormalized),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            widget.composeIssuance.params.description != ''
                ? HorizonTextFormField(
                    label: "Description",
                    controller: TextEditingController(
                        text: widget.composeIssuance.params.description),
                    enabled: false,
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Divisible",
              controller: TextEditingController(
                  text: issueParams.divisible == true ? 'true' : 'false'),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Lock",
              controller: TextEditingController(
                  text: issueParams.lock == true ? 'true' : 'false'),
              enabled: false,
            ),
            const SizedBox(height: 16.0),
            HorizonTextFormField(
              label: "Reset",
              controller: TextEditingController(
                  text: issueParams.reset == true ? 'true' : 'false'),
              enabled: false,
            ),
            HorizonTextFormField(
              label: "Fee",
              controller: TextEditingController(
                  text:
                      "${widget.fee.toString()} sats ( ${widget.feeRate} sats/vbyte )"),
              enabled: false,
            ),
            Column(
              children: [
                const SizedBox(height: 16.0),
                // FeeEstimation(
                //     feeMap: widget.composeIssuanceState.feeEstimates,
                //     virtualSize: widget.composeIssuanceState.virtualSize,
                //     onChanged: (v) {
                //       setState(() {
                //         fee = v.toInt();
                //       });
                //     }),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(
                    thickness: 1.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HorizonCancelButton(
                      onPressed: () {
                        context
                            .read<ComposeIssuanceBloc>()
                            .add(FetchFormData(currentAddress: widget.address));
                      },
                      buttonText: 'BACK',
                    ),
                    HorizonContinueButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          context.read<ComposeIssuanceBloc>().add(
                                FinalizeTransactionEvent(
                                  composeIssuance: widget.composeIssuance,
                                  fee: fee,
                                ),
                              );
                        }
                      },
                      buttonText: 'CONTINUE',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
