import 'dart:math' as math;

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
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_bloc.dart';
import 'package:horizon/presentation/screens/update_issuance/bloc/update_issuance_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class UpdateIssuancePageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final IssuanceActionType actionType;
  final String assetName;

  const UpdateIssuancePageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.actionType,
    required this.assetName,
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
        )..add(FetchFormData(
            assetName: assetName, currentAddress: state.currentAddress)),
        child: UpdateIssuancePage(
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          address: state.currentAddress,
          actionType: actionType,
          assetName: assetName,
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
  const UpdateIssuancePage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.actionType,
    required this.assetName,
  });

  @override
  UpdateIssuancePageState createState() => UpdateIssuancePageState();
}

class UpdateIssuancePageState extends State<UpdateIssuancePage> {
  late TextEditingController _subassetController;
  late TextEditingController _quantityController;
  late TextEditingController _newDescriptionController;

  late Asset originalAsset;
  @override
  void initState() {
    super.initState();
    _subassetController = TextEditingController(text: '${widget.assetName}.');
    _quantityController = TextEditingController();
    _newDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _subassetController.dispose();
    _quantityController.dispose();
    _newDescriptionController.dispose();
    super.dispose();
  }

  late String name;
  late String? longName;
  late int quantity;
  late String? description;
  late bool isDivisible;
  late bool isLocked;
  late bool isReset;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdateIssuanceBloc, UpdateIssuanceState>(
      listener: (context, state) {
        state.assetState.maybeWhen(
          success: (asset) {
            originalAsset = asset;
            name = asset.asset!;
            longName = asset.assetLongname;
            quantity = asset.supply!;
            description = asset.description;
            isDivisible = asset.divisible ?? false;
            isLocked = asset.locked ?? false;
            isReset = false;
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return ComposeBasePage<UpdateIssuanceBloc, UpdateIssuanceState>(
          address: widget.address,
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<UpdateIssuanceBloc>()
              .add(ChangeFeeOption(value: fee)),
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
      },
    );
  }

  List<Widget> _buildInitialFormFields(
      UpdateIssuanceState state, bool loading, GlobalKey<FormState> formKey) {
    return state.assetState.maybeWhen(
      loading: () {
        return switch (widget.actionType) {
          IssuanceActionType.reset => [
              const HorizonUI.HorizonTextFormField(
                  label: 'Reset Asset:',
                  enabled: false,
                  suffix: CircularProgressIndicator())
            ],
          IssuanceActionType.lockDescription => [
              const HorizonUI.HorizonTextFormField(
                  label: 'Lock Description for Asset',
                  enabled: false,
                  suffix: CircularProgressIndicator())
            ],
          IssuanceActionType.lockQuantity => [
              const HorizonUI.HorizonTextFormField(
                  label: 'Lock Quantity for Asset',
                  enabled: false,
                  suffix: CircularProgressIndicator())
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
              const HorizonUI.HorizonTextFormField(
                  label: 'Issue Subasset of Asset', enabled: false),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: TextEditingController(),
                label: 'Subasset Name',
                hint: 'Enter the new subasset name',
                enabled: false,
              ),
            ],
        };
      },
      success: (asset) {
        print('asset Locked??: ${asset.locked}');

        return switch (widget.actionType) {
          IssuanceActionType.reset => [
              HorizonUI.HorizonTextFormField(
                  label: 'Reset Asset',
                  controller: TextEditingController(text: asset.asset),
                  enabled: false),
            ],
          IssuanceActionType.lockDescription => [
              HorizonUI.HorizonTextFormField(
                  label: 'Lock Description for Asset',
                  controller: TextEditingController(text: asset.asset),
                  enabled: false)
            ],
          IssuanceActionType.lockQuantity => [
              HorizonUI.HorizonTextFormField(
                  label: 'Lock Quantity for Asset',
                  controller: TextEditingController(text: asset.asset),
                  enabled: false),
            ],
          IssuanceActionType.changeDescription => [
              HorizonUI.HorizonTextFormField(
                  label: 'Update Description for Asset',
                  enabled: false,
                  controller: TextEditingController(text: asset.asset)),
              const SizedBox(height: 16),
              asset.description != ''
                  ? HorizonUI.HorizonTextFormField(
                      label: 'Current Description',
                      enabled: false,
                      controller:
                          TextEditingController(text: asset.description),
                    )
                  : const Align(
                      alignment: Alignment.centerLeft,
                      child:
                          SelectableText('Asset currently has no description')),
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
                onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
              )
            ],
          IssuanceActionType.issueMore => [
              HorizonUI.HorizonTextFormField(
                  label: 'Issue More of Asset',
                  enabled: false,
                  controller: TextEditingController(text: asset.asset)),
              HorizonUI.HorizonTextFormField(
                  label: 'Current Supply',
                  enabled: false,
                  controller:
                      TextEditingController(text: asset.supplyNormalized)),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: _quantityController,
                label: 'Quantity to Add to Current Supply',
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                inputFormatters: [
                  asset.divisible == true
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
            ],
          IssuanceActionType.issueSubasset => [
              HorizonUI.HorizonTextFormField(
                  label: 'Issue Subasset of Asset',
                  enabled: false,
                  controller: TextEditingController(text: asset.asset)),
              const SizedBox(height: 16),
              _buildSubassetNameField(asset, formKey),
            ],
        };
      },
      orElse: () => [],
    );
  }

  Widget _buildSubassetNameField(Asset asset, GlobalKey<FormState> formKey) {
    return Stack(
      children: [
        HorizonUI.HorizonTextFormField(
          controller: _subassetController,
          textCapitalization: TextCapitalization.characters,
          label: 'Subasset Name',
          validator: (value) {
            if (value == null || value.isEmpty || value == '${asset.asset}.') {
              return 'Please enter a subasset name';
            }
            return null;
          },
          onChanged: (value) {
            final prefix = '${asset.asset}.';
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
          onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
        ),
      ],
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      switch (widget.actionType) {
        case IssuanceActionType.reset:
          isReset = true;
          break;
        // case IssuanceActionType.lockDescription:
        //   isLocked = true;
        //   break;
        case IssuanceActionType.lockQuantity:
          isLocked = true;
          break;
        case IssuanceActionType.changeDescription:
          description = _newDescriptionController.text;
          break;
        case IssuanceActionType.issueMore:
          // TODO: wrap this in function and write some tests
          final int originalQuantity = quantity;
          Decimal input = Decimal.parse(_quantityController.text);

          int newQuantity;
          if (isDivisible) {
            newQuantity =
                (input * Decimal.fromInt(100000000)).toBigInt().toInt();
          } else {
            newQuantity = (input).toBigInt().toInt();
          }
          quantity = newQuantity + originalQuantity;
          break;
        case IssuanceActionType.issueSubasset:
          longName = _subassetController.text;

          break;

        default:
          print("Invalid case");
      }

      context.read<UpdateIssuanceBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: UpdateIssuanceEventParams(
              name: longName ?? name,
              // longName: longName,
              quantity: quantity,
              description: description ?? '',
              divisible: isDivisible,
              lock: isLocked,
              reset: isReset,
              issuanceActionType: widget.actionType,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeIssuanceVerbose).params;
    print('original asset: $originalAsset');
    print('supply normalized: ${originalAsset.supplyNormalized}');
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: widget.actionType == IssuanceActionType.issueSubasset
            ? "Subasset Issuance"
            : "Token name",
        controller: TextEditingController(text: composeTransaction.name),
        enabled: false,
        textColor: widget.actionType == IssuanceActionType.issueSubasset
            ? Colors.green
            : null,
      ),
      //       const SizedBox(height: 16.0),
      // HorizonUI.HorizonTextFormField(
      //   label: "Asset Long Name",
      //   controller: TextEditingController(text: composeTransaction.longName),
      //   enabled: false,
      // ),
      widget.actionType == IssuanceActionType.issueMore
          ? Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  children: [
                    HorizonUI.HorizonTextFormField(
                      label: "Original Supply",
                      controller: TextEditingController(
                          text: originalAsset.supplyNormalized),
                      enabled: false,
                    ),
                    HorizonUI.HorizonTextFormField(
                      label: "Additional Supply",
                      controller: TextEditingController(
                          text: (Decimal.parse(params.quantityNormalized) -
                                  Decimal.parse(
                                      originalAsset.supplyNormalized!))
                              .toString()),
                      enabled: false,
                    ),
                  ],
                ),
              ],
            )
          : const SizedBox.shrink(),
      const SizedBox(height: 16),
      HorizonUI.HorizonTextFormField(
        label: widget.actionType == IssuanceActionType.issueMore ||
                originalAsset.supplyNormalized != params.quantityNormalized
            ? "Updated Quantity"
            : "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
        textColor: widget.actionType == IssuanceActionType.issueMore ||
                originalAsset.supplyNormalized != params.quantityNormalized
            ? Colors.green
            : null,
      ),
      params.description != ''
          ? Column(
              children: [
                const SizedBox(height: 16),
                HorizonUI.HorizonTextFormField(
                  label: "Description",
                  controller: TextEditingController(text: params.description),
                  enabled: false,
                  textColor:
                      widget.actionType == IssuanceActionType.changeDescription
                          ? Colors.green
                          : null,
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
        textColor: widget.actionType == IssuanceActionType.lockQuantity
            ? Colors.green
            : null,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Reset",
        controller: TextEditingController(
            text: params.reset == true ? 'true' : 'false'),
        enabled: false,
        textColor:
            widget.actionType == IssuanceActionType.reset ? Colors.green : null,
      ),
    ];
  }

  void _onConfirmationBack() {
    context.read<UpdateIssuanceBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<UpdateIssuanceBloc>().add(
            FinalizeTransactionEvent<ComposeIssuanceVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<UpdateIssuanceBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context.read<UpdateIssuanceBloc>().add(FetchFormData(
        currentAddress: widget.address, assetName: widget.assetName));
  }
}

class PrefixTextEditingController extends TextEditingController {
  final String prefix;

  PrefixTextEditingController({required this.prefix}) : super(text: prefix);

  @override
  set text(String newText) {
    if (newText.startsWith(prefix)) {
      super.text = newText;
    } else {
      super.text =
          prefix + newText.replaceAll(RegExp('^.*?(?=[A-Z0-9]|\$)'), '');
    }
  }

  @override
  TextSelection get selection {
    final newSelection = super.selection;
    return newSelection.copyWith(
      baseOffset: math.max(prefix.length, newSelection.baseOffset),
      extentOffset: math.max(prefix.length, newSelection.extentOffset),
    );
  }
}
