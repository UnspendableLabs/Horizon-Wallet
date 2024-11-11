import 'package:horizon/presentation/forms/open_order_form/open_order_form_view.dart';
import 'package:get_it/get_it.dart';

import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import 'package:horizon/presentation/common/compose_base/bloc/compose_base_state.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';
import 'package:horizon/presentation/screens/compose_order/bloc/compose_order_bloc.dart';
import 'package:horizon/presentation/screens/compose_order/bloc/compose_order_state.dart';
import 'package:horizon/presentation/screens/compose_order/bloc/compose_order_event.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/presentation/common/usecase/compose_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';

import 'package:horizon/presentation/common/compose_base/bloc/compose_base_event.dart';
import 'package:horizon/presentation/common/compose_base/view/compose_base_page.dart';

import 'package:horizon/common/fn.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/forms/open_order_form/open_order_form_bloc.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/compose_repository.dart';

class ComposeOrderPageWrapper extends StatelessWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String currentAddress;
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;


  final String? initialGiveAsset;
  final int? initialGiveQuantity;
  final String? initialGetAsset;
  final int? initialGetQuantity;

  const ComposeOrderPageWrapper({
    required this.dashboardActivityFeedBloc,
    required this.currentAddress,
    required this.getFeeEstimatesUseCase,
    required this.assetRepository,
    this.initialGiveAsset,
    this.initialGiveQuantity,
    this.initialGetAsset,
    this.initialGetQuantity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
      success: (state) => BlocProvider(
        key: Key(currentAddress),
        create: (context) => ComposeOrderBloc(
          getFeeEstimatesUseCase: GetIt.I.get<GetFeeEstimatesUseCase>(),
          logger: GetIt.I.get<Logger>(),
          writelocalTransactionUseCase:
              GetIt.I.get<WriteLocalTransactionUseCase>(),
          signAndBroadcastTransactionUseCase:
              GetIt.I.get<SignAndBroadcastTransactionUseCase>(),
          composeTransactionUseCase: GetIt.I.get<ComposeTransactionUseCase>(),
          analyticsService: GetIt.I.get<AnalyticsService>(),
          composeRepository: GetIt.I.get<ComposeRepository>(),
        )..add(FetchFormData(currentAddress: currentAddress)),
        child: ComposeOrderPage(
          getFeeEstimatesUseCase: getFeeEstimatesUseCase,
          address: currentAddress,
          dashboardActivityFeedBloc: dashboardActivityFeedBloc,
          balanceRepository: GetIt.I.get<BalanceRepository>(),
          assetRepository: GetIt.I.get<AssetRepository>(),
          initialGiveAsset: initialGiveAsset,
          initialGiveQuantity: initialGiveQuantity,
          initialGetAsset: initialGetAsset,
          initialGetQuantity: initialGetQuantity
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class ComposeOrderPage extends StatefulWidget {
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;
  final String address;

  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final GetFeeEstimatesUseCase getFeeEstimatesUseCase;

  final String? initialGiveAsset;
  final int? initialGiveQuantity;
  final String? initialGetAsset;
  final int? initialGetQuantity;
  const ComposeOrderPage({
    super.key,
    required this.getFeeEstimatesUseCase,
    required this.dashboardActivityFeedBloc,
    required this.address,
    required this.balanceRepository,
    required this.assetRepository,
    this.initialGiveAsset,
    this.initialGiveQuantity,
    this.initialGetAsset,
    this.initialGetQuantity,
  });

  @override
  ComposeOrderPageState createState() => ComposeOrderPageState();
}

class ComposeOrderPageState extends State<ComposeOrderPage> {
  void _handleInitialSubmit(GlobalKey<FormState> formKey) {
    print(formKey.currentState);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ComposeOrderBloc, ComposeOrderState>(
        listener: (context, state) {},
        builder: (context, state) {
          return switch (state.submitState) {
            SubmitInitial(error: var error) => OpenOrderForm(
                getFeeEstimatesUseCase: widget.getFeeEstimatesUseCase,
                assetRepository: widget.assetRepository,
                balanceRepository: widget.balanceRepository,
                currentAddress: widget.address,
                initialGiveAsset: widget.initialGiveAsset,
                initialGiveQuantity: widget.initialGiveQuantity,
                initialGetAsset: widget.initialGetAsset,
                initialGetQuantity: widget.initialGetQuantity,
              ),
            _ => Text("some other form state")
          };
        });
  }
}

// class ComposeOrderWizard extends StatelessWidget {
//   final BalanceRepository balanceRepository;
//   final AssetRepository assetRepository;
//   final String currentAddress;
//
//   final String? initialGiveAsset;
//   final int? initialGiveQuantity;
//   final String? initialGetAsset;
//   final int? initialGetQuantity;
//
//   const ComposeOrderWizard(
//       {super.key,
//       required this.assetRepository,
//       required this.balanceRepository,
//       required this.currentAddress,
//       this.initialGiveAsset,
//       this.initialGiveQuantity,
//       this.initialGetAsset,
//       this.initialGetQuantity});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) {
//         return OpenOrderFormBloc(
//             assetRepository: assetRepository,
//             balanceRepository: balanceRepository,
//             currentAddress: currentAddress)
//           ..add(InitializeForm(params: _getInitializeParams()));
//       },
//       child: OpenOrderForm_(),
//     );
//   }
//
//   _getInitializeParams() {
//     if (initialGiveAsset != null &&
//         initialGiveQuantity != null &&
//         initialGetAsset != null &&
//         initialGetQuantity != null) {
//       return InitializeParams(
//         initialGiveAsset: initialGiveAsset!,
//         initialGiveQuantity: initialGiveQuantity!,
//         initialGetQuantity: initialGetQuantity!,
//         initialGetAsset: initialGetAsset!,
//       );
//     }
//   }
// }
