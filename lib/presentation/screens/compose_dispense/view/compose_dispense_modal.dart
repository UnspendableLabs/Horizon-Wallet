import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/repositories/dispenser_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/shared_util.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_bloc.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_event.dart';
import 'package:horizon/presentation/screens/compose_dispense/bloc/compose_dispense_state.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/estimate_dispenses.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_dispense/usecase/fetch_open_dispensers_on_address.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:rational/rational.dart';

class ComposeDispensePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String? initialDispenserAddress;
  final String currentAddress;
  const ComposeDispensePageWrapper({
    required this.dashboardActivityFeedBloc,
    this.initialDispenserAddress,
    required this.currentAddress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeDispenseBloc(
          logger: GetIt.I.get<Logger>(),
          estimateDispensesUseCase: GetIt.I.get<EstimateDispensesUseCase>(),
          fetchOpenDispensersOnAddressUseCase:
              GetIt.I.get<FetchOpenDispensersOnAddressUseCase>(),
          dispenserRepository: GetIt.I.get<DispenserRepository>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          fetchDispenseFormDataUseCase:
              GetIt.I.get<FetchDispenseFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(FetchFormData(
            currentAddress: currentAddress,
            initialDispenserAddress: initialDispenserAddress)),
        child: ComposeDispensePage(
          initialDispenserAddress: initialDispenserAddress,
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeDispensePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;
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

// Define an enum to represent the input method
enum InputMethod {
  Quantity,
  Lots,
}

class ComposeDispensePageState extends State<ComposeDispensePage> {
  TextEditingController dispenserController = TextEditingController();
  TextEditingController openAddressController = TextEditingController();
  TextEditingController buyQuantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController lotController = TextEditingController();

  String? _selectedAsset;
  Dispenser? _selectedDispenser;
  String? _buyQuantity;

  // Variable to hold the selected input method
  InputMethod _inputMethod = InputMethod.Quantity;

  // Add variable to hold the error message for lot input
  String? _lotInputError;

  @override
  void initState() {
    super.initState();
    openAddressController.text = widget.address;
    dispenserController.text = widget.initialDispenserAddress ?? "";
  }

  @override
  void dispose() {
    dispenserController.dispose();
    openAddressController.dispose();
    buyQuantityController.dispose();
    priceController.dispose();
    lotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeDispenseBloc, ComposeDispenseState>(
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeDispenseBloc>().add(ChangeFeeOption(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
      buildConfirmationFormFields: (state, composeTransaction, formKey) =>
          _buildConfirmationDetails(state, composeTransaction),
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
      int priceQuantity = getQuantityForDivisibility(
          divisible: true, inputQuantity: priceController.text);
      String dispenser = dispenserController.text;

      // Dispatch the event with the calculated values
      context.read<ComposeDispenseBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address,
            params: ComposeDispenseEventParams(
                address: widget.address,
                dispenser: dispenser,
                quantity: priceQuantity),
          ));
    }
  }

  Widget _buildOpenDispensersList(ComposeDispenseState state) {
    return state.dispensersState.when(
      initial: () => Container(),
      loading: () => const Center(child: CircularProgressIndicator()),
      success: (dispensers) {
        // Extract unique assets for the dropdown
        final assets = dispensers.map((d) => d.asset).toSet().toList();

        if (assets.isEmpty) {
          // Handle the case where there are no assets
          return const Text('No dispensers available at this address.');
        }

        if (_selectedAsset == null) {
          _selectedAsset = assets.first;
          _selectedDispenser = dispensers.firstWhere(
            (dispenser) => dispenser.asset == _selectedAsset,
          );
        }

        String selectedAsset = _selectedAsset!;

        List<Widget> dispenserWidgets = [
          Column(
            children:
                _buildDispenserRowItems(dispensers, assets, selectedAsset),
          ),
        ];

        return Column(
          children: dispenserWidgets,
        );
      },
      error: (error) => Text('Error: $error'),
    );
  }

  List<Widget> _buildDispenserRowItems(
      List<Dispenser> dispensers, List<String> assets, String selectedAsset) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final disabledTextColor = isDarkMode ? Colors.grey[500] : Colors.grey[400];

    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: HorizonUI.HorizonDropdownMenu<String>(
              key: const Key('asset_dropdown_menu'),
              items: assets.map((String asset) {
                final dispenserForAsset = dispensers.firstWhere(
                  (dispenser) => dispenser.asset == asset,
                );
                return DropdownMenuItem<String>(
                  key: Key('asset_dropdown_item_$asset'),
                  value: asset,
                  child: Text(displayAssetName(dispenserForAsset.asset,
                      dispenserForAsset.assetInfo.assetLongname)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedAsset = newValue;
                    _selectedAsset = newValue;
                    _selectedDispenser = dispensers.firstWhere(
                      (dispenser) => dispenser.asset == newValue,
                    );
                    _buyQuantity = null;
                    _lotInputError = null;
                  });
                }
              },
              label: 'Asset',
              selectedValue: selectedAsset,
              selectedItemBuilder: (BuildContext context) {
                return assets.map((String asset) {
                  final dispenserForAsset = dispensers.firstWhere(
                    (dispenser) => dispenser.asset == asset,
                  );
                  return DropdownMenuItem<String>(
                    value: asset,
                    child: Text(displayAssetName(dispenserForAsset.asset,
                        dispenserForAsset.assetInfo.assetLongname)),
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: HorizonUI.HorizonTextFormField(
              label: "Unit price",
              controller: TextEditingController(
                  text: _selectedDispenser?.priceNormalized),
              enabled: false,
              textColor: disabledTextColor,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16.0),
      IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quantity per dispense",
                      style: TextStyle(
                        fontSize: 12,
                        color: disabledTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedDispenser?.giveQuantityNormalized ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Price per dispense",
                      style: TextStyle(
                        fontSize: 12,
                        color: disabledTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedDispenser?.satoshirateNormalized ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quantity available",
                      style: TextStyle(
                        fontSize: 12,
                        color: disabledTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedDispenser?.giveRemainingNormalized ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildBuyQuantityInput(GlobalKey<FormState> formKey) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_selectedDispenser == null) {
      return const SizedBox.shrink();
    }

    // ignore_for_file: unnecessary_non_null_assertion
    final quantityPerDispense =
        Decimal.parse(_selectedDispenser!.giveQuantityNormalized!);
    final remaining =
        Decimal.parse(_selectedDispenser!.giveRemainingNormalized!);
    final maxFullDispenses = (remaining / quantityPerDispense).floor().toInt();

    List<Decimal> values = [];
    for (int i = 1; i <= maxFullDispenses; i++) {
      values.add(quantityPerDispense * Decimal.fromInt(i));
    }

    if (remaining > values.last &&
        remaining < values.last + quantityPerDispense) {
      values.add(remaining);
    }

    if (_buyQuantity == null || _buyQuantity!.isEmpty) {
      _buyQuantity = values.first.toString();
      _updateLotFromQuantity();
      _lotInputError = null;
    }

    int currentIndex = 0;
    if (_buyQuantity != null && _buyQuantity!.isNotEmpty) {
      final currentValue = Decimal.parse(_buyQuantity!);
      currentIndex = values.indexWhere((value) => value == currentValue);
      if (currentIndex == -1) currentIndex = 0;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio buttons to select input method
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Quantity'),
                leading: Radio<InputMethod>(
                  value: InputMethod.Quantity,
                  groupValue: _inputMethod,
                  onChanged: (InputMethod? value) {
                    setState(() {
                      _inputMethod = value!;
                      _buyQuantity = values[currentIndex].toString();
                      lotController.clear();
                      _updateLotFromQuantity();
                      _lotInputError = null;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Lots'),
                leading: Radio<InputMethod>(
                  value: InputMethod.Lots,
                  groupValue: _inputMethod,
                  onChanged: (InputMethod? value) {
                    setState(() {
                      _inputMethod = value!;
                      // Clear quantity input
                      _buyQuantity = '';
                      _lotInputError = null;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        // Inputs based on selected method
        Row(
          children: [
            // Dispense Quantity Input
            Expanded(
              child: AbsorbPointer(
                absorbing: _inputMethod != InputMethod.Quantity,
                child: Opacity(
                  opacity: _inputMethod == InputMethod.Quantity ? 1.0 : 0.5,
                  child: Container(
                    key: const Key('dispense_quantity_input'),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _inputMethod == InputMethod.Quantity &&
                                  currentIndex > 0
                              ? () {
                                  setState(() {
                                    currentIndex--;
                                    _buyQuantity =
                                        values[currentIndex].toString();
                                    _updateLotFromQuantity();
                                    _lotInputError = null;
                                  });
                                }
                              : null,
                        ),
                        Expanded(
                          child: Text(
                            key: const Key('buy_quantity_text'),
                            '${values[currentIndex]}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _inputMethod == InputMethod.Quantity &&
                                  currentIndex < values.length - 1
                              ? () {
                                  setState(() {
                                    currentIndex++;
                                    _buyQuantity =
                                        values[currentIndex].toString();
                                    _updateLotFromQuantity();
                                    _lotInputError = null;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Lot Input Field
            Expanded(
              child: HorizonUI.HorizonTextFormField(
                key: const Key('lot_input'),
                label: 'Lots',
                controller: lotController,
                enabled: _inputMethod == InputMethod.Lots,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (_selectedDispenser == null) return null;
                  if (_inputMethod == InputMethod.Lots) {
                    if (value == null || value.isEmpty) {
                      return 'Lots are required';
                    } else {
                      if (int.tryParse(value) != null &&
                          int.tryParse(value)! >
                              (Decimal.parse(_selectedDispenser!
                                          .giveRemainingNormalized!) /
                                      Decimal.parse(_selectedDispenser!
                                          .giveQuantityNormalized!))
                                  .floor()
                                  .toInt()) {
                        return 'Lots entered are greater\nthan lots available.\nMax: ${(Decimal.parse(_selectedDispenser!.giveRemainingNormalized!) / Decimal.parse(_selectedDispenser!.giveQuantityNormalized!)).floor()}';
                      }
                    }
                    if (_lotInputError != null) {
                      return _lotInputError;
                    }
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) {
                  _onLotChanged(value);
                },
                // Add the hint for max lots available
                helperText: _inputMethod == InputMethod.Lots
                    ? 'Max Lots available: ${(Decimal.parse(_selectedDispenser!.giveRemainingNormalized!) / Decimal.parse(_selectedDispenser!.giveQuantityNormalized!)).floor()}'
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _updateLotFromQuantity() {
    if (_selectedDispenser == null || _buyQuantity == null) return;

    final quantityPerDispense =
        Decimal.parse(_selectedDispenser!.giveQuantityNormalized!);

    final totalQuantity = Decimal.parse(_buyQuantity!);
    final lots = (totalQuantity / quantityPerDispense);

    lotController.text = lots.toString();
  }

  void _onLotChanged(String lotsStr) {
    if (_selectedDispenser == null) return;

    if (lotsStr.isEmpty) {
      setState(() {
        _buyQuantity = '0';
        _lotInputError = null;
      });
      return;
    }
    if (_inputMethod == InputMethod.Lots) {
      int lots = int.tryParse(lotsStr) ?? 0;

      final quantityPerDispense =
          Decimal.parse(_selectedDispenser!.giveQuantityNormalized!);

      final totalQuantity = quantityPerDispense * Decimal.fromInt(lots);

      // Calculate giveRemaining
      final giveRemaining =
          Decimal.parse(_selectedDispenser!.giveRemainingNormalized!);

      // Check if totalQuantity exceeds giveRemaining
      if (totalQuantity > giveRemaining) {
        setState(() {
          _lotInputError = 'Lots entered are greater than lots available.';
        });
      } else {
        setState(() {
          _lotInputError = null;
        });
      }

      setState(() {
        _buyQuantity = totalQuantity.toString();
      });
    }
  }

  Widget _buildPriceInput(ComposeDispenseState state) {
    if (_selectedDispenser == null) {
      return const SizedBox.shrink();
    }
    final String price = _buyQuantity != null && _buyQuantity!.isNotEmpty
        ? ((Decimal.parse(_buyQuantity!) /
                    Decimal.parse(
                        _selectedDispenser!.giveQuantityNormalized!)) *
                Rational.parse(_selectedDispenser!.satoshiPriceNormalized!))
            .toDouble()
            .toStringAsFixed(8)
        : '';

    priceController.text = price;
    return HorizonUI.HorizonTextFormField(
      key: const Key('price_input'),
      label: 'Price',
      controller: priceController,
      enabled: false,
    );
  }

  Widget _buildBuyQuantityAndPrice(
      GlobalKey<FormState> formKey, ComposeDispenseState state) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_selectedDispenser == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quantity to be dispensed",
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode
                ? darkThemeInputLabelColor
                : lightThemeInputLabelColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildBuyQuantityInput(formKey),
        // _buildGiveQuantityHint(),
        const SizedBox(height: 16.0),
        // Price Input Centered Below
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: _buildPriceInput(state),
            ),
          ],
        ),
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
      HorizonUI.HorizonTextFormField(
        key: const Key('dispense_dispenser_input'),
        controller: dispenserController,
        label: 'Dispenser Address',
        onChanged: (value) {
          dispenserController.text = value;
          context
              .read<ComposeDispenseBloc>()
              .add(DispenserAddressChanged(address: value));
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Dispener Address is required';
          }
          return null;
        },
      ),
      const SizedBox(height: 16.0),
      _buildOpenDispensersList(state),
      const SizedBox(height: 16.0),
      _buildBuyQuantityAndPrice(formKey, state),
      const SizedBox(height: 16.0),
    ];
  }

  List<Widget> _buildConfirmationDetails(state_, dynamic composeTransaction) {
    final estimatedDispenses = state_.otherParams as List<EstimatedDispense>;
    final params = (composeTransaction as ComposeDispenseResponse).params;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDarkMode ? Colors.white : Colors.black;

    final selectedDispense = estimatedDispenses
        .where((d) => d.dispenser.asset == _selectedAsset)
        .firstOrNull;

    final labelStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: labelColor,
    );

    final assetTextStyle = TextStyle(
      fontSize: 16,
      color: labelColor,
    );

    Widget buildDispenseRow(EstimatedDispense dispense) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            "${dispense.estimatedQuantityNormalized} ${displayAssetName(dispense.dispenser.asset, dispense.dispenser.assetInfo.assetLongname)}",
            style: assetTextStyle,
          ),
          const SizedBox(height: 4),
          SelectableText(
            "(${dispense.dispenser.giveQuantityNormalized} x ${dispense.estimatedUnits})",
            style: assetTextStyle,
          ),
          const Divider(height: 16),
        ],
      );
    }

    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Dispenser",
        controller: TextEditingController(text: params.destination),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "BTC Paid",
        controller: TextEditingController(
          text: "${satoshisToBtc(params.quantity).toStringAsFixed(8)} BTC",
        ),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Dispense:",
          style: labelStyle,
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 16.0),
        child: selectedDispense == null
            ? SelectableText(
                "Error: $_selectedAsset will not be dispensed",
                style: const TextStyle(color: Colors.red),
              )
            : buildDispenseRow(selectedDispense),
      ),
      if (estimatedDispenses
          .where((d) => d.dispenser.asset != _selectedAsset)
          .isNotEmpty) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Other dispenses:",
            style: labelStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
          child: Column(
            children: estimatedDispenses
                .where((d) => d.dispenser.asset != _selectedAsset)
                .map((dispense) => buildDispenseRow(dispense))
                .toList(),
          ),
        ),
      ],
      const SizedBox(height: 16.0),
    ];
  }

  void _onConfirmationBack() {
    context.read<ComposeDispenseBloc>().add(FetchFormData(
          currentAddress: widget.address,
          initialDispenserAddress: dispenserController.text,
        ));
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
    context.read<ComposeDispenseBloc>().add(FetchFormData(
          currentAddress: widget.address,
          initialDispenserAddress: dispenserController.text,
        ));
  }
}
