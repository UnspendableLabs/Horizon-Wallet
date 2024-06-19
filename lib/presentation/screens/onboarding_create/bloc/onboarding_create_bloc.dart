import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/account_service_return.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/coin.dart';
import 'package:horizon/domain/entities/purpose.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/coin_repository.dart';
import 'package:horizon/domain/repositories/purpose_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/account_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_event.dart';
import 'package:horizon/presentation/screens/onboarding_create/bloc/onboarding_create_state.dart';
import 'package:logger/logger.dart';

class OnboardingCreateBloc extends Bloc<OnboardingCreateEvent, OnboardingCreateState> {
  final Logger logger = Logger();
  final mnmonicService = GetIt.I<MnemonicService>();
  final addressService = GetIt.I<AddressService>();
  final accountService = GetIt.I<AccountService>();
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final purposeRepository = GetIt.I<PurposeRepository>();
  final coinRepository = GetIt.I<CoinRepository>();

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
          Wallet wallet = Wallet(uuid: uuid.v4(), name: 'Wallet 1');

          Purpose purpose = Purpose(uuid: uuid.v4(), bip: '84', walletUuid: wallet.uuid);

          // TODO: coin type 1 is testnet
          Coin coin = Coin(uuid: uuid.v4(), type: 0, walletUuid: wallet.uuid, purposeUuid: purpose.uuid);

          int accountIndex = 0;

          Account account = Account(
              uuid: uuid.v4(),
              name: 'm/${purpose.bip}\'/${coin.type}\'/$accountIndex\'',
              walletUuid: wallet.uuid,
              purposeUuid: purpose.uuid,
              coinUuid: coin.uuid,
              accountIndex: accountIndex,
              xPub: '');

          AccountServiceReturn accountServiceReturn = await accountService.deriveAccountAndAddress(
              state.mnemonicState.mnemonic, purpose.bip, coin.type, accountIndex);

          account.xPub = accountServiceReturn.xPub;
          Address address = accountServiceReturn.address;

          debugger(when: true);
          await walletRepository.insert(wallet);
          await purposeRepository.insert(purpose);
          await coinRepository.insert(coin);
          await accountRepository.insert(account);
          await addressRepository.insert(address);

          debugger(when: true);

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
}
