import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_bloc.dart';
import 'package:horizon/presentation/screens/compose_destroy/bloc/compose_destroy_state.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';

class ComposeDestroyPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const ComposeDestroyPageWrapper({
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
        create: (context) => ComposeDestroyBloc(
          httpConfig: GetIt.I<HttpConfig>(),
          passwordRequired:
              GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
          inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          logger: GetIt.I.get<Logger>(),
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: ComposeDestroyPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDestroyPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  const ComposeDestroyPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeDestroyPageState createState() => ComposeDestroyPageState();
}

class ComposeDestroyPageState extends State<ComposeDestroyPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController tagController = TextEditingController();
  bool _submitted = false;
  bool assetError = false;
  Balance? balance_;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    quantityController.dispose();
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeDestroyBloc, ComposeDestroyState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeDestroyBloc, ComposeDestroyState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<ComposeDestroyBloc>()
              .add(FeeOptionChanged(value: fee)),
          buildInitialFormFields: (state, loading, formKey) =>
              _buildInitialFormFields(state, loading, formKey),
          onInitialCancel: () => _handleInitialCancel(),
          onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
          buildConfirmationFormFields: (_, composeTransaction, formKey) =>
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
      },
    );
  }

  List<Widget> _buildInitialFormFields(
      ComposeDestroyState state, bool loading, GlobalKey<FormState> formKey) {
    return state.balancesState.maybeWhen(
      // only a single balance is emitted by the compose destroy bloc
      success: (balances) => [
        HorizonUI.HorizonTextFormField(
          label: 'Source Address',
          enabled: false,
          controller: TextEditingController(text: widget.address),
        ),
        const SizedBox(height: 16),
        _buildAssetInput(state, loading, formKey, 'Destroy Asset'),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          label: 'Tag',
          controller: tagController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a tag';
            }
            return null;
          },
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          inputFormatters: [
            // Allow all ASCII characters
            FilteringTextInputFormatter.allow(RegExp(r'[\x20-\x7E]')),
          ],
        )
      ],
      orElse: () => [
        const HorizonUI.HorizonTextFormField(
          label: 'Source Address',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Destroy Asset',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'Available supply',
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Quantity to destroy',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Available supply',
          enabled: false,
        ),
        const SizedBox(height: 16),
        const HorizonUI.HorizonTextFormField(
          label: 'Tag',
          enabled: false,
        )
      ],
    );
  }

  Widget _buildAssetInput(
      ComposeDestroyState state, bool loading, GlobalKey<FormState> formKey,
      [String? label]) {
    return state.balancesState.maybeWhen(
      loading: () => const CircularProgressIndicator(),
      error: (error) => Text('Error fetching balances: $error'),
      success: (balances) {
        if (balances.isEmpty) {
          return const HorizonUI.HorizonTextFormField(
            enabled: false,
            label: "No assets",
          );
        }

        return Column(
          children: [
            HorizonUI.HorizonSearchableDropdownMenu<Balance>(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: "Destroy Asset",
              items: balances
                  .map((balance) => DropdownMenuItem(
                      value: balance,
                      child: Text(displayAssetName(
                          balance.asset, balance.assetInfo.assetLongname))))
                  .toList(),
              onChanged: (Balance? value) => setState(() {
                balance_ = value;
                quantityController.text = '';
                assetError = false;
              }),
              selectedValue: balance_,
              displayStringForOption: (Balance balance) => displayAssetName(
                  balance.asset, balance.assetInfo.assetLongname),
            ),
            if (assetError)
              const Text(
                'Please select an asset to destroy',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            HorizonUI.HorizonTextFormField(
              label: 'Quantity to destroy',
              enabled: balance_ != null,
              controller: quantityController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a quantity per unit';
                }
                if (Decimal.parse(value) >
                    Decimal.parse(balance_!.quantityNormalized)) {
                  return 'Quantity to destroy cannot be greater than available supply';
                }
                return null;
              },
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              inputFormatters: [
                balance_?.assetInfo.divisible == true
                    ? DecimalTextInputFormatter(decimalRange: 8)
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              onFieldSubmitted: (value) {
                _handleInitialSubmit(formKey);
              },
            ),
            const SizedBox(height: 16),
            HorizonUI.HorizonTextFormField(
              controller: TextEditingController(
                  text: balance_?.quantityNormalized ?? ''),
              enabled: false,
              label: 'Available supply',
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    if (balance_ == null) {
      assetError = true;
      return;
    }
    if (formKey.currentState!.validate()) {
      final quantity = getQuantityForDivisibility(
          inputQuantity: quantityController.text,
          divisible: balance_!.assetInfo.divisible);
      context.read<ComposeDestroyBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
            params: ComposeDestroyEventParams(
              assetName: balance_!.asset,
              quantity: quantity,
              tag: tagController.text,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDestroyResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: 'Source',
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Asset',
        controller: TextEditingController(
            text:
                displayAssetName(params.asset, params.assetInfo.assetLongname)),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Quantity to destroy',
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: 'Tag',
        controller: TextEditingController(text: params.tag),
        keyboardType: TextInputType.text,
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeDestroyBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDestroyBloc>().add(
            ReviewSubmitted<ComposeDestroyResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDestroyBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeDestroyBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }
}
