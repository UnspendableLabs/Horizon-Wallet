import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/format.dart';
import 'package:horizon/domain/entities/address.dart';
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
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

class CloseDispenserPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const CloseDispenserPageWrapper({
    required this.dashboardActivityFeedBloc,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(state.currentAccountUuid),
        create: (context) => CloseDispenserBloc(
          fetchCloseDispenserFormDataUseCase:
              GetIt.I.get<FetchCloseDispenserFormDataUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          // fetchDispenserFormDataUseCase: GetIt.I.get<FetchDispenserFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(FetchFormData(currentAddress: state.currentAddress)),
        child: CloseDispenserPage(
          address: state.currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class CloseDispenserPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final Address address;

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

  // String? asset;
  // Balance? balance_;
  Dispenser? selectedDispenser;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    // openAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CloseDispenserBloc, CloseDispenserState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        return ComposeBasePage<CloseDispenserBloc, CloseDispenserState>(
          address: widget.address,
          dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
          onFeeChange: (fee) => context
              .read<CloseDispenserBloc>()
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
      CloseDispenserState state, bool loading, GlobalKey<FormState> formKey) {
    try {
      return state.dispensersState.maybeWhen(
        success: (dispensers) => [
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
                    '${dispenser.openAddress} - ${dispenser.assetName} - '
                    'Quantity: ${dispenser.giveQuantity} - '
                    'Price: ${dispenser.mainchainrate}',
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
              return '${dispenser.openAddress} - ${dispenser.assetName} - '
                  'Quantity: ${dispenser.giveQuantity} - '
                  'Price: ${dispenser.mainchainrate}';
            },
            selectedItemBuilder: (BuildContext context) {
              return dispensers.map<Widget>((Dispenser dispenser) {
                return Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${dispenser.openAddress} - ${dispenser.assetName} - '
                    'Quantity: ${dispenser.giveQuantity} - '
                    'Price: ${dispenser.mainchainrate}',
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
      context.read<CloseDispenserBloc>().add(ComposeTransactionEvent(
            sourceAddress: widget.address.address,
            params: CloseDispenserParams(
              asset: selectedDispenser!.assetName,
              giveQuantity: selectedDispenser!.giveQuantity,
              escrowQuantity: selectedDispenser!.escrowQuantity,
              mainchainrate: selectedDispenser!.mainchainrate,
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
        controller: TextEditingController(text: params.giveQuantityNormalized),
        enabled: false,
      ),
      const SizedBox(height: 16.0),
      HorizonUI.HorizonTextFormField(
        label: "Escrow Quantity",
        controller:
            TextEditingController(text: params.escrowQuantityNormalized),
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
    context
        .read<CloseDispenserBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<CloseDispenserBloc>().add(
            FinalizeTransactionEvent<ComposeDispenserResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<CloseDispenserBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<CloseDispenserBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }
}
