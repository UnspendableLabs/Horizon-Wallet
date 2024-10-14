import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
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
  final bool _submitted = false;

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
        // return state.dispensersState.maybeWhen(
        //   loading: () => ComposeBasePage<CloseDispenserBloc, CloseDispenserState>(
        //     address: widget.address,
        //     dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
        //     onFeeChange: (fee) {},
        //     buildInitialFormFields: (state, loading, formKey) => _buildInitialFormFields(state, loading, formKey),
        //     onInitialCancel: () => _handleInitialCancel(),
        //     onInitialSubmit: (formKey) {},
        //     buildConfirmationFormFields: (composeTransaction, formKey) => [],
        //     onConfirmationBack: () {},
        //     onConfirmationContinue: (composeTransaction, fee, formKey) {},
        //     onFinalizeSubmit: (password, formKey) {},
        //     onFinalizeCancel: () {},
        //   ),
        //   success: (dispensers) => ComposeBasePage<CloseDispenserBloc, CloseDispenserState>(
        //     address: widget.address,
        //     dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
        //     onFeeChange: (fee) => context.read<CloseDispenserBloc>().add(ChangeFeeOption(value: fee)),
        //     buildInitialFormFields: (state, loading, formKey) => _buildInitialFormFields(state, loading, formKey),
        //     onInitialCancel: () => _handleInitialCancel(),
        //     onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
        //     buildConfirmationFormFields: (composeTransaction, formKey) => _buildConfirmationDetails(composeTransaction),
        //     onConfirmationBack: () => _onConfirmationBack(),
        //     onConfirmationContinue: (composeTransaction, fee, formKey) {
        //       _onConfirmationContinue(composeTransaction, fee, formKey);
        //     },
        //     onFinalizeSubmit: (password, formKey) {
        //       _onFinalizeSubmit(password, formKey);
        //     },
        //     onFinalizeCancel: () => _onFinalizeCancel(),
        //   ),
        //   error: (error) => SelectableText(error),
        //   orElse: () => const SizedBox.shrink(),
        // );
      },
    );
  }

  List<Widget> _buildInitialFormFields(
      CloseDispenserState state, bool loading, GlobalKey<FormState> formKey) {
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
              child: Text(
                '${dispenser.openAddress} - ${dispenser.assetName} - '
                'Quantity: ${dispenser.giveQuantity} - '
                'Price: ${dispenser.mainchainrate}',
              ),
            );
          }).toList(),
          onChanged: (Dispenser? newDispenser) {
            setState(() {
              selectedDispenser = newDispenser;
            });
            // if (newDispenser != null) {
            //   context.read<CloseDispenserBloc>().add(SelectDispenser(dispenser: newDispenser));
            // }
          },
        ),
      ],
      loading: () => [
        const Center(child: CircularProgressIndicator()),
      ],
      error: (error) => [SelectableText(error)],
      orElse: () => [const Text('No dispensers available')],
    );
  }

  void _handleInitialCancel() {
    // TODO: implement _onInitialCancel
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    // TODO: implement _onInitialSubmit
  }

  void _onFinalizeCancel() {}

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    // TODO: implement _onFinalizeSubmit
  }

  void _onConfirmationBack() {
    // TODO: implement _onConfirmationBack
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    // TODO: implement _onConfirmationContinue
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    return [];
  }
}
