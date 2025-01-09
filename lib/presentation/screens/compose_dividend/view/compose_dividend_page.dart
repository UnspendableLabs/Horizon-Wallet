import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/asset.dart';
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
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

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
  bool assetError = false;
  String? xcpError;
  bool maxAmountError = false;

  @override
  void initState() {
    super.initState();
    quantityPerUnitController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    quantityPerUnitController.removeListener(() {
      setState(() {});
    });
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
              _buildConfirmationDetails(composeTransaction, state),
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
    final xcpFee = state.dividendXcpFeeState.maybeWhen(
      success: (dividendXcpFee) => dividendXcpFee,
      error: (error) {
        xcpError = error;
        return 0;
      },
      orElse: () => 0,
    );
    if (xcpError != null) {
      return [
        SelectableText('Error fetching dividend XCP fee: $xcpError'),
      ];
    }
    final balances = state.balancesState.maybeWhen(
      success: (balances) => balances,
      orElse: () => [],
    );
    return state.assetState.maybeWhen(
      success: (asset) => [
        HorizonUI.HorizonTextFormField(
          label: 'Source Address',
          enabled: false,
          controller: TextEditingController(text: widget.address),
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          label: 'Target Asset (holders will receive dividend)',
          enabled: false,
          controller: TextEditingController(
              text: displayAssetName(asset.asset, asset.assetLongname)),
        ),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          label: 'Target Asset Total Supply (not including issuer\'s balance)',
          enabled: false,
          controller: TextEditingController(
              text: asset.divisible!
                  ? (Decimal.parse(asset.supplyNormalized!) -
                          Decimal.parse(balances
                              .firstWhere((balance) =>
                                  balance.asset == widget.assetName)
                              .quantityNormalized))
                      .toStringAsFixed(8)
                  : (Decimal.parse(asset.supplyNormalized!) -
                          Decimal.parse(balances
                              .firstWhere((balance) =>
                                  balance.asset == widget.assetName)
                              .quantityNormalized))
                      .toString()),
        ),
        const SizedBox(height: 16),
        _buildAssetInput(state, loading, formKey, 'Dividend Payment Asset'),
        const SizedBox(height: 16),
        HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'XCP Fee',
          controller: TextEditingController(
              text:
                  '${quantityToQuantityNormalizedString(quantity: xcpFee, divisible: true)} XCP'),
        ),
      ],
      error: (error) => [
        SelectableText('Error fetching asset ${widget.assetName}: $error'),
      ],
      loading: () => [
        HorizonUI.HorizonTextFormField(
          enabled: false,
          label: 'Source',
          controller: TextEditingController(text: widget.address),
        ),
        const SizedBox(height: 16),
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
            SizedBox(height: 16),
            HorizonUI.HorizonTextFormField(
              enabled: false,
              label: 'XCP Fee',
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
              floatingLabelBehavior: FloatingLabelBehavior.always,
              label: "Dividend Payment Asset",
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
                assetError = false;
              }),
              selectedValue: dividendBalance,
              displayStringForOption: (Balance balance) => displayAssetName(
                  balance.asset, balance.assetInfo.assetLongname),
            ),
            if (assetError)
              const Text(
                'Please select a dividend payment asset',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            HorizonUI.HorizonTextFormField(
              label: 'Payment Amount (per unit of target asset)',
              enabled: dividendBalance != null,
              controller: quantityPerUnitController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a quantity per unit';
                }
                maxAmountError = false;
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              inputFormatters: [
                dividendBalance?.assetInfo.divisible == true
                    ? DecimalTextInputFormatter(decimalRange: 8)
                    : FilteringTextInputFormatter.digitsOnly,
              ],
              onFieldSubmitted: (value) {
                _handleInitialSubmit(formKey);
              },
              suffix: dividendBalance != null
                  ? TextButton(
                      onPressed: () {
                        state.assetState.maybeWhen(
                          success: (asset) {
                            final maxAmount = _calculateMaxAmount(
                                dividendBalance!,
                                asset,
                                balances.firstWhere((balance) =>
                                    balance.asset == widget.assetName));
                            quantityPerUnitController.text = maxAmount;
                          },
                          orElse: () {},
                        );
                      },
                      child: const Text('MAX'),
                    )
                  : null,
            ),
            if (maxAmountError)
              const SelectableText(
                'Not enough balance to pay max dividend',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            HorizonUI.HorizonTextFormField(
              enabled: false,
              label: 'Total Dividend Balance',
              controller: TextEditingController(
                text: dividendBalance != null
                    ? '${dividendBalance!.quantityNormalized} ${displayAssetName(dividendBalance!.asset, dividendBalance!.assetInfo.assetLongname)}'
                    : '',
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  String _calculateMaxAmount(
      Balance dividendBalance, Asset targetAsset, Balance targetAssetBalance) {
    try {
      final dividendQuantity =
          Decimal.parse(dividendBalance.quantityNormalized);
      final targetAssetSupply = Decimal.parse(targetAsset.supplyNormalized!) -
          Decimal.parse(targetAssetBalance.quantityNormalized);

      if (targetAssetSupply == Decimal.zero) {
        return '0';
      }

      // Convert the Rational to a decimal string by performing the actual division
      final rational = dividendQuantity / targetAssetSupply;
      final rawValue =
          rational.numerator.toDouble() / rational.denominator.toDouble();
      // If asset is not divisible
      if (!dividendBalance.assetInfo.divisible) {
        if (rawValue < 1) {
          maxAmountError = true;
          return '0';
        }
        // Round down to nearest whole number
        return rawValue.floor().toString();
      }

      // For divisible assets, round to 8 decimal places
      final roundedDown = (rawValue * 1e8).floor() / 1e8;
      final decimalValue = Decimal.parse(roundedDown.toString());

      return decimalValue.toString();
    } catch (e) {
      maxAmountError = true;
      return '0';
    }
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    if (dividendBalance == null) {
      setState(() {
        assetError = true;
      });
      return;
    }
    if (maxAmountError) {
      return;
    }
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

  List<Widget> _buildConfirmationDetails(
      dynamic composeTransaction, ComposeDividendState state) {
    final xcpFee = state.dividendXcpFeeState.maybeWhen(
      success: (dividendXcpFee) => dividendXcpFee,
      error: (error) {
        xcpError = error;
        return 0;
      },
      orElse: () => 0,
    );
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
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        enabled: false,
        label: 'XCP Fee',
        controller: TextEditingController(
            text:
                '${quantityToQuantityNormalizedString(quantity: xcpFee, divisible: true)} XCP'),
      ),
    ];
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
