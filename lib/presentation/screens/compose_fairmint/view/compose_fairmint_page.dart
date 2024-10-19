import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/fairminter.dart';
import 'package:horizon/domain/repositories/block_repository.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/colors.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_state.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

class ComposeFairmintPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeFairmintPageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => ComposeFairmintBloc(
          logger: GetIt.I.get<Logger>(),
          fetchComposeFairmintFormDataUseCase:
              GetIt.I.get<FetchComposeFairmintFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          blockRepository: GetIt.I.get<BlockRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: ComposeFairmintPage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeFairmintPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;
  const ComposeFairmintPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  ComposeFairmintPageState createState() => ComposeFairmintPageState();
}

class ComposeFairmintPageState extends State<ComposeFairmintPage> {
  TextEditingController quantityController = TextEditingController();
  TextEditingController fromAddressController = TextEditingController();
  TextEditingController nameController = UpperCaseTextEditingController();

  Fairminter? fairminter;

  bool _submitted = false;

  String? error;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeFairmintBloc, ComposeFairmintState>(
      listener: (context, state) {},
      builder: (context, state) {
        return state.fairmintersState.maybeWhen(
          loading: () =>
              ComposeBasePage<ComposeFairmintBloc, ComposeFairmintState>(
                  address: widget.address,
                  dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
                  onFeeChange: (fee) => context
                      .read<ComposeFairmintBloc>()
                      .add(ChangeFeeOption(value: fee)),
                  buildInitialFormFields: (state, loading, formKey) => [
                        HorizonUI.HorizonTextFormField(
                          label: "Address that will be minting the asset",
                          controller: fromAddressController,
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        HorizonUI.HorizonTextFormField(
                          label: "Name of the asset to mint",
                          controller: nameController,
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        HorizonUI.HorizonTextFormField(
                          controller: TextEditingController(text: 'OR'),
                          enabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        const HorizonUI.HorizonTextFormField(
                          label: "Select a fairminter",
                          enabled: false,
                        ),
                      ],
                  onInitialCancel: () => _handleInitialCancel(),
                  onInitialSubmit: (formKey) {},
                  buildConfirmationFormFields:
                      (state, composeTransaction, formKey) => [],
                  onConfirmationBack: () {},
                  onConfirmationContinue: (composeTransaction, fee, formKey) {},
                  onFinalizeSubmit: (password, formKey) {},
                  onFinalizeCancel: () {}),
          success: (fairminters) =>
              ComposeBasePage<ComposeFairmintBloc, ComposeFairmintState>(
            address: widget.address,
            dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
            onFeeChange: (fee) => context
                .read<ComposeFairmintBloc>()
                .add(ChangeFeeOption(value: fee)),
            buildInitialFormFields: (state, loading, formKey) =>
                _buildInitialFormFields(state, loading, formKey, fairminters),
            onInitialCancel: () => _handleInitialCancel(),
            onInitialSubmit: (formKey) =>
                _handleInitialSubmit(formKey, fairminters),
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
          error: (error) => SelectableText(error),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(
      GlobalKey<FormState> formKey, List<Fairminter> fairminters) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      if (fairminter == null && nameController.text.isEmpty) {
        setState(() {
          error = 'Please select a fairminter or enter a fairminter name';
        });
        return;
      } else if (fairminter == null && nameController.text.isNotEmpty) {
        if (!fairminters
            .any((fairminter) => fairminter.asset == nameController.text)) {
          setState(() {
            error = 'Fairminter with name ${nameController.text} not found';
          });
          return;
        }
      } else if (fairminter != null && nameController.text.isNotEmpty) {
        setState(() {
          error =
              'Please specify either a fairminter name or a select from the dropdown, not both';
        });
        return;
      }

      context.read<ComposeFairmintBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: ComposeFairmintEventParams(
              asset: fairminter?.asset ?? nameController.text,
            ),
          ));
    }
  }

  List<Widget> _buildInitialFormFields(ComposeFairmintState state, bool loading,
      GlobalKey<FormState> formKey, List<Fairminter> fairminters) {
    if (fairminters.isEmpty) {
      return [
        const SelectableText('No fairminters found'),
      ];
    }
    return [
      HorizonUI.HorizonTextFormField(
        label: "Address that will be minting the asset",
        controller: fromAddressController,
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Name of the asset to mint",
        controller: nameController,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        controller: TextEditingController(text: 'OR'),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonDropdownMenu(
        label: "Select a fairminter",
        items: fairminters
            .map((fairminter) => DropdownMenuItem(
                value: fairminter, child: Text(fairminter.asset!)))
            .toList(),
        onChanged: (Fairminter? value) => setState(() {
          fairminter = value;
        }),
      ),
      if (error != null)
        SelectableText(
          error!,
          style: const TextStyle(color: redErrorText),
        ),
    ];
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params = (composeTransaction as ComposeFairmintResponse).params;
    return [
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Asset",
        controller: TextEditingController(text: params.asset),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Quantity",
        controller: TextEditingController(text: params.quantityNormalized),
        enabled: false,
      ),
    ];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeFairmintBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    context
        .read<ComposeFairmintBloc>()
        .add(FinalizeTransactionEvent<ComposeFairmintResponse>(
          composeTransaction: composeTransaction,
          fee: fee,
        ));
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeFairmintBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeFairmintBloc>()
        .add(FetchFormData(currentAddress: widget.address));
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
