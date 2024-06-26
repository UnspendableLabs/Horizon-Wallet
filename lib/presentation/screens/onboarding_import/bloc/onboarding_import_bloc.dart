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
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_event.dart';
import 'package:horizon/presentation/screens/onboarding_import/bloc/onboarding_import_state.dart';

class OnboardingImportBloc extends Bloc<OnboardingImportEvent, OnboardingImportState> {
  final accountRepository = GetIt.I<AccountRepository>();
  final addressRepository = GetIt.I<AddressRepository>();
  final walletRepository = GetIt.I<WalletRepository>();
  final walletService = GetIt.I<WalletService>();
  final addressService = GetIt.I<AddressService>();
  final mnemonicService = GetIt.I<MnemonicService>();
  final encryptionService = GetIt.I<EncryptionService>();

  OnboardingImportBloc() : super(OnboardingImportState()) {
    on<PasswordSubmit>((event, emit) {
      if (event.password != event.passwordConfirmation) {
        emit(state.copyWith(passwordError: "Passwords do not match"));
      } else if (event.password.length != 32) {
        emit(state.copyWith(passwordError: "Password must be 32 characters.  Don't worry, we'll change this :)"));
      } else {
        emit(state.copyWith(password: event.password, passwordError: null));
      }
    });

    on<MnemonicChanged>((event, emit) async {
      emit(state.copyWith(mnemonic: event.mnemonic));
    });

    on<ImportFormatChanged>((event, emit) async {
      ImportFormat importFormat = event.importFormat == "Segwit" ? ImportFormat.segwit : ImportFormat.freewalletBech32;
      emit(state.copyWith(importFormat: importFormat));
    });

    on<ImportWallet>((event, emit) async {
      bool validMnemonic = mnemonicService.validateMnemonic(state.mnemonic);
      if (!validMnemonic) {
        emit(state.copyWith(importState: ImportStateError(message: "Invalid mnemonic")));
        return;
      }

      emit(state.copyWith(importState: ImportStateLoading()));
      try {
        switch (state.importFormat) {
          case ImportFormat.segwit:
            Wallet wallet = await walletService.deriveRoot(state.mnemonic, state.password!);

            final decryptedPrivKey = await encryptionService.decrypt(wallet.encryptedPrivKey, state.password!);
            //m/84'/1'/0'/0
            Account account0 = Account(
              name: 'Account #0',
              walletUuid: wallet.uuid,
              purpose: '84\'',
              coinType: '${_getCoinType()}\'',
              accountIndex: '0\'',
              uuid: uuid.v4(),
            );
            
            Address address0 = await addressService.deriveAddressSegwit(
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account0.uuid,
                purpose: account0.purpose,
                coin: account0.coinType,
                account: account0.accountIndex,
                change: '0',
                index: 0);

            await walletRepository.insert(wallet);
            await accountRepository.insert(account0);
            // await accountRepository.insert(account1);
            // await accountRepository.insert(account2);
            await addressRepository.insert(address0);
            // await addressRepository.insert(address1);
            // await addressRepository.insert(address2);

            break;
          case ImportFormat.freewalletBech32:
            Wallet wallet = await walletService.deriveRoot(state.mnemonic, state.password!);

            final decryptedPrivKey = await encryptionService.decrypt(wallet.encryptedPrivKey, state.password!);

            Account account = Account(
                name: 'Account 0',
                walletUuid: wallet.uuid,
                purpose: '32', // unused in Freewallet path
                coinType: _getCoinType(),
                accountIndex: '0\'',
                uuid: uuid.v4());

            List<Address> addresses = await addressService.deriveAddressFreewalletBech32Range(
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: account.uuid,
                purpose: account.purpose,
                coin: account.coinType,
                account: account.accountIndex,
                change: '0',
                start: 0,
                end: 7);

            await walletRepository.insert(wallet);
            await accountRepository.insert(account);
            await addressRepository.insertMany(addresses);

            break;
          default:
            throw UnimplementedError();
        }

        emit(state.copyWith(importState: ImportStateSuccess()));
        return;
      } catch (e, stackTrace) {
        emit(state.copyWith(importState: ImportStateError(message: e.toString())));
        print(e.toString());
        print(stackTrace);
        return;
      }
    });
  }

  String _getCoinType() {
    bool isTestnet = dotenv.get('TEST') == 'true';
    return isTestnet ? '1' : '0';
  }
}
