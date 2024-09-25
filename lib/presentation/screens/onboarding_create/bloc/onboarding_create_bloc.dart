import 'package:flutter_bloc/flutter_bloc.dart';
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
  final Logger logger = Logger();

  final Config config;
  final MnemonicService mnmonicService;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final WalletService walletService;
  final AddressService addressService;

  OnboardingCreateBloc({
    required this.config,
    required this.mnmonicService,
    required this.walletRepository,
    required this.walletService,
    required this.accountRepository,
    required this.addressRepository,
    required this.encryptionService,
    required this.addressService,
  }) : super(const OnboardingCreateState()) {
    on<CreateWallet>((event, emit) async {
      logger.d('Processing CreateWallet event');
      emit(state.copyWith(createState: CreateStateLoading()));
      final password = event.password;
      try {
        Wallet wallet = await walletService.deriveRoot(
            state.mnemonicState.mnemonic, password);

        String decryptedPrivKey =
            await encryptionService.decrypt(wallet.encryptedPrivKey, password);

        Account account = Account(
            name: 'ACCOUNT 1',
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
      if (state.mnemonicState is GenerateMnemonicStateUnconfirmed) {
        // If a mnemonic is already generated, do not generate a new one
        return;
      }
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
      if (state.mnemonicState.mnemonic != event.mnemonic.join(' ')) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (state.mnemonicState.mnemonic.split(' ')[i] != event.mnemonic[i]) {
            incorrectIndexes.add(i);
          }
        }
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase does not match',
                incorrectIndexes: incorrectIndexes)));
      } else {
        emit(state.copyWith(mnemonicError: null));
      }
    });

    on<ConfirmMnemonic>((event, emit) {
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase is required', incorrectIndexes: [])));
        return;
      }
      if (state.mnemonicState.mnemonic != event.mnemonic.join(' ')) {
        List<int> incorrectIndexes = [];
        for (int i = 0; i < 12; i++) {
          if (state.mnemonicState.mnemonic.split(' ')[i] != event.mnemonic[i]) {
            incorrectIndexes.add(i);
          }
        }
        emit(state.copyWith(
            mnemonicError: MnemonicErrorState(
                message: 'Seed phrase does not match',
                incorrectIndexes: incorrectIndexes)));
      } else {
        emit(state.copyWith(
            createState: CreateStateMnemonicConfirmed, mnemonicError: null));
      }
    });

    on<GoBackToMnemonic>((event, emit) {
      emit(state.copyWith(
          createState: CreateStateNotAsked, mnemonicError: null));
    });
  }

  String _getCoinType() =>
      switch (config.network) { Network.mainnet => "0", _ => "1" };
}
