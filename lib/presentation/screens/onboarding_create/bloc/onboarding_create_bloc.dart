import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:logger/logger.dart';

class OnboardingCreateBloc extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final Logger logger = Logger();
  final mnmonicService = GetIt.I<MnemonicService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final encryptionService = GetIt.I<EncryptionService>();
  final walletService = GetIt.I<WalletService>();
  final addressService = GetIt.I<AddressService>();

  OnboardingCreateBloc() : super(OnboardingCreateState()) {
    on<PasswordSubmit>((event, emit) {
      logger.d('Processing PasswordSubmit event');
      if (event.password != event.passwordConfirmation) {
        logger.w('Passwords do not match');
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else if (event.password.length != 32) {
        logger.w('Password must be 32 characters');
        emit(state.copyWith(passwordError: "Password must be 32 characters.  Don't worry, we'll change this :)"));
      } else {
        try {
          String mnemonic = mnmonicService.generateMnemonic();
          emit(state.copyWith(
              password: event.password,
              passwordError: null,
              mnemonicState: GenerateMnemonicStateSuccess(mnemonic: mnemonic)));
          logger.d('Mnemonic generated successfully');
        } catch (e) {
          logger.e({'message': 'Failed to generate mnemonic', 'error': e});
          emit(state.copyWith(
              password: event.password,
              passwordError: null,
              mnemonicState: GenerateMnemonicStateError(message: e.toString())));
        }
      }
    });

    on<CreateWallet>((event, emit) async {
      logger.d('Processing CreateWallet event');
      if (state.mnemonicState is GenerateMnemonicStateSuccess) {
        emit(state.copyWith(createState: CreateStateLoading()));
        try {
          Wallet wallet = await walletService.deriveRoot(state.mnemonicState.mnemonic, state.password!);

          final decryptedPrivKey = await encryptionService.decrypt(wallet.encryptedPrivKey, state.password!);

          Account account = Account(
            name: 'Account 0',
            walletUuid: wallet.uuid,
            purpose: '84\'',
            coinType: _getCoinType(),
            accountIndex: '0',
            uuid: uuid.v4(),
          );
          Address address = await addressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account.uuid,
              purpose: account.purpose,
              coin: account.coinType,
              account: account.accountIndex,
              change: '0',
              index: 0);

          await walletRepository.insert(wallet);
          await accountRepository.insert(account);
          await addressRepository.insert(address);

          emit(state.copyWith(createState: CreateStateSuccess()));
        } catch (e) {
          logger.e({'message': 'Failed to create wallet', 'error': e});
          emit(state.copyWith(createState: CreateStateError(message: e.toString())));
        }
      } else {
        logger.w('Attempted to create wallet without successful mnemonic generation');
        emit(state.copyWith(createState: CreateStateError(message: "Mnemonic generation not successful")));
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

  _getCoinType() {
    bool isTestnet = dotenv.get('TEST') == 'true';
    return isTestnet ? '1\'' : '0\'';
  }
}
