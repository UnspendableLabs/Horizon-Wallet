import 'package:horizon/presentation/forms/open_order_form/open_order_form_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/asset_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/presentation/forms/open_order_form/open_order_form_bloc.dart';
import 'package:flow_builder/flow_builder.dart';



enum ComposeTransactionStep {
  form,
  confirm,
  signAndBroadcast,
}





// class OrderTransactionParams {
//   final String initialGiveAsset;
//   final int initialGiveQuantity;
//   final String initialGetAsset;
//   final int initialGetQuantity;
//
//   OrderTransactionParams({
//     required this.initialGiveAsset,
//     required this.initialGiveQuantity,
//     required this.initialGetAsset,
//     required this.initialGetQuantity,
//   });
// }
//
// class OpenOrderFlow {
//   final OrderTransactionParams? params;
// }

class OpenOrderWizard extends StatelessWidget {
  final BalanceRepository balanceRepository;
  final AssetRepository assetRepository;
  final String currentAddress;

  final String? initialGiveAsset;
  final int? initialGiveQuantity;
  final String? initialGetAsset;
  final int? initialGetQuantity;

  const OpenOrderWizard(
      {super.key,
      required this.assetRepository,
      required this.balanceRepository,
      required this.currentAddress,
      this.initialGiveAsset,
      this.initialGiveQuantity,
      this.initialGetAsset,
      this.initialGetQuantity});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return OpenOrderFormBloc(
            assetRepository: assetRepository,
            balanceRepository: balanceRepository,
            currentAddress: currentAddress)
          ..add(InitializeForm(params: _getInitializeParams()));
      },
      child: OpenOrderForm_(),
    );
  }

  _getInitializeParams() {
    if (initialGiveAsset != null &&
        initialGiveQuantity != null &&
        initialGetAsset != null &&
        initialGetQuantity != null) {
      return InitializeParams(
        initialGiveAsset: initialGiveAsset!,
        initialGiveQuantity: initialGiveQuantity!,
        initialGetQuantity: initialGetQuantity!,
        initialGetAsset: initialGetAsset!,
      );
    }
  }
}
