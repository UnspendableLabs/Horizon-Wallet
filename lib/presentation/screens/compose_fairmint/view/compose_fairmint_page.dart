import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_bloc.dart';
import 'package:horizon/presentation/screens/compose_fairmint/bloc/compose_fairmint_state.dart';
import 'package:horizon/presentation/screens/compose_fairmint/usecase/fetch_form_data.dart';
import 'package:horizon/presentation/screens/compose_issuance/bloc/compose_issuance_bloc.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

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
          fetchComposeFairmintFormDataUseCase:
              GetIt.I.get<FetchComposeFairmintFormDataUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          // addressRepository: GetIt.I.get<AddressRepository>(),
          // balanceRepository: GetIt.I.get<BalanceRepository>(),
          // composeRepository: GetIt.I.get<ComposeRepository>(),
          // utxoRepository: GetIt.I.get<UtxoRepository>(),
          // accountRepository: GetIt.I.get<AccountRepository>(),
          // walletRepository: GetIt.I.get<WalletRepository>(),
          // encryptionService: GetIt.I.get<EncryptionService>(),
          // addressService: GetIt.I.get<AddressService>(),
          // transactionService: GetIt.I.get<TransactionService>(),
          // bitcoindService: GetIt.I.get<BitcoindService>(),
          // transactionRepository: GetIt.I.get<TransactionRepository>(),
          // transactionLocalRepository: GetIt.I.get<TransactionLocalRepository>(),
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

  // final balanceRepository = GetIt.I.get<BalanceRepository>();

  // String? asset;

  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    fromAddressController.text = widget.address.address;
  }

  @override
  Widget build(BuildContext context) {
    return ComposeBasePage<ComposeFairmintBloc, ComposeFairmintState>(
      address: widget.address,
      dashboardActivityFeedBloc: widget.dashboardActivityFeedBloc,
      onFeeChange: (fee) =>
          context.read<ComposeFairmintBloc>().add(ChangeFeeOption(value: fee)),
      buildInitialFormFields: (state, loading, formKey) =>
          _buildInitialFormFields(state, loading, formKey),
      onInitialCancel: () => _handleInitialCancel(),
      onInitialSubmit: (formKey) => _handleInitialSubmit(formKey),
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
    );
  }

  void _handleInitialCancel() {
    Navigator.of(context).pop();
  }

  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    setState(() {
      _submitted = true;
    });
    // if (formKey.currentState!.validate()) {
    //   // TODO: wrap this in function and write some tests
    //   Decimal input = Decimal.parse(quantityController.text);

    //   int quantity;

    //   if (isDivisible) {
    //     quantity = (input * Decimal.fromInt(100000000)).toBigInt().toInt();
    //   } else {
    //     quantity = (input).toBigInt().toInt();
    //   }

    // context.read<ComposeIssuanceBloc>().add(ComposeTransactionEvent(
    //       sourceAddress: widget.address.address,
    //       params: ComposeIssuanceEventParams(
    //         name: nameController.text,
    //         quantity: quantity,
    //         description: descriptionController.text,
    //         divisible: isDivisible,
    //         lock: isLocked,
    //         reset: false,
    //       ),
    //     ));
    // }
  }

  List<Widget> _buildInitialFormFields(
      ComposeFairmintState state, bool loading, GlobalKey<FormState> formKey) {
    return state.fairmintersState.maybeWhen(
      success: (fairminters) => [
        ...fairminters.map((fairminter) => Text(fairminter.asset)),
      ],
      orElse: () => [],
    );
  }

  List<Widget> _buildConfirmationDetails(dynamic composeTransaction) {
    // final params = (composeTransaction as ComposeIssuanceResponseVerbose).params;
    // return [
    //   HorizonUI.HorizonTextFormField(
    //     label: "Source Address",
    //     controller: TextEditingController(text: params.source),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Token name",
    //     controller: TextEditingController(text: composeTransaction.name),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Quantity",
    //     controller: TextEditingController(text: params.quantityNormalized),
    //     enabled: false,
    //   ),
    //   params.description != ''
    //       ? Column(
    //           children: [
    //             const SizedBox(height: 16.0),
    //             HorizonUI.HorizonTextFormField(
    //               label: "Description",
    //               controller: TextEditingController(text: params.description),
    //               enabled: false,
    //             ),
    //           ],
    //         )
    //       : const SizedBox.shrink(),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Divisible",
    //     controller: TextEditingController(text: params.divisible == true ? 'true' : 'false'),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Lock",
    //     controller: TextEditingController(text: params.lock == true ? 'true' : 'false'),
    //     enabled: false,
    //   ),
    //   const SizedBox(height: 16.0),
    //   HorizonUI.HorizonTextFormField(
    //     label: "Reset",
    //     controller: TextEditingController(text: params.reset == true ? 'true' : 'false'),
    //     enabled: false,
    //   ),
    // ];
    return [];
  }

  void _onConfirmationBack() {
    context
        .read<ComposeIssuanceBloc>()
        .add(FetchFormData(currentAddress: widget.address));
  }

  void _onConfirmationContinue(
      dynamic composeTransaction, int fee, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            FinalizeTransactionEvent<ComposeIssuanceResponseVerbose>(
              composeTransaction: composeTransaction,
              fee: fee,
            ),
          );
    }
  }

  void _onFinalizeSubmit(String password, GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      context.read<ComposeIssuanceBloc>().add(
            SignAndBroadcastTransactionEvent(
              password: password,
            ),
          );
    }
  }

  void _onFinalizeCancel() {
    context
        .read<ComposeIssuanceBloc>()
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
