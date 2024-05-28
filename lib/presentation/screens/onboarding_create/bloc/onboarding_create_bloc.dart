import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';

class OnboardingCreateBloc extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final mnmonicService = GetIt.I<MnemonicService>();
  final addressService = GetIt.I<AddressService>();
  final walletService = GetIt.I<WalletService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();

  OnboardingCreateBloc() : super(OnboardingCreateState()) {
    on<PasswordSubmit>((event, emit) {
      if (event.password != event.passwordConfirmation) {
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else if (event.password.length != 32) {
        emit(state.copyWith(passwordError: "Password must be 32 characters.  Don't worry, we'll change this :)"));
      } else {
        try {
          String mnemonic = mnmonicService.generateMnemonic();
          emit(state.copyWith(
              password: event.password,
              passwordError: null,
              mnemonicState: GenerateMnemonicStateSuccess(mnemonic: mnemonic)));
        } catch (e) {
          emit(state.copyWith(
              password: event.password,
              passwordError: null,
              mnemonicState: GenerateMnemonicStateError(message: e.toString())));
        }
      }
    });

    on<CreateWallet>((event, emit) async {
      if (state.mnemonicState is GenerateMnemonicStateSuccess) {
        emit(state.copyWith(createState: CreateStateLoading()));
        try {
          // there is some duplicate work here ( but it's all fast )

          Wallet wallet = await walletService.deriveRoot(state.mnemonicState.mnemonic, state.password!);

          Account account = Account(uuid: uuid.v4());
          wallet.uuid = uuid.v4();
          wallet.accountUuid = account.uuid;

          Address address = await addressService.deriveAddressSegwit(state.mnemonicState.mnemonic, 0);
          address.walletUuid = wallet.uuid;

          await accountRepository.insert(account);
          await walletRepository.insert(wallet);
          // insert not implemented at the moment
          await addressRepository.insertMany([address]);

          emit(state.copyWith(createState: CreateStateSuccess()));
        } catch (e) {
          emit(state.copyWith(createState: CreateStateError(message: e.toString())));
        }
      }
    });

    // This is actually unused for now
    on<GenerateMnemonic>((event, emit) {
      emit(state.copyWith(mnemonicState: GenerateMnemonicStateLoading()));

      try {
        String mnemonic = mnmonicService.generateMnemonic();

        emit(state.copyWith(mnemonicState: GenerateMnemonicStateSuccess(mnemonic: mnemonic)));
      } catch (e) {
        emit(state.copyWith(mnemonicState: GenerateMnemonicStateError(message: e.toString())));
      }
    });
  }
}
