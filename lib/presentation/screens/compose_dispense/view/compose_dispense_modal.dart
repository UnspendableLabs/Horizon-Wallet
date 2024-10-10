import 'package:collection/collection.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/format.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/compose_send/view/asset_dropdown.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';

class ComposeDispensePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String? initialDispenserAddress;

  const ComposeDispensePageWrapper({
    required this.dashboardActivityFeedBloc,
    this.initialDispenserAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeDispenseBloc(
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          fetchDispenseFormDataUseCase:
              GetIt.I.get<FetchDispenseFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeDispensePage(
          initialDispenserAddress: initialDispenserAddress,
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDispensePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  final String? initialDispenserAddress;

  const ComposeDispensePage({
    super.key,
    this.initialDispenserAddress,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeDispensePageState createState() => ComposeDispensePageState();
}

class ComposeDispensePageState extends State<ComposeDispensePage> {
  TextEditingController dispenserController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController openAddressController = TextEditingController();

  String? asset;
  Balance? balance_;

  @override
  void initState() {
    super.initState();
    // TODO: not sure why we are doing this.
    openAddressController.text = widget.address.address;
    dispenserController.text = widget.initialDispenserAddress ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeDispenseBloc, ComposeDispenseState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeDispenseBloc>().add(ChangeFeeOption(value: fee)),
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
      int quantity =
          (Decimal.parse(quantityController.text) * Decimal.fromInt(100000000))
              .toBigInt()
              .toInt();
      String dispenser = dispenserController.text;

      // Dispatch the event with the calculated values
      context.read<ComposeDispenseBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: ComposeDispenseEventParams(
                address: widget.address.address,
                dispenser: dispenser,
                quantity: quantity),
          ));
    }
  }

  Widget _buildQuantityInput(ComposeDispenseState state,
      void Function() handleInitialSubmit, bool loading) {
    return state.balancesState.maybeWhen(orElse: () {
      return _buildQuantityInputField(
          state,
          null,
          // handleInitialSubmit,
          loading);
    }, success: (balances) {
      if (balances.isEmpty) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      Balance? balance =
          balance_ ?? _getBalanceForSelectedAsset(balances, "BTC");

      if (balance == null) {
        return const HorizonUI.HorizonTextFormField(
          enabled: false,
        );
      }

      return _buildQuantityInputField(
          state,
          balance,
          // handleInitialSubmit,
          loading);
    });
  }

  Widget _buildQuantityInputField(ComposeDispenseState state, Balance? balance,
      /* void Function() handleInitialSubmit, */ bool loading) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          key: Key('dispense_btc_quantity_input'),
          controller: quantityController,
          enabled: !loading,
          // onChanged: (value) {
          //   context
          //       .read<ComposeDispenseBloc>()
          //       .add(ChangeGiveQuantity(value: value));
          // },
          label: 'Quantity',
          inputFormatters: [DecimalTextInputFormatter(decimalRange: 8)],
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a quantity';
            }
            Decimal input = Decimal.parse(value);
            Decimal max = Decimal.parse(balance?.quantityNormalized ?? '0');
            if (input > max) {
              return "give quantity exceeds available balance";
            }
            // why are we doing this?
            setState(() {
              balance_ = balance;
            });
            return null;
          },
        ),
        state.balancesState.maybeWhen(orElse: () {
          return const SizedBox.shrink();
        }, success: (_) {
          return asset != null
              ? Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2.0),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  List<Widget> _buildInitialFormFields(
      ComposeDispenseState state, bool loading, GlobalKey<FormState> formKey) {
    return [
      HorizonUI.HorizonTextFormField(
        enabled: false,
        controller: openAddressController,
        label: "Source Address",
      ),
      const SizedBox(height: 16.0),
      _buildDispenserInput(),
      const SizedBox(height: 16.0),
      _buildQuantityInput(state, () {
        _handleInitialSubmit(formKey);
      }, loading),
      const SizedBox(height: 16.0),
    ];
  }

  Widget _buildDispenserInput() {
    return HorizonUI.HorizonTextFormField(
      key: const Key('dispense_dispenesr_input'),
      controller: dispenserController,
      label: 'Dispenser Address',
      // keyboardType: const TextInputType.numberWithOptions(
      //     decimal: false, signed: false), // No decimal allowed
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Dispener Address is required';
        }
        return null;
      },
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeDispenseResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.address),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Dispenser",
        controller: TextEditingController(text: params.dispenser),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeDispenseBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDispenseBloc>().add(
            FinalizeTransactionEvent<ComposeDispenseResponse>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeDispenseBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeDispenseBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}

_getBalanceForSelectedAsset(List<Balance> balances, String asset) {
  if (balances.isEmpty) {
    return null;
  }

  return balances.firstWhereOrNull((balance) => balance.asset == asset) ??
      balances[0];
}
