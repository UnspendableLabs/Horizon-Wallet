import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/asset.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
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
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/issuance_checkboxes.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

class UpdateIssuancePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final IssuanceActionType actionType;
  final String assetName;
  final String? assetLongname;

  const UpdateIssuancePageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.actionType,
    required this.assetName,
    required this.assetLongname,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => UpdateIssuanceBloc(
          assetRepository: GetIt.I.get<AssetRepository>(),
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          bitcoindService: GetIt.I.get<BitcoindService>(),
          utxoRepository: GetIt.I.get<UtxoRepository>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          transactionService: GetIt.I.get<TransactionService>(),
          addressRepository: GetIt.I.get<AddressRepository>(),
          accountRepository: GetIt.I.get<AccountRepository>(),
          walletRepository: GetIt.I.get<WalletRepository>(),
          encryptionService: GetIt.I.get<EncryptionService>(),
          addressService: GetIt.I.get<AddressService>(),
          transactionRepository: GetIt.I.get<TransactionRepository>(),
          transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
          bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
        )..add(FetchFormData(
            assetName: assetName, currentAddress: state.currentAddress)),
        child: UpdateIssuancePage(
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          address: state.currentAddress,
          actionType: actionType,
          assetName: assetName,
          assetLongname: assetLongname,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class UpdateIssuancePage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  final IssuanceActionType actionType;
  final String assetName;
  final String? assetLongname;

  const UpdateIssuancePage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.actionType,
    required this.assetName,
    this.assetLongname,
  });

  @override
  UpdateIssuancePageState createState() => UpdateIssuancePageState();
}

class UpdateIssuancePageState extends State<UpdateIssuancePage> {
  late TextEditingController _subassetController;
  late TextEditingController _quantityController;
  late TextEditingController _newDescriptionController;
  late TextEditingController _destinationAddressController;

  @override
  void initState() {
    super.initState();
    _subassetController = TextEditingController(
        text: '${widget.assetLongname ?? widget.assetName}.');
    _quantityController = TextEditingController();
    _newDescriptionController = TextEditingController();
    _destinationAddressController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _subassetController.dispose();
    _quantityController.dispose();
    _newDescriptionController.dispose();
    _destinationAddressController.dispose();
  }

  // ignore: avoid_init_to_null
  late bool? isDivisible = null;
  // ignore: avoid_init_to_null
  late bool? isLocked = null;

