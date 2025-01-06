import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_bloc.dart';
import 'package:horizon/presentation/screens/compose_dividend/bloc/compose_dividend_state.dart';
import 'package:horizon/presentation/screens/compose_dividend/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeDividendPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final String assetName;

  const ComposeDividendPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.assetName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDividendBloc(
          composeRepository: GetIt.I.get<ComposeRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          fetchDividendFormDataUseCase:
              GetIt.I.get<FetchDividendFormDataUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          logger: GetIt.I.get<Logger>(),
        )..add(FetchFormData(
            currentAddress: currentAddress, assetName: assetName)),
        child: ComposeDividendPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          assetName: assetName,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDividendPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
  final String assetName;

  const ComposeDividendPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.assetName,
  });

  @override
  ComposeDividendPageState createState() => ComposeDividendPageState();
}

class ComposeDividendPageState extends State<ComposeDividendPage> {
  TextEditingController quantityPerUnitController = TextEditingController();
  TextEditingController assetController = TextEditingController();
  bool _submitted = false;
  Balance? dividendBalance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    quantityPerUnitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeDividendBloc, ComposeDividendState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<ComposeDividendBloc, ComposeDividendState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<ComposeDividendBloc>()
              .add(ChangeFeeOption(value: fee)),
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
      ComposeDividendState state, bool loading, GlobalKey<FormState> formKey) {
    return state.assetState.maybeWhen(
      success: (asset) => [
        HorizonUI.HorizonTextFormField(
          label: 'Asset name',
          enabled: false,
          controller: TextEditingController(
              text: displayAssetName(asset.asset, asset.assetLongname)),
        ),
        const SizedBox(height: 16),
        _buildAssetInput(state, loading, formKey, 'Dividend asset'),
      ],
      error: (error) => [
        SelectableText('Error fetching asset ${widget.assetName}: $error'),
      ],
      loading: () => [
        const HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'Asset name',
        ),
        const SizedBox(height: 16),
        const Column(
          children: [
            HorizonUI.HorizonTextFormField(
              enabled: false,
              label: 'Dividend Asset',
            ),
            SizedBox(height: 16),
            HorizonUI.HorizonTextFormField(
              enabled: false,
              label: 'Quantity per unit',
            ),
          ],
        ),
      ],
      orElse: () => [],
    );
  }

  Widget _buildAssetInput(
      ComposeDividendState state, bool loading, GlobalKey<FormState> formKey,
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
              label: "Select a dividend asset",
              items: balances
                  .where((balance) => balance.asset != widget.assetName)
                  .map((balance) => DropdownMenuItem(
                      value: balance,
                      child: Text(displayAssetName(
                          balance.asset, balance.assetInfo.assetLongname))))
                  .toList(),
              onChanged: (Balance? value) => setState(() {
                dividendBalance = value;
                quantityPerUnitController.text = '';
              }),
              selectedValue: dividendBalance,
              displayStringForOption: (Balance balance) => displayAssetName(
                  balance.asset, balance.assetInfo.assetLongname),
            ),
            const SizedBox(height: 20),
            HorizonUI.HorizonTextFormField(
              label: 'Quantity per unit',
              enabled: dividendBalance != null,
              controller: quantityPerUnitController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a quantity per unit';
                }
                return null;
              },
              inputFormatters: [
                dividendBalance?.assetInfo.divisible == true
                    ? DecimalTextInputFormatter(decimalRange: 8)
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              onFieldSubmitted: (value) {
                _handleInitialSubmit(formKey);
              },
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
    if (formKey.currentState!.validate()) {
      final quantity = getQuantityForDivisibility(
          inputQuantity: quantityPerUnitController.text,
          divisible: dividendBalance!.assetInfo.divisible);
      context.read<ComposeDividendBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address,
            params: ComposeDividendEventParams(
              assetName: widget.assetName,
              quantityPerUnit: quantity,
              dividendAsset: dividendBalance!.asset,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDividendResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'Source',
        controller: TextEditingController(text: params.source),
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'Asset name',
        controller: TextEditingController(
            text:
                displayAssetName(params.asset, params.assetInfo.assetLongname)),
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'Dividend asset',
        controller: TextEditingController(
            text: displayAssetName(
                params.dividendAsset, params.dividendAssetInfo.assetLongname)),
      ),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'Quantity per unit of dividend asset',
        controller:
            TextEditingController(text: params.quantityPerUnitNormalized),
      ),
    ];
//
  }

  void _onConfirmationBack() {
    context.read<ComposeDividendBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDividendBloc>().add(
            FinalizeTransactionEvent<ComposeDividendResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDividendBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<ComposeDividendBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }
}
