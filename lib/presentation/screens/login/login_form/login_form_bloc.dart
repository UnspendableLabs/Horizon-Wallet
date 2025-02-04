import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/services/imported_address_service.dart';

abstract class FormEvent extends Equatable {
  const FormEvent();
  @override
  List<Object?> get props => [];
}

class PasswordChanged extends FormEvent {
  const PasswordChanged(this.password);
  final String password;
  @override
  List<Object?> get props => [password];
}

class FormSubmitted extends FormEvent {}

class FormState with FormzMixin {
  FormState({
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
  });

  final Password password;
  final FormzSubmissionStatus status;

  FormState copyWith({
    Password? password,
    FormzSubmissionStatus? status,
  }) {
    return FormState(
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [password];
}

enum PasswordValidationError { empty }

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([super.value = '']) : super.pure();

  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }
    return null;
  }
}

class LoginFormBloc extends Bloc<FormEvent, FormState> {
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final InMemoryKeyRepository inMemoryKeyRepository;
  final ImportedAddressRepository importedAddressRepository;
  final ImportedAddressService importedAddressService;

  LoginFormBloc(
      {required this.importedAddressService,
      required this.importedAddressRepository,
      required this.walletRepository,
      required this.encryptionService,
      required this.inMemoryKeyRepository})
      : super(FormState()) {
    on<PasswordChanged>(_onPasswordChanged);
    on<FormSubmitted>(_onFormSubmitted);
  }

  _onPasswordChanged(PasswordChanged event, Emitter<FormState> emit) {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.initial,
        password: Password.dirty(event.password),
      ),
    );
  }

  _onFormSubmitted(FormSubmitted event, Emitter<FormState> emit) async {
    emit(
      state.copyWith(
        status: FormzSubmissionStatus.inProgress,
      ),
    );

    try {
      final password = state.password.value;

      final wallet = await walletRepository.getCurrentWallet();

      String decryptionKey = await encryptionService.getDecryptionKey(
          wallet!.encryptedPrivKey, password);

      // test decrypt to validate password
      await encryptionService.decryptWithKey(
          wallet.encryptedPrivKey, decryptionKey);

      await inMemoryKeyRepository.set(key: decryptionKey);

      final importedAddresses = await importedAddressRepository.getAll();
      Map<String, String> importedAddressMap = {};

      for (var importedAddress in importedAddresses) {
        String decryptionKey = await encryptionService.getDecryptionKey(
            importedAddress.encryptedWif, password);
        importedAddressMap[importedAddress.address] = decryptionKey;
      }

      await inMemoryKeyRepository.setMap(map: importedAddressMap);

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
        ),
      );
    } catch (e) {
      emit(state.copyWith(
        status: FormzSubmissionStatus.failure,
      ));
    } //TODO: set encryption key
  }
}