  late bool? isReset = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateIssuanceBloc, UpdateIssuanceState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.assetState.maybeWhen(
          loading: () =>
              ComposeBasePage<UpdateIssuanceBloc, UpdateIssuanceState>(
            address: widget.address,
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<UpdateIssuanceBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormLoadingFields(state, loading, formKey),
            onInitialCancel: () => {},
            onInitialSubmit: (formKey) => {},
            buildConfirmationFormFields: (composeTransaction, formKey) => [],
            onConfirmationBack: () => {},
            onConfirmationContinue: (composeTransaction, fee, formKey) => {},
            onFinalizeSubmit: (password, formKey) => {},
            onFinalizeCancel: () => {},
          ),
          success: (originalAsset) {
            return ComposeBasePage<UpdateIssuanceBloc, UpdateIssuanceState>(
              address: widget.address,
              dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
              onFeeChange: (fee) => context
                  .read<UpdateIssuanceBloc>()
                  .add(ChangeFeeOption(value: fee)),
              buildInitialFormFields: (state, loading, formKey) =>
                  _buildInitialFormFields(
                      state, loading, formKey, originalAsset),
              onInitialCancel: () => _handleInitialCancel(),
              onInitialSubmit: (formKey) =>
                  _handleInitialSubmit(formKey, originalAsset),
              buildConfirmationFormFields: (composeTransaction, formKey) =>
                  _buildConfirmationDetails(composeTransaction, originalAsset),
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
          error: (error) => SelectableText(error),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  List<Widget> _buildInitialFormLoadingFields(
      UpdateIssuanceState state, bool loading, GlobalKey<FormState> formKey) {
    return switch (widget.actionType) {
      IssuanceActionType.reset => [
          const HorizonUI.HorizonTextFormField(
              label: 'Reset Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Currently Supply',
            enabled: false,
          ),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Reset Quantity',
            enabled: false,
          )
        ],
      IssuanceActionType.lockDescription => [
          const HorizonUI.HorizonTextFormField(
              label: 'Lock Description for Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Current Description',
            enabled: false,
          ),
        ],
      IssuanceActionType.lockQuantity => [
          const HorizonUI.HorizonTextFormField(
              label: 'Lock Quantity for Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Quantity',
            enabled: false,
          )
        ],
      IssuanceActionType.changeDescription => [
          const HorizonUI.HorizonTextFormField(
              label: 'Update Description for Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Current Description',
            enabled: false,
          ),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: TextEditingController(),
            label: 'New Description',
            enabled: false,
          )
        ],
      IssuanceActionType.issueMore => [
          const HorizonUI.HorizonTextFormField(
              label: 'Issue More of Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const HorizonUI.HorizonTextFormField(
            label: 'Current Supply',
            enabled: false,
          ),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: TextEditingController(),
            label: 'Quantity to Add to Current Supply',
            enabled: false,
          ),
        ],
      IssuanceActionType.issueSubasset => [
          HorizonUI.HorizonTextFormField(
            controller: TextEditingController(),
            label: 'Subasset Name',
            hint: 'Enter the new subasset name',
            enabled: false,
          ),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Quantity',
            enabled: false,
          ),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Description (optional)',
            enabled: false,
          ),
        ],
      IssuanceActionType.transferOwnership => [
          const HorizonUI.HorizonTextFormField(
              label: 'Transfer Ownership of Asset',
              enabled: false,
              suffix: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const HorizonUI.HorizonTextFormField(
            label: 'Destination Address',
            enabled: false,
          ),
        ],
    };
  }

  List<Widget> _buildInitialFormFields(UpdateIssuanceState state, bool loading,
      GlobalKey<FormState> formKey, Asset originalAsset) {
    final assetName = originalAsset.assetLongname ?? originalAsset.asset;
    return switch (widget.actionType) {
      IssuanceActionType.reset => [
          // Resetting an asset allows the user to change the supply quantity of the asset and to change the divisibility
          HorizonUI.HorizonTextFormField(
              label: 'Reset Asset',
              controller: TextEditingController(text: assetName),
              enabled: false),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: HorizonUI.HorizonTextFormField(
                  label: 'Current Supply',
                  controller: TextEditingController(
                      text: originalAsset.supplyNormalized),
                  enabled: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: HorizonUI.HorizonTextFormField(
                  label: 'Currently Divisible',
                  controller: TextEditingController(
                      text: originalAsset.divisible == true ? 'true' : 'false'),
                  enabled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQuantityField(formKey, originalAsset, 'Reset Quantity'),
          const SizedBox(height: 16),
          IssuanceCheckboxes(
            isDivisible: isDivisible ?? originalAsset.divisible!,
            onDivisibleChanged: (bool? value) {
              setState(() {
                isDivisible = value ?? false;
                _quantityController.text = '';
              });
            },
            loading: loading,
            isReset: true,
          ),
        ],
      IssuanceActionType.lockDescription => [
          // Lock only the description of the asset
          HorizonUI.HorizonTextFormField(
              label: 'Lock Description for Asset',
              controller: TextEditingController(text: assetName),
              enabled: false),
          const SizedBox(height: 16),
          originalAsset.description != ''
              ? HorizonUI.HorizonTextFormField(
                  label: 'Current Description',
                  enabled: false,
                  controller:
                      TextEditingController(text: originalAsset.description),
                )
              : const Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText('Asset currently has no description')),
          const SizedBox(height: 16),
        ],
      IssuanceActionType.lockQuantity => [
          // locking the quantity will not allow the user to change the quantity in the future
          HorizonUI.HorizonTextFormField(
              label: 'Lock Quantity for Asset',
              controller: TextEditingController(text: assetName),
              enabled: false),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            label: 'Quantity',
            controller:
                TextEditingController(text: originalAsset.supplyNormalized),
            enabled: false,
          )
        ],
      IssuanceActionType.changeDescription => [
          // change the description of the asset
          HorizonUI.HorizonTextFormField(
              label: 'Update Description for Asset',
              enabled: false,
              controller: TextEditingController(text: assetName)),
          const SizedBox(height: 16),
          originalAsset.description != ''
              ? HorizonUI.HorizonTextFormField(
                  label: 'Current Description',
                  enabled: false,
                  controller:
                      TextEditingController(text: originalAsset.description),
                )
              : const Align(
                  alignment: Alignment.centerLeft,
                  child: SelectableText('Asset currently has no description')),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: _newDescriptionController,
            label: 'New Description',
            hint: 'Enter the new description for the asset',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                _handleInitialSubmit(formKey, originalAsset),
          )
        ],
      IssuanceActionType.issueMore => [
          // Add to the current supply of the asset
          HorizonUI.HorizonTextFormField(
              label: 'Issue More of Asset',
              enabled: false,
              controller: TextEditingController(text: assetName)),
          HorizonUI.HorizonTextFormField(
              label: 'Current Supply',
              enabled: false,
              controller:
                  TextEditingController(text: originalAsset.supplyNormalized)),
          const SizedBox(height: 16),
          _buildQuantityField(
              formKey, originalAsset, 'Quantity to Add to Current Supply'),
        ],
      IssuanceActionType.issueSubasset => [
          // Issue a subasset of the asset
          _buildSubassetNameField(formKey, originalAsset),
          const SizedBox(height: 16),
          _buildQuantityField(formKey, originalAsset, 'Quantity'),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            controller: _newDescriptionController,
            label: 'Description (optional)',
            onFieldSubmitted: (_) =>
                _handleInitialSubmit(formKey, originalAsset),
          ),
          const SizedBox(height: 16.0),
          IssuanceCheckboxes(
            isDivisible: isDivisible ?? originalAsset.divisible!,
            isLocked: isLocked ?? originalAsset.locked!,
            onDivisibleChanged: (bool? value) {
              setState(() {
                isDivisible = value ?? false;
                _quantityController.text = '';
              });
            },
            onLockChanged: (bool? value) {
              setState(() {
                isLocked = value ?? false;
              });
            },
          ),
        ],
      IssuanceActionType.transferOwnership => [
          // Transfer the asset to a new owner
          HorizonUI.HorizonTextFormField(
              label: 'Transfer Ownership of Asset',
              enabled: false,
              controller: TextEditingController(text: assetName)),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            label: 'Destination Address',
            controller: _destinationAddressController,
            onFieldSubmitted: (_) =>
                _handleInitialSubmit(formKey, originalAsset),
          ),
        ],
    };
  }

  Widget _buildQuantityField(
      GlobalKey<FormState> formKey, Asset originalAsset, String label) {
    return HorizonUI.HorizonTextFormField(
      controller: _quantityController,
      label: label,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      inputFormatters: [
        isDivisible ?? originalAsset.divisible!
            ? DecimalTextInputFormatter(decimalRange: 8)
            : FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a quantity';
        }
        return null;
      },
      onFieldSubmitted: (_) => _handleInitialSubmit(formKey, originalAsset),
    );
  }

  Widget _buildSubassetNameField(
      GlobalKey<FormState> formKey, Asset originalAsset) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          controller: _subassetController,
          textCapitalization: TextCapitalization.characters,
          label: 'Subasset Name',
          validator: (value) {
            if (value == null ||
                value.isEmpty ||
                value ==
                    '${originalAsset.assetLongname ?? originalAsset.asset}.') {
              return 'Please enter a subasset name';
            }
            return null;
          },
          onChanged: (value) {
            final prefix =
                '${originalAsset.assetLongname ?? originalAsset.asset}.';
            if (value.length < prefix.length) {
              // If the user is trying to delete the prefix, keep it intact
              _subassetController.value = TextEditingValue(
                text: prefix,
                selection: TextSelection.collapsed(offset: prefix.length),
              );
            } else {
              // Allow typing after the prefix, but ensure the prefix is always there
              String subAssetPart = value.substring(prefix.length);
              // Filter and capitalize alphanumeric characters
              String filteredPart = '';
              for (int i = 0;
                  i < subAssetPart.length && filteredPart.length < 20;
                  i++) {
                String char = subAssetPart[i].toUpperCase();
                if ((char.codeUnitAt(0) >= 65 &&
                        char.codeUnitAt(0) <= 90) || // A-Z
                    (char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57)) {
                  // 0-9
                  filteredPart += char;
                }
              }

              final issueSubassetName = '$prefix$filteredPart';

              _subassetController.value = TextEditingValue(
                text: issueSubassetName,
                selection:
                    TextSelection.collapsed(offset: issueSubassetName.length),
              );
            }
          },
          onFieldSubmitted: (_) => _handleInitialSubmit(formKey, originalAsset),
        ),
      ],
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey, Asset originalAsset) {
    String name = originalAsset.assetLongname ?? originalAsset.asset!;
    int quantity = 0;
    String? description = originalAsset.description;
    String? destinationAddress;

    if (formKey.currentState!.validate()) {
      switch (widget.actionType) {
        case IssuanceActionType.reset:
          isReset = true;
          quantity = _updateQuantity(
              isDivisible ?? originalAsset.divisible!, _quantityController);
          break;
        case IssuanceActionType.lockDescription:
          description = 'lock_description';
          break;
        case IssuanceActionType.lockQuantity:
          isLocked = true;
          break;
        case IssuanceActionType.changeDescription:
          description = _newDescriptionController.text;
          break;
        case IssuanceActionType.issueMore:
          quantity = _updateQuantity(
              isDivisible ?? originalAsset.divisible!, _quantityController);
          break;
        case IssuanceActionType.issueSubasset:
          name = _subassetController.text;
          quantity = _updateQuantity(
              isDivisible ?? originalAsset.divisible!, _quantityController);
          description = _newDescriptionController.text;
          break;
        case IssuanceActionType.transferOwnership:
          destinationAddress = _destinationAddressController.text;
          break;
        default:
          print("Invalid case");
      }

      context.read<UpdateIssuanceBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: UpdateIssuanceEventParams(
              name: name,
              quantity: quantity,
              description: description ?? '',
              divisible: isDivisible ?? originalAsset.divisible!,
              lock: isLocked ?? originalAsset.locked!,
              reset: isReset ?? false,
              issuanceActionType: widget.actionType,
              destination: destinationAddress,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(
      dynamic composeTransaction, Asset originalAsset) {
    final params =
        (composeTransaction as ComposeIssuanceResponseVerbose).params;
    return switch (widget.actionType) {
      IssuanceActionType.reset => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: HorizonUI.HorizonTextFormField(
                  label: "Original Supply",
                  controller: TextEditingController(
                      text: originalAsset.supplyNormalized),
                  enabled: false,
                  textColor: Colors.grey,
                ),
              ),
              Expanded(
                child: HorizonUI.HorizonTextFormField(
                  label: "Updated Supply",
                  controller:
                      TextEditingController(text: params.quantityNormalized),
                  enabled: false,
                  textColor: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.lockQuantity => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          _buildConfirmQuantityField(originalAsset.supplyNormalized!),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.lockDescription => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          _buildConfirmQuantityField(originalAsset.supplyNormalized!),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(originalAsset.description ?? '',
              originalAsset, widget.actionType),
          const SizedBox(height: 16),
          HorizonUI.HorizonTextFormField(
            label: "Lock Description",
            controller: TextEditingController(text: 'true'),
            enabled: false,
            textColor: Colors.green,
          ),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.changeDescription => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          _buildConfirmQuantityField(originalAsset.supplyNormalized!),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.issueMore => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          Column(
            children: [
              HorizonUI.HorizonTextFormField(
                label: "Additional Supply",
                enabled: false,
                controller:
                    TextEditingController(text: params.quantityNormalized),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: HorizonUI.HorizonTextFormField(
                      label: "Original Supply",
                      controller: TextEditingController(
                          text: originalAsset.supplyNormalized),
                      enabled: false,
                      textColor: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: HorizonUI.HorizonTextFormField(
                      label: "Updated Total Supply",
                      controller: TextEditingController(
                          text: (Decimal.parse(params.quantityNormalized) +
                                  Decimal.parse(
                                      originalAsset.supplyNormalized!))
                              .toString()),
                      enabled: false,
                      textColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.issueSubasset => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          _buildConfirmQuantityField(params.quantityNormalized),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
      IssuanceActionType.transferOwnership => [
          _sourceField(params.source),
          const SizedBox(height: 16),
          Column(
            children: [
              HorizonUI.HorizonTextFormField(
                label: "Destination Address",
                controller:
                    TextEditingController(text: params.transferDestination),
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _nameField(composeTransaction.name, widget.actionType),
          const SizedBox(height: 16),
          _buildConfirmQuantityField(originalAsset.supplyNormalized!),
          const SizedBox(height: 16),
          _buildConfirmDescriptionField(
              params.description ?? '', originalAsset, widget.actionType),
          const SizedBox(height: 16),
          ..._buildBoolFields(params, originalAsset),
        ],
    };
  }

  void _onConfirmationBack() {
    context.read<UpdateIssuanceBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<UpdateIssuanceBloc>().add(
            FinalizeTransactionEvent<ComposeIssuanceResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<UpdateIssuanceBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  static HorizonUI.HorizonTextFormField _sourceField(String source) =>
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: source),
        enabled: false,
      );

  static HorizonUI.HorizonTextFormField _nameField(
          String name, IssuanceActionType actionType) =>
      HorizonUI.HorizonTextFormField(
        label: actionType == IssuanceActionType.issueSubasset
            ? "Subasset Issuance"
            : "Token name",
        controller: TextEditingController(text: name),
        enabled: false,
      );

  static HorizonUI.HorizonTextFormField _buildConfirmQuantityField(
          String quantityNormalized) =>
      HorizonUI.HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: quantityNormalized),
        enabled: false,
      );

  static HorizonUI.HorizonTextFormField _buildConfirmDescriptionField(
          String description,
          Asset originalAsset,
          IssuanceActionType actionType) =>
      HorizonUI.HorizonTextFormField(
        label: "Description",
        controller: TextEditingController(text: description),
        enabled: false,
        textColor: actionType != IssuanceActionType.lockDescription &&
                description != originalAsset.description
            ? Colors.green
            : null,
      );

  List<Widget> _buildBoolFields(
          ComposeIssuanceResponseVerboseParams params, Asset originalAsset) =>
      [
        HorizonUI.HorizonTextFormField(
          label: "Divisible",
          controller: TextEditingController(
              text: params.divisible == true ? 'true' : 'false'),
          enabled: false,
          textColor: params.divisible != originalAsset.divisible &&
                  widget.actionType != IssuanceActionType.issueSubasset
              ? Colors.green
              : null,
        ),
        const SizedBox(height: 16.0),
        HorizonUI.HorizonTextFormField(
          label: "Lock",
          controller: TextEditingController(
              text: params.lock == true ? 'true' : 'false'),
          enabled: false,
          textColor: params.lock != originalAsset.locked &&
                  widget.actionType != IssuanceActionType.issueSubasset
              ? Colors.green
              : null,
        ),
        const SizedBox(height: 16.0),
        HorizonUI.HorizonTextFormField(
          label: "Reset",
          controller: TextEditingController(
              text: params.reset == true ? 'true' : 'false'),
          enabled: false,
          textColor: params.reset == true ? Colors.green : null,
        ),
      ];

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<UpdateIssuanceBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  int _updateQuantity(
      bool isDivisible, TextEditingController quantityController) {
    Decimal input = Decimal.parse(quantityController.text);

    int quantity;

    if (isDivisible) {
      quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
    } else {
      quantity = (input).toBigInt().toInt();
    }
    return quantity;
  }
}
