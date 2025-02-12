import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/dispenser.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_bloc.dart';
import 'package:horizon/presentation/screens/close_dispenser/bloc/close_dispenser_state.dart';
import 'package:horizon/presentation/screens/close_dispenser/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/session/bloc/session_cubit.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/settings_repository.dart';
import 'package:horizon/core/logging/logger.dart';

class CloseDispenserPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;

  const CloseDispenserPageWrapper({
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
        create: (context) => CloseDispenserBloc(
          logger: GetIt.I.get<Logger>(),
          passwordRequired:
              GetIt.I<SettingsRepository>().requirePasswordForCryptoOperations,
          inMemoryKeyRepository: GetIt.I.get<InMemoryKeyRepository>(),
          fetchCloseDispenserFormDataUseCase:
              GetIt.I.get<FetchCloseDispenserFormDataUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(AsyncFormDependenciesRequested(currentAddress: currentAddress)),
        child: CloseDispenserPage(
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class CloseDispenserPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  const CloseDispenserPage({
    super.key,
    required this.dashboardActivityFeedBloc,
    required this.address,
  });

  @override
  CloseDispenserPageState createState() => CloseDispenserPageState();
}

class CloseDispenserPageState extends State<CloseDispenserPage> {
  TextEditingController dispenserController = TextEditingController();

  Dispenser? selectedDispenser;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CloseDispenserBloc, CloseDispenserState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ComposeBasePage<CloseDispenserBloc, CloseDispenserState>(
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<CloseDispenserBloc>()
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
      CloseDispenserState state, bool loading, GlobalKey<FormState> formKey) {
    try {
      return state.dispensersState.maybeWhen(
        success: (dispensers) => [
          HorizonUI.HorizonTextFormField(
            label: 'Source Address',
            controller: TextEditingController(text: widget.address),
            enabled: false,
          ),
          HorizonUI.HorizonDropdownMenu<Dispenser>(
            controller: dispenserController,
            id: 'close_dispenser_dropdown',
            label: 'Select Dispenser to Close',
            selectedValue: selectedDispenser,
            items: dispensers.map((dispenser) {
              return DropdownMenuItem<Dispenser>(
                value: dispenser,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${dispenser.asset} - '
                    'Quantity: ${dispenser.giveQuantityNormalized} - '
                    'Price: ${dispenser.satoshirateNormalized}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
            onChanged: (Dispenser? newDispenser) {
              setState(() {
                selectedDispenser = newDispenser;
              });
            },
            displayStringForOption: (Dispenser? dispenser) {
              if (dispenser == null) return '';
              return '${dispenser.asset} - '
                  'Quantity: ${dispenser.giveQuantityNormalized} - '
                  'Price: ${dispenser.satoshirateNormalized}';
            },
            selectedItemBuilder: (BuildContext context) {
              return dispensers.map<Widget>((Dispenser dispenser) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${dispenser.asset} - '
                    'Quantity: ${dispenser.giveQuantityNormalized} - '
                    'Price: ${dispenser.satoshirateNormalized}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList();
            },
            isDense: false,
            isExpanded: true,
            validator: (value) {
              if (value == null) {
                return 'Please select a dispenser';
              }
              return null;
            },
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
          ),
        ],
        loading: () => [
          const Center(child: CircularProgressIndicator()),
        ],
        error: (error) => [SelectableText(error)],
        orElse: () => [const Text('No dispensers available')],
      );
    } catch (e) {
      return [SelectableText(e.toString())];
    }
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    if (formKey.currentState!.validate()) {
      context.read<CloseDispenserBloc>().add(FormSubmitted(
            sourceAddress: widget.address,
            params: CloseDispenserParams(
              asset: selectedDispenser!.asset,
              giveQuantity: 0,
              escrowQuantity: 0,
              mainchainrate: selectedDispenser!.satoshirate,
              status: 10,
            ),
          ));
    }
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    final params =
        (composeTransaction as ComposeDispenserResponseVerbose).params;
    return [
      const SelectableText('CLOSE DISPENSER',
          style: TextStyle(fontWeight: FontWeight.bold)),
      HorizonUI.HorizonTextFormField(
        label: "Source Address",
        controller: TextEditingController(text: params.source),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Give Quantity",
        controller: TextEditingController(
            text: selectedDispenser!.giveQuantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Escrow Quantity",
        controller: TextEditingController(
            text: selectedDispenser!.escrowQuantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: 'Price Per Unit (BTC)',
        controller: TextEditingController(
            text: satoshisToBtc(params.mainchainrate).toStringAsFixed(8)),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
    ];
  }

  void _onConfirmationBack() {
    setState(() {
      selectedDispenser = null;
      dispenserController.clear();
    });
    context
        .read<CloseDispenserBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<CloseDispenserBloc>().add(
            ReviewSubmitted<ComposeDispenserResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<CloseDispenserBloc>().add(
            SignAndBroadcastFormSubmitted(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    setState(() {
      selectedDispenser = null;
      dispenserController.clear();
    });
    context
        .read<CloseDispenserBloc>()
        .add(AsyncFormDependenciesRequested(currentAddress: widget.address));
  }
}
