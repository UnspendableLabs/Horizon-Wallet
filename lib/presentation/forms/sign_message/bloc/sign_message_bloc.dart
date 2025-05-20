import "package:fpdart/fpdart.dart";
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/services/transaction_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';

import "./sign_message_state.dart";
import "./sign_message_event.dart";

class SignMessageBloc extends Bloc<SignMessageEvent, SignMessageState> {
  final bool passwordRequired;
  final String message;
  final String address;
  final TransactionService transactionService;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final ImportedAddressService importedAddressService;
  final BalanceRepository balanceRepository;
  final InMemoryKeyRepository inMemoryKeyRepository;

  SignMessageBloc({
    required this.passwordRequired,
    required this.message,
    required this.address,
    required this.transactionService,
    required this.encryptionService,
    required this.addressService,
    required this.importedAddressService,
    required this.balanceRepository,
    required this.inMemoryKeyRepository,
  }) : super(SignMessageState(
          message: message,
        )) {
    on<PasswordChanged>(_handlePasswordChanged);
    on<SignMessageSubmitted>(_handleSignMessageSubmitted);
  }

  _handlePasswordChanged(
      PasswordChanged event, Emitter<SignMessageState> emit) {
    final password = PasswordInput.dirty(event.password);

    emit(state.copyWith(
      password: password,
      error: null,
      submissionStatus: FormzSubmissionStatus.initial,
    ));
  }

  _handleSignMessageSubmitted(
      SignMessageSubmitted event, Emitter<SignMessageState> emit) async {
        throw UnimplementedError("");
    // try {
    //   Wallet? wallet = await walletRepository.getCurrentWallet();
    //
    //   String privateKey = '';
    //
    //   if (passwordRequired) {
    //     try {
    //       privateKey = await encryptionService.decrypt(
    //           wallet.encryptedPrivKey, state.password.value);
    //     } catch (e) {
    //       emit(state.copyWith(
    //         submissionStatus: FormzSubmissionStatus.failure,
    //         error: "Incorrect password.",
    //       ));
    //       return;
    //     }
    //   } else {
    //     try {
    //       privateKey = await encryptionService.decryptWithKey(
    //           wallet.encryptedPrivKey, (await inMemoryKeyRepository.get())!);
    //     } catch (e) {
    //       emit(state.copyWith(
    //         submissionStatus: FormzSubmissionStatus.failure,
    //         error: "Invariant: could not decrypt wallet",
    //       ));
    //       return;
    //     }
    //   }
    //
    //   dynamic signature = await addressRepository
    //       .get(address)
    //       .flatMap((UnifiedAddress unifiedAddress) => getUAddressPrivateKey(
    //             passwordRequired
    //                 ? Password(state.password.value)
    //                 : InMemoryKey(),
    //             privateKey,
    //             wallet.chainCodeHex,
    //             unifiedAddress,
    //           ))
    //       .map((addressPrivateKey) {
    //         return transactionService.signMessage(message, addressPrivateKey);
    //       })
    //       .match((error) => throw error, (signature) => signature)
    //       .run();
    //
    //   emit(state.copyWith(
    //     signature: signature,
    //     submissionStatus: FormzSubmissionStatus.success,
    //   ));
    // } catch (e) {
    //   emit(state.copyWith(
    //       submissionStatus: FormzSubmissionStatus.failure,
    //       error: e.toString()));
    // }
  }

}
