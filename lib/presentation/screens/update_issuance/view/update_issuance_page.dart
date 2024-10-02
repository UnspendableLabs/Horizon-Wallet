import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<UpdateIssuanceBloc, UpdateIssuanceState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<UpdateIssuanceBloc>().add(ChangeFeeOption(value: fee)),
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
        return switch (widget.actionType) {
          IssuanceActionType.reset => [
              HorizonUI.HorizonTextFormField(
                  label: 'Reset Asset',
                  controller: TextEditingController(text: asset.asset),
                  enabled: false)
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
                  enabled: false)
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
                  : const SelectableText('Asset currently has no description'),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: TextEditingController(),
                label: 'New Description',
                hint: 'Enter the new description for the asset',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
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
                      TextEditingController(text: asset.supply.toString())),
              const SizedBox(height: 16),
              HorizonUI.HorizonTextFormField(
                controller: TextEditingController(),
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
              HorizonUI.HorizonTextFormField(
                controller: TextEditingController(),
                label: 'Subasset Name',
                hint: 'Enter the new subasset name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subasset name';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleInitialSubmit(formKey),
              ),
            ],
        };
      },
      orElse: () => [],
    );
  }

  void _handleInitialCancel() {}

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {}

  List<Widget> _buildConfirmationDetails(composeTransaction) {
    return const [];
  }

  void _onConfirmationBack() {}

  void _onConfirmationContinue(
      composeTransaction, int fee, GlobalKey<FormState> formKey) {}

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {}

  void _onFinalizeCancel() {}
}
