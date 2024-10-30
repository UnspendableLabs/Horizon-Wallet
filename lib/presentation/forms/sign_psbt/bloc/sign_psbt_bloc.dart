import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:horizon/common/constants.dart';

import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';

import "./sign_psbt_state.dart";
import "./sign_psbt_event.dart";

class SignPsbtBloc extends Bloc<SignPsbtEvent, SignPsbtState> {
  final String unsignedPsbt;
  final TransactionService transactionService;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;

  SignPsbtBloc(
      {required this.unsignedPsbt,
      required this.transactionService,
      required this.walletRepository,
      required this.encryptionService,
      required this.addressService})
      : super(SignPsbtState()) {
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignPsbtSubmitted>(_handleSignPsbtSubmitted);
  }

  _handlePasswordChanged(PasswordChanged event, Emitter<SignPsbtState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
      submissionStatus: Formz.validate([password])
          ? FormzSubmissionStatus.initial
          : FormzSubmissionStatus.failure,
    ));
  }

  _handleSignPsbtSubmitted(
      SignPsbtSubmitted event, Emitter<SignPsbtState> emit) async {
    try {
      Wallet? wallet = await walletRepository.getCurrentWallet();

      if (wallet == null) {
        throw Exception("invariant: wallet not found");
      }

      String privateKey = await encryptionService.decrypt(
          wallet.encryptedPrivKey, state.password.value);


      final addressPrivKey = await addressService.deriveAddressPrivateKey(
        rootPrivKey: privateKey,
        chainCodeHex: wallet.chainCodeHex,
        purpose: '84\'',
        coin: '0\'',
        account: '0\'',
        change: '0',
        index: 0,
        importFormat: ImportFormat.horizon,
      );

      String signedHex =
          transactionService.signPsbt(unsignedPsbt, addressPrivKey);

      emit(state.copyWith(
        signedPsbt: signedHex,
        submissionStatus: FormzSubmissionStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
          submissionStatus: FormzSubmissionStatus.failure,
          error: e.toString()));
    }
  }
}
