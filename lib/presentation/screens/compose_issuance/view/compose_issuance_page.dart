import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/issuance_checkboxes.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_state.dart';
import 'package:horizon/presentation/screens/compose_issuance/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';

import 'package:horizon/domain/repositories/settings_repository.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'dart:math';

class ComposeIssuancePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  const ComposeIssuancePageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionStateCubit>();
    return session.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeIssuanceBloc(
          inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
          // TODO: factor into settings repository...
          passwordRequired:
              GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          transactionService: GetIt.I.get<TransactionService>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          logger: GetIt.I.get<Logger>(),
          fetchIssuanceFormDataUseCase:
              GetIt.I.get<FetchIssuanceFormDataUseCase>(),
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: ComposeIssuancePage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeIssuancePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
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

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address;
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeIssuanceBloc, ComposeIssuanceState>(
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeIssuanceBloc>().add(FeeOptionChanged(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
      buildConfirmationFormFields: (state, composeTransaction, formKey) =>
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
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      int quantity = getQuantityForDivisibility(
          divisible: isDivisible, inputQuantity: quantityController.text);

      context.read<ComposeIssuanceBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
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
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
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
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
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
        autovalidateMode: _submitted
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
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
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
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
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            ReviewSubmitted<ComposeIssuanceResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeIssuanceBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
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
