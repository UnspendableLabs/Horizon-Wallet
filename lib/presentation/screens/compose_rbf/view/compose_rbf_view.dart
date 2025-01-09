import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/forms/replace_by_fee/replace_by_fee_form_view.dart';
import 'package:horizon/presentation/forms/replace_by_fee/replace_by_fee_form_bloc.dart' as rbfForm;
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_bloc.dart';

class ComposeRBFPageWrapper extends StatelessWidget {
  final String txHash;

  const ComposeRBFPageWrapper({required this.txHash, super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        success: (state) => BlocProvider(
            create: (context) => ComposeRBFBloc(),
            child: BlocProvider(
                create: (context) => rbfForm.ReplaceByFeeFormBloc(
                      txHash: txHash,
                      transactionService: GetIt.I.get<TransactionService>(),
                      bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                      getFeeEstimatesUseCase:
                          GetIt.I.get<GetFeeEstimatesUseCase>(),
                    )..add(rbfForm.InitializeRequested(txHash: txHash)),
                child: HorizonUI.HorizonDialog(
                    title: "Accelerate this transaction",
                    body: ReplaceByFeeForm(
                    onSubmitSuccess: () {
                      context
                      .read<ComposeRBFBloc>()
                      .add(const  FormSubmitted());

                    },


                    )))));
    // )
  }
}
