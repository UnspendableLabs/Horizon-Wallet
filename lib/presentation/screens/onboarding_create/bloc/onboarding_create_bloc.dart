import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:logger/logger.dart';

class OnboardingCreateBloc
    extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final Config config = GetIt.I<Config>();

  final Logger logger = Logger();
  final mnmonicService = GetIt.I<MnemonicService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final encryptionService = GetIt.I<EncryptionService>();
  final walletService = GetIt.I<WalletService>();
  final addressService = GetIt.I<AddressService>();

  OnboardingCreateBloc() : super(const OnboardingCreateState()) {
    on<PasswordChanged>((event, emit) {
      if (event.password.length < 8) {
        emit(state.copyWith(
            passwordError: "Password must be at least 8 characters."));
      } else {
        emit(state.copyWith(password: event.password, passwordError: null));
      }
    });

    on<PasswordConfirmationChanged>((event, emit) {
      if (state.password != event.passwordConfirmation) {
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else {
        emit(state.copyWith(passwordError: null));
      }
    });

    on<PasswordError>((event, emit) {
      emit(state.copyWith(passwordError: event.error));
    });

    on<CreateWallet>((event, emit) async {
      logger.d('Processing CreateWallet event');
      emit(state.copyWith(createState: CreateStateLoading()));
      try {
        Wallet wallet = await walletService.deriveRoot(
            state.mnemonicState.mnemonic, state.password!);

        String decryptedPrivKey = await encryptionService.decrypt(
            wallet.encryptedPrivKey, state.password!);

        Account account = Account(
            name: 'Account 0',
            walletUuid: wallet.uuid,
            purpose: '84\'',
            coinType: '${_getCoinType()}\'',
            accountIndex: '0\'',
            uuid: uuid.v4(),
            importFormat: ImportFormat.horizon);

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
        emit(state.copyWith(
            createState: CreateStateError(message: e.toString())));
      }
    });

    on<GenerateMnemonic>((event, emit) {
      // print('state.mnemonicState.mnemonic: ${state.mnemonicState.mnemonic}');
      print('state.mnemonicState: ${state.mnemonicState}');
      // if (state.mnemonicState.mnemonic != '' || state.mnemonicState.mnemonic != null) {
      //   return;
      // }
      emit(state.copyWith(mnemonicState: GenerateMnemonicStateLoading()));

      try {
        String mnemonic = mnmonicService.generateMnemonic();

        emit(state.copyWith(
            mnemonicState: GenerateMnemonicStateGenerated(mnemonic: mnemonic)));
      } catch (e) {
        emit(state.copyWith(
            mnemonicState: GenerateMnemonicStateError(message: e.toString())));
      }
    });

    on<UnconfirmMnemonic>((event, emit) {
      emit(state.copyWith(
          mnemonicState: GenerateMnemonicStateUnconfirmed(
              mnemonic: state.mnemonicState.mnemonic),
          createState: CreateStateMnemonicUnconfirmed));
    });

    on<ConfirmMnemonicChanged>((event, emit) {
      if (state.mnemonicState.mnemonic != event.mnemonic) {
        emit(state.copyWith(mnemonicError: 'Mnemonic does not match'));
      } else {
        emit(state.copyWith(mnemonicError: null));
      }
    });

    on<ConfirmMnemonic>((event, emit) {
      if (state.mnemonicState.mnemonic != event.mnemonic) {
        emit(state.copyWith(mnemonicError: 'Mnemonic does not match'));
      } else {
        emit(state.copyWith(
            createState: CreateStateMnemonicConfirmed, mnemonicError: null));
      }
    });

    on<GoBackToMnemonic>((event, emit) {
      emit(state.copyWith(createState: CreateStateNotAsked));
    });
  }

  String _getCoinType() =>
      switch (config.network) { Network.mainnet => "0", _ => "1" };
}
