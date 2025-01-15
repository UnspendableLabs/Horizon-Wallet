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
  final String psbtHex;
  final void Function() onContinue;

  const ComposeRBFReview(
      {required this.psbtHex, required this.onContinue, super.key});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        HorizonUI.HorizonTextFormField(
            label: "tx hex",
            enabled: false,
            controller: TextEditingController(text: psbtHex)),
        const HorizonUI.HorizonDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HorizonUI.HorizonCancelButton(
              onPressed: () => {},
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
                        c.Form() =>
                          ReplaceByFeeForm(onSubmitSuccess: (makeRBFResponse) {
                            context
                                .read<c.ComposeRBFBloc>()
                                .add(c.FormSubmitted(makeRBFResponse: makeRBFResponse));
                          }),
                        c.Review() => ComposeRBFReview(
                            psbtHex: state.makeRBFResponse!.txHex,
                            onContinue: () {
                              context
                                  .read<c.ComposeRBFBloc>()
                                  .add(const c.ReviewSubmitted());
                            }),
                        c.Password() => BlocProvider(
                            create: (context) => ComposeRbfPasswordBloc(
                              bitcoindService: GetIt.I.get<BitcoindService>(),
                                bitcoinRepository: GetIt.I.get<BitcoinRepository>(),
                                importedAddressService: GetIt.I<ImportedAddressService>(),
                                addressService: GetIt.I<AddressService>(),
                                accountRepository: GetIt.I<AccountRepository>(),
                                addressRepository: GetIt.I<UnifiedAddressRepository>(),
                                encryptionService: GetIt.I<EncryptionService>(),
                                transactionService: GetIt.I<TransactionService>(),
                                signAndBroadcastTransactionUseCase: GetIt.I
                                    .get<SignAndBroadcastTransactionUseCase>(),
                                address: address,
                                walletRepository: GetIt.I<WalletRepository>(),
                                makeRBFResponse: state.makeRBFResponse!),
                            child: const ComposeRBFPasswordForm()),
                      };
                    })))));
    // )
  }
}
