import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/shell/bloc/shell_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/unified_address_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/bitcoind_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/presentation/screens/horizon/ui.dart' as HorizonUI;
import 'package:horizon/presentation/forms/replace_by_fee/replace_by_fee_form_view.dart';
import 'package:horizon/presentation/forms/replace_by_fee/replace_by_fee_form_bloc.dart'
    as rbfForm;
import 'package:horizon/presentation/common/usecase/get_fee_estimates.dart';

import 'package:horizon/presentation/screens/compose_rbf/bloc/compose_rbf_bloc.dart'
    as c;

import 'package:horizon/presentation/screens/compose_rbf/view/password/compose_rbf_password_bloc.dart';
import 'package:horizon/presentation/screens/compose_rbf/view/password/compose_rbf_password_view.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/common/usecase/sign_and_broadcast_transaction_usecase.dart';

class ComposeRBFReview extends StatelessWidget {
  final rbfForm.RBFData rbfData;
  final MakeRBFResponse makeRBFResponse;
  final void Function() onContinue;
  final void Function() onBack;

  const ComposeRBFReview(
      {required this.rbfData,
      required this.makeRBFResponse,
      required this.onBack,
      required this.onContinue,
      super.key});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Replacing:',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Row(
          children: [
            Text(
              "${rbfData.tx.txid}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),

        const SizedBox(height: 16.0),
        Text(
          'Fee:',
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Row(
          children: [
            Text(
              "${rbfData.tx.fee} sats/vbyte",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.lineThrough,
                  ),
            ),
            const SizedBox(width: 8.0),
            Text(
              "${makeRBFResponse.fee} sats/vbyte",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.green),
            ),
          ],
        ),
        // SizedBox(height: 16.0),
        // Text(
        //   'Fee Rate:',
        //   style: Theme.of(context).textTheme.labelSmall,
        // ),
        // Row(
        //   children: [
        //     Text(
        //       (rbfData.tx.fee / rbfData.adjustedSize).toStringAsFixed(2),
        //       style: Theme.of(context).textTheme.bodyMedium,
        //     ),
        //     const SizedBox(width: 8.0),
        //     Text(
        //       (makeRBFResponse.fee / makeRBFResponse.virtualSize)
        //           .toStringAsFixed(2),
        //       style: Theme.of(context).textTheme.bodyMedium,
        //     ),
        //     const Text("sats/vB"),
        //   ],
        // ),
        const HorizonUI.HorizonDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HorizonUI.HorizonCancelButton(
              onPressed: () => onBack(),
              buttonText: 'BACK',
            ),
            HorizonUI.HorizonContinueButton(
              onPressed: () => onContinue(),
              buttonText: 'CONTINUE',
            ),
          ],
        ),
      ]),
    );
  }
}

class ComposeRBFPageWrapper extends StatelessWidget {
  final String txHash;
  final String address;

  const ComposeRBFPageWrapper(
      {required this.txHash, required this.address, super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watch<ShellStateCubit>();
    return shell.state.maybeWhen(
        orElse: () => const SizedBox.shrink(),
        success: (state) => BlocProvider(
            create: (context) => c.ComposeRBFBloc(),
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
                                bitcoindService: GetIt.I.get<BitcoindService>(),
                                bitcoinRepository:
                                    GetIt.I.get<BitcoinRepository>(),
                                importedAddressService:
                                    GetIt.I<ImportedAddressService>(),
                                addressService: GetIt.I<AddressService>(),
                                accountRepository: GetIt.I<AccountRepository>(),
                                addressRepository:
                                    GetIt.I<UnifiedAddressRepository>(),
                                encryptionService: GetIt.I<EncryptionService>(),
                                transactionService:
                                    GetIt.I<TransactionService>(),
                                signAndBroadcastTransactionUseCase: GetIt.I
                                    .get<SignAndBroadcastTransactionUseCase>(),
                                address: address,
                                walletRepository: GetIt.I<WalletRepository>(),
                                makeRBFResponse: state.makeRBFResponse!),
                            child: ComposeRBFPasswordForm(onSuccess: () {
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
