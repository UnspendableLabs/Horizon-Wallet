import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/transaction_local_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;

import 'package:horizon/presentation/screens/compose_rbf/view/form/compose_rbf_form_view.dart';
import 'package:horizon/presentation/screens/compose_rbf/view/form/compose_rbf_form_bloc.dart'
    as rbfForm;

import 'package:horizon/presentation/screens/compose_rbf/view/review/compose_rbf_review_view.dart';

import 'package:horizon/presentation/screens/compose_rbf/view/password/compose_rbf_password_bloc.dart';
import 'package:horizon/presentation/screens/compose_rbf/view/password/compose_rbf_password_view.dart';

import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_bloc.dart'
    as c;

import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/presentation/common/usecase/write_local_transaction_usecase.dart';
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_bloc.dart";
import "package:horizon/presentation/screens/dashboard/bloc/dashboard_activity_feed/dashboard_activity_feed_event.dart";

class ComposeRBFPageWrapper extends StatelessWidget {
  final String txHash;
  final String address;
  final DashboardActivityFeedBloc dashboardActivityFeedBloc;

  const ComposeRBFPageWrapper(
      {required this.dashboardActivityFeedBloc,
      required this.txHash,
      required this.address,
      super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        success: (state) => BlocProvider(
            create: (context) => c.ComposeRBFBloc(),
            child: BlocProvider(
                create: (context) => rbfForm.ReplaceByFeeFormBloc(
                      source: address,
                      txHash: txHash,
                      transactionService: GetIt.I.get<TransactionService>(),
                      bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                      getFeeEstimatesUseCase:
                          GetIt.I.get<GetFeeEstimatesUseCase>(),
                    )..add(rbfForm.InitializeRequested(txHash: txHash)),
                child: HorizonUI.HorizonDialog(
                    title: "Accelerate this transaction",
                    body: BlocBuilder<c.ComposeRBFBloc, c.ComposeRBFState>(
                        builder: (context, state) {
                      return switch (state.step) {
                        c.Form() => ReplaceByFeeForm(onCancel: () {
                            Navigator.of(context).pop();
                          }, onSubmitSuccess: (makeRBFResponse, rbfData) {
                            context.read<c.ComposeRBFBloc>().add(
                                c.FormSubmitted(
                                    makeRBFResponse: makeRBFResponse,
                                    rbfData: rbfData));
                          }),
                        c.Review() => ComposeRBFReview(
                            makeRBFResponse: state.makeRBFResponse!,
                            rbfData: state.rbfData!,
                            onBack: () {
                              context
                                  .read<c.ComposeRBFBloc>()
                                  .add(const c.ReviewBackButtonPressed());
                            },
                            onContinue: () {
                              context
                                  .read<c.ComposeRBFBloc>()
                                  .add(const c.ReviewSubmitted());
                            }),
                        c.Password() => BlocProvider(
                            create: (context) => ComposeRbfPasswordBloc(
                              
                                  transactionLocalRepository:
                                      GetIt.I.get<TransactionLocalRepository>(),
                                  analyticsService: GetIt.I<AnalyticsService>(),
                                  bitcoindService:
                                      GetIt.I.get<BitcoindService>(),
                                  bitcoinRepository:
                                      GetIt.I.get<BitcoinRepository>(),
                                  importedAddressService:
                                      GetIt.I<ImportedAddressService>(),
                                  addressService: GetIt.I<AddressService>(),
                                  accountRepository:
                                      GetIt.I<AccountRepository>(),
                                  addressRepository:
                                      GetIt.I<UnifiedAddressRepository>(),
                                  encryptionService:
                                      GetIt.I<EncryptionService>(),
                                  transactionService:
                                      GetIt.I<TransactionService>(),
                                  signAndBroadcastTransactionUseCase: GetIt.I
                                      .get<
                                          SignAndBroadcastTransactionUseCase>(),
                                  txHashToReplace: txHash,
                                  address: address,
                                  walletRepository: GetIt.I<WalletRepository>(),
                                  makeRBFResponse: state.makeRBFResponse!,
                                  writelocalTransactionUseCase:
                                      GetIt.I<WriteLocalTransactionUseCase>(),
                                ),
                            child: ComposeRBFPasswordForm(onSuccess: () {
                              dashboardActivityFeedBloc.add(const Load());
                              Navigator.of(context).pop();
                            }, onBack: () {
                              context
                                  .read<c.ComposeRBFBloc>()
                                  .add(const c.PasswordBackButtonPressed());
                            })),
                      };
                    })))));
    // )
  }
}
