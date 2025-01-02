import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_bloc.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/bloc/compose_attach_utxo_state.dart';
import 'package:horizon/presentation/screens/compose_attach_utxo/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeAttachUtxoPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;
  final String? assetLongname;
  const ComposeAttachUtxoPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.assetName,
    this.assetLongname,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeAttachUtxoBloc(
          logger: GetIt.I.get<Logger>(),
          fetchComposeAttachUtxoFormDataUseCase:
              GetIt.I.get<FetchComposeAttachUtxoFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
          cacheProvider: GetIt.I.get<CacheProvider>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeAttachUtxoPage(
          address: currentAddress,
          assetName: assetName,
          assetLongname: assetLongname,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeAttachUtxoPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;
  final String? assetLongname;
  const ComposeAttachUtxoPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
    this.assetLongname,
  });

  @override
  ComposeAttachUtxoPageState createState() => ComposeAttachUtxoPageState();
}

class ComposeAttachUtxoPageState extends State<ComposeAttachUtxoPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController assetController = TextEditingController();

  bool _submitted = false;
  String? error;
  // Add a key for the dropdown
  bool showLockedOnly = false;
  bool warningAccepted = false;
  bool errorWarningAccepted = false;
  @override
  void initState() {
    super.initState();
    warningAccepted = false;
    fromAddressController.text = widget.address;
    assetController.text =
        displayAssetName(widget.assetName, widget.assetLongname);
  }

  @override
  void dispose() {
    super.dispose();
    quantityController.dispose();
    fromAddressController.dispose();
    assetController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.balancesState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => () {},
            buildInitialFormFields: (state, loading, formKey) => [
              HorizonUI.HorizonTextFormField(
                controller: fromAddressController,
                label: 'From Address',
                enabled: false,
              ),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: assetController,
                label: 'Asset',
                enabled: false,
              ),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: quantityController,
                label: 'Quantity',
                enabled: false,
              ),
              const SizedBox(height: 16),
              const HorizonUI.HorizonTextFormField(
                label: 'Available Supply',
                enabled: false,
              ),
              const SizedBox(height: 16),
              const HorizonUI.HorizonTextFormField(
                label: 'XCP Fee Estimate',
                enabled: false,
              ),
            ],
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) => () {},
            buildConfirmationFormFields: (state, composeTransaction, formKey) =>
                [],
            onConfirmationBack: () => () {},
            onConfirmationContinue: (composeTransaction, fee, formKey) {
              () {};
            },
            onFinalizeSubmit: (password, formKey) {
              () {};
            },
            onFinalizeCancel: () => () {},
          ),
          success: (balances) =>
              ComposeBasePage<ComposeAttachUtxoBloc, ComposeAttachUtxoState>(
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeAttachUtxoBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) =>
                _handleInitialSubmit(formKey, balances),
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
          ),
          error: (message) => SelectableText(message),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(
      GlobalKey<FormState> formKey, List<Balance> balances) {
    setState(() {
      _submitted = true;
    });

    final balance = balances
        .firstWhereOrNull((balance) => balance.asset == widget.assetName);
    if (balance == null) {
      // we should never reach this point but this is a safeguard against submitting the wrong asset
      throw Exception('Balance not found for asset ${widget.assetName}');
    }

    if (!warningAccepted) {
      setState(() {
        errorWarningAccepted = true;
      });
      return;
    }
    if (formKey.currentState!.validate()) {
      int quantity = getQuantityForDivisibility(
          divisible: balance.assetInfo.divisible,
          inputQuantity: quantityController.text);

      context.read<ComposeAttachUtxoBloc>().add(ComposeTransactionEvent(
            sourceAddress: fromAddressController.text,
            params: ComposeAttachUtxoEventParams(
              asset: widget.assetName,
              quantity: quantity,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeAttachUtxoState state,
      bool loading, GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(
      success: (balances) {
        final balance = balances
            .firstWhereOrNull((balance) => balance.asset == widget.assetName);
        if (balance == null) {
          throw Exception('No balance found');
        }

        return [
          HorizonUI.HorizonTextFormField(
            controller: fromAddressController,
            label: 'From Address',
            enabled: false,
          ),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: assetController,
            label: 'Asset',
            enabled: false,
          ),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: quantityController,
            label: 'Quantity to attach',
            inputFormatters: [
              balance.assetInfo.divisible == true
                  ? DecimalTextInputFormatter(decimalRange: 20)
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Quantity is required';
              }
              return null;
            },
            autovalidateMode: _submitted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
          ),
          const SizedBox(height: 32),
          HorizonUI.HorizonTextFormField(
            controller: TextEditingController(text: balance.quantityNormalized),
            label: 'Available Supply',
            enabled: false,
          ),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: TextEditingController(text: state.xcpFeeEstimate),
            label: 'XCP Fee Estimate',
            enabled: false,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: warningAccepted,
                onChanged: (value) {
                  setState(() {
                    warningAccepted = value ?? false;
                    errorWarningAccepted = false;
                  });
                },
              ),
              Expanded(
                child: SelectableText(
                  'If you use this address in a wallet that does not support Counterparty there is a very high risk of losing your UTXO-attached asset.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (errorWarningAccepted)
            const SelectableText(
              'You must accept the warning to continue',
              style: TextStyle(color: Colors.red),
            ),
        ];
      },
      orElse: () => [],
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeAttachUtxoResponse).params;
    if (params.asset == widget.assetName) {
      return [
        HorizonUI.HorizonTextFormField(
          controller: TextEditingController(
              text: displayAssetName(
                  params.asset, params.assetInfo.assetLongname)),
          label: 'Asset',
          enabled: false,
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          controller: TextEditingController(text: params.quantityNormalized),
          label: 'Quantity',
          enabled: false,
        ),
      ];
    }
    return [
      const SelectableText('Unknown error occurred')
    ]; // we will never get here
  }

  void _onConfirmationBack() {
    context.read<ComposeAttachUtxoBloc>().add(FetchFormData(
          currentAddress: widget.address,
        ));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeAttachUtxoBloc>()
        .add(FinalizeTransactionEvent<ComposeAttachUtxoResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeAttachUtxoBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<ComposeAttachUtxoBloc>().add(FetchFormData(
          currentAddress: widget.address,
        ));
  }
}
