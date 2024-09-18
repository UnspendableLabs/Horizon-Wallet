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
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc
    extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final Config config;
  final AccountRepository accountRepository;
  final AddressRepository addressRepository;
  final WalletRepository walletRepository;
  final WalletService walletService;
  final AddressService addressService;
  final MnemonicService mnemonicService;
  final EncryptionService encryptionService;

  OnboardingImportBloc({
    required this.config,
    required this.accountRepository,
    required this.addressRepository,
    required this.walletRepository,
    required this.walletService,
    required this.addressService,
    required this.mnemonicService,
    required this.encryptionService,
  }) : super(const OnboardingImportState()) {
    on<MnemonicChanged>((event, emit) async {
      if (event.mnemonic.isEmpty) {
        emit(state.copyWith(
            mnemonicError: "Seed phrase is required",
            mnemonic: event.mnemonic));
        return;
      } else if (event.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(
            mnemonicError: "Invalid seed phrase length",
            mnemonic: event.mnemonic));
        return;
      } else {
        if (state.importFormat == ImportFormat.horizon ||
            state.importFormat == ImportFormat.freewallet) {
          bool validMnemonic = mnemonicService.validateMnemonic(event.mnemonic);
          if (!validMnemonic) {
            emit(state.copyWith(
                mnemonicError: "Invalid seed phrase",
                mnemonic: event.mnemonic));
            return;
          }
        }
        emit(state.copyWith(mnemonic: event.mnemonic, mnemonicError: null));
      }
    });

    on<ImportFormatChanged>((event, emit) async {
      final importFormat = switch (event.importFormat) {
        "Horizon" => ImportFormat.horizon,
        "Freewallet" => ImportFormat.freewallet,
        "Counterwallet" => ImportFormat.counterwallet,
        _ => throw Exception('Invariant: Invalid import format')
      };
      emit(state.copyWith(importFormat: importFormat));
    });

    on<MnemonicSubmit>((event, emit) async {
      if (state.mnemonic.isEmpty) {
        emit(state.copyWith(mnemonicError: "Seed phrase is required"));
        return;
      } else if (state.mnemonic.split(' ').length != 12) {
        emit(state.copyWith(mnemonicError: "Invalid seed phrase length"));
        return;
      } else if (event.importFormat == "Horizon" ||
          event.importFormat == "Freewallet") {
        // only validate mnemonic if importing from horizon or freewallet
        bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
        if (!validMnemonic) {
          emit(state.copyWith(mnemonicError: "Invalid seed phrase"));
          return;
        }
      }
      ImportFormat importFormat = switch (event.importFormat) {
        "Horizon" => ImportFormat.horizon,
        "Freewallet" => ImportFormat.freewallet,
        "Counterwallet" => ImportFormat.counterwallet,
        _ => throw Exception('Invariant: Invalid import format')
      };
      emit(state.copyWith(
          importState: ImportStateMnemonicCollected(),
          importFormat: importFormat,
          mnemonic: event.mnemonic));
    });

    on<ImportWallet>((event, emit) async {
      emit(state.copyWith(importState: ImportStateLoading()));
      final password = event.password;
      try {
        switch (state.importFormat) {
          case ImportFormat.horizon:
            Wallet wallet =
                await walletService.deriveRoot(state.mnemonic, password);
            String decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);

            //m/84'/1'/0'/0
            Account account0 = Account(
              name: 'ACCOUNT 1',
              walletUuid: wallet.uuid,
              purpose: '84\'',
              coinType: '${_getCoinType()}\'',
              accountIndex: '0\'',
              uuid: uuid.v4(),
              importFormat: ImportFormat.horizon,
            );

            Address address = await addressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: account0.uuid,
              purpose: account0.purpose,
              coin: account0.coinType,
              account: account0.accountIndex,
              change: '0',
              index: 0,
            );

            await walletRepository.insert(wallet);
            await accountRepository.insert(account0);
            await addressRepository.insert(address);
            break;

          case ImportFormat.freewallet:
            Wallet wallet = await walletService.deriveRootFreewallet(
                state.mnemonic, password);

            String decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);

            // create an account to house
            Account account = Account(
                name: 'ACCOUNT 1',
                walletUuid: wallet.uuid,
                purpose: '32', // unused in Freewallet path
                coinType: _getCoinType(),
                accountIndex: '0\'',
                uuid: uuid.v4(),
                importFormat: ImportFormat.freewallet);

            List<Address> addressesBech32 =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.bech32,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            List<Address> addressesLegacy =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.legacy,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insertMany(addressesBech32);
            await addressRepository.insertMany(addressesLegacy);

            break;
          case ImportFormat.counterwallet:
            Wallet wallet = await walletService.deriveRootCounterwallet(
                state.mnemonic, password);

            String decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);

            // https://github.com/CounterpartyXCP/counterwallet/blob/1de386782818aeecd7c23a3d2132746a2f56e4fc/src/js/util.bitcore.js#L17
            Account account = Account(
                name: 'ACCOUNT 1',
                walletUuid: wallet.uuid,
                purpose: '0\'',
                coinType: _getCoinType(),
                accountIndex: '0\'',
                uuid: uuid.v4(),
                importFormat: ImportFormat.counterwallet);

            List<Address> addressesBech32 =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.bech32,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            List<Address> addressesLegacy =
                await addressService.deriveAddressFreewalletRange(
                    type: AddressType.legacy,
                    privKey: decryptedPrivKey,
                    chainCodeHex: wallet.chainCodeHex,
                    accountUuid: account.uuid,
                    // purpose: account.purpose,
                    // coin: account.coinType,
                    account: account.accountIndex,
                    change: '0',
                    start: 0,
                    end: 9);

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insertMany(addressesBech32);
            await addressRepository.insertMany(addressesLegacy);

            break;
          default:
            throw UnimplementedError();
        }

        emit(state.copyWith(importState: ImportStateSuccess()));
        return;
      } catch (e) {
        emit(state.copyWith(
            importState: ImportStateError(message: e.toString())));
        return;
      }
    });
  }

  String _getCoinType() =>
      switch (config.network) { Network.mainnet => "0", _ => "1" };
}
