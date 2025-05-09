import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/events_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

// ignore_for_file: constant_identifier_names
const DEFAULT_NUM_ACCOUNTS = 1;

class PasswordException implements Exception {
  final String message;
  PasswordException(this.message);
}

class MultipleWalletsException implements Exception {
  final String message;
  MultipleWalletsException(this.message);
}

// ImportWalletUseCase.call handles two wallet import types:

// 1. Horizon Native:
//    - Derive Horizon Wallet from seed + password
//    - Derive first Account + single Address; scan for btc or counterparty transactions; if no txs, insert only this first Account/Address
//    - If the first Account/Address has txs: continue deriving up to 20 Account/Address pairs until finding one without txs
//    - Insert Wallet + all Accounts/Address pairs with transactions

// 2. Freewallet / Counterwallet / RPW:
//    case a. Invalid BIP39 mnemonic - Counterwallet only:
//      - Derive Counterwallet Wallet from seed + password
//      - Derive first Account + 20 Addresses (10 bech32 + 10 legacy); scan for transactions; if no txs, insert only this first Account + 20 Addresses
//      - If has txs: derive up to 20 Accounts with 20 addresses each until finding one without txs
//      - Insert Wallet + all Accounts/Addresses with transactions

//    case b. Invalid Counterwallet mnemonic - Freewallet only:
//      - Derive Freewallet Wallet from seed + password
//      - Same flow as case a, but using Freewallet Wallet

//    case c. mnemonic can be a valid counterwallet or freewallet seed phrase - Counterwallet is the default:
//      - Attempt to import Counterwallet as outlined in case a. If there are CW txs, insert CW Wallet + Accounts/Addresses
//      - If there are no Counterwallet txs: attempt to import Freewallet as outlined in case b.
//      - If there are transactions on the Freewallet Accounts/Addresses: insert Freewallet Wallet + Accounts/Addresses
//      - Otherwise, default to Counterwallet and insert CW Wallet + Accounts/Addresses

// At the end of the import, the decryption key is written to secure storage
// onSuccess() is called to redirect the user to the dashboard screen

class ImportWalletUseCase {
  final InMemoryKeyRepository inMemoryKeyRepository;
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final Config config;
  final WalletService walletService;
  final BitcoinRepository bitcoinRepository;
  final MnemonicService mnemonicService;
  final EventsRepository eventsRepository;

  ImportWalletUseCase({
    required this.inMemoryKeyRepository,
    required this.addressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.config,
    required this.walletService,
    required this.bitcoinRepository,
    required this.mnemonicService,
    required this.eventsRepository,
  });

  Future<Map<Account, List<Address>>> createHorizonWallet({
    required String password,
    required String mnemonic,
    required Wallet wallet,
  }) async {
    Map<Account, List<Address>> accountsWithBalances = {};

    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // Attempt to find balances/transactions for up to 20 accounts, checking only the first address for each horizon account
    for (var i = 0; i < DEFAULT_NUM_ACCOUNTS; i++) {
      // m/84'/0'/0'/0
      Account account = Account(
        name: 'ACCOUNT ${i + 1}',
        walletUuid: wallet.uuid,
        purpose: '84\'',
        coinType: '${_getCoinType()}\'',
        accountIndex: '$i\'',
        uuid: uuid.v4(),
        importFormat: ImportFormat.horizon,
      );

      accountsWithBalances[account] = [];
    }

    return accountsWithBalances;
  }

  Future<(Map<Account, List<Address>>, bool)> createBip32Wallet({
    required String password,
    required String mnemonic,
    required Wallet wallet,
    required ImportFormat importFormat,
  }) async {
    // This method is used for both counterwallet and freewallet
    // The Account and Address derivations are exactly the same for both but derive from different wallet types
    bool hasTransactions = false;

    Map<Account, List<Address>> accountsWithBalances = {};
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // The purpose is unused for both counterwallet and freewallet derivations so this is unnecessary
    // However, as a distinction, we save the counterwallet purpose as '0\' and the freewallet purpose as '32'
    final purpose = switch (importFormat) {
      ImportFormat.counterwallet => '0\'',
      ImportFormat.freewallet => '32',
      _ => throw UnimplementedError(),
    };

    // TODO: don't use account name, just use indices
    Account account = Account(
        name: 'Account 1',
        walletUuid: wallet.uuid,
        purpose: purpose,
        coinType: _getCoinType(),
        accountIndex: '0\'',
        uuid: uuid.v4(),
        importFormat: importFormat);

    // derive all 20 addresses for the account
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

    // import the first account + addresses, even if there are no transactions
    accountsWithBalances[account] = [
      ...addressesBech32,
      ...addressesLegacy,
    ];

    final allAddressesHaveTransactions = await addressesHaveTransactions([
      ...addressesBech32,
      ...addressesLegacy,
    ]);

    // if there are any transactions on the first account, check any following accounts for transactions, up to 20 accounts
    if (allAddressesHaveTransactions) {
      hasTransactions = true;
      // check any subsequent accounts for transactions, up to 20 accounts
      for (int i = 1; i < DEFAULT_NUM_ACCOUNTS; i++) {
        Account nextAccount = Account(
            name: 'ACCOUNT ${i + 1}',
            walletUuid: wallet.uuid,
            purpose: account.purpose,
            coinType: account.coinType,
            accountIndex: '$i\'',
            uuid: uuid.v4(),
            importFormat: importFormat);

        List<Address> nextAddressesBech32 =
            await addressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: nextAccount.uuid,
                account: nextAccount.accountIndex,
                change: '0',
                start: 0,
                end: 9);

        List<Address> nextAddressesLegacy =
            await addressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: nextAccount.uuid,
                account: nextAccount.accountIndex,
                change: '0',
                start: 0,
                end: 9);

        final bool allAddressesHaveTransactions =
            await addressesHaveTransactions([
          ...nextAddressesBech32,
          ...nextAddressesLegacy,
        ]);
        if (!allAddressesHaveTransactions) {
          // break at the first account with no transactions
          break;
        }
        accountsWithBalances[nextAccount] = [
          ...nextAddressesBech32,
          ...nextAddressesLegacy,
        ];
      }
    }
    return (accountsWithBalances, hasTransactions);
  }

  Future<void> call({
    required String password,
    required WalletType walletType,
    required String mnemonic,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      Wallet wallet;
      Map<Account, List<Address>> accountsWithBalances = {};

      switch (walletType) {
        case WalletType.horizon:
          wallet = await walletService.deriveRoot(mnemonic, password);
          accountsWithBalances = await createHorizonWallet(
              password: password, mnemonic: mnemonic, wallet: wallet);
          break;

        case WalletType.bip32:
          final isValidBip39 = mnemonicService.validateMnemonic(mnemonic);
          if (!isValidBip39) {
            // if the seed phrase is not valid bip39, import counterwallet and break
            wallet =
                await walletService.deriveRootCounterwallet(mnemonic, password);
            (accountsWithBalances, _) = await createBip32Wallet(
                password: password,
                mnemonic: mnemonic,
                wallet: wallet,
                importFormat: ImportFormat.counterwallet);
            break;
          }

          final isValidCounterwallet =
              mnemonicService.validateCounterwalletMnemonic(mnemonic);
          if (!isValidCounterwallet) {
            // if the seed phrase is not valid counterwallet, import freewallet and break
            wallet =
                await walletService.deriveRootFreewallet(mnemonic, password);
            (accountsWithBalances, _) = await createBip32Wallet(
                password: password,
                mnemonic: mnemonic,
                wallet: wallet,
                importFormat: ImportFormat.freewallet);
            break;
          }

          // we will get to this point if the seed phrase is both valid bip39 and valid counterwallet, which is not very common, but possible
          // in this case, for bip32 wallets, assume 99% of users have a counterwallet seed phrase
          // counterwallet seeds are the default freewallet/RPW seed phrases
          final counterwallet =
              await walletService.deriveRootCounterwallet(mnemonic, password);
          final (
            counterwalletAccountsWithBalances,
            counterwalletHasTransactions
          ) = await createBip32Wallet(
              password: password,
              mnemonic: mnemonic,
              wallet: counterwallet,
              importFormat: ImportFormat.counterwallet);

          // default to importing counterwallet in the case of no Freewallet transactions
          wallet = counterwallet;
          accountsWithBalances = counterwalletAccountsWithBalances;

          if (!counterwalletHasTransactions) {
            // if there are no counterwallet transactions, check freewallet bip39
            final freewallet =
                await walletService.deriveRootFreewallet(mnemonic, password);
            final (freewalletAccountsWithBalances, freewalletHasTransactions) =
                await createBip32Wallet(
                    password: password,
                    mnemonic: mnemonic,
                    wallet: freewallet,
                    importFormat: ImportFormat.freewallet);

            if (freewalletHasTransactions) {
              // import freewallet ONLY IF THERE ARE TRANSACTIONS ON THE FREEWALLET ACCOUNTS
              wallet = freewallet;
              accountsWithBalances = freewalletAccountsWithBalances;
            }
          }
          break;

        default:
          throw UnimplementedError();
      }

      final existingWallet = await walletRepository.getCurrentWallet();
      if (existingWallet != null) {
        throw MultipleWalletsException(onboardingErrorMessage);
      }

      // insert wallet, accounts, and addresses
      await walletRepository.insert(wallet);
      for (var account in accountsWithBalances.keys) {
        await accountRepository.insert(account);
        await addressRepository.insertMany(accountsWithBalances[account]!);
      }

      final currentWallet = await walletRepository.getCurrentWallet();

      if (currentWallet == null) {
        throw Exception('Wallet insert failed');
      }

      String decryptionKey = await encryptionService.getDecryptionKey(
          currentWallet.encryptedPrivKey, password);

      // write decryption key to secure storage ( i.e. create a valid session )
      await inMemoryKeyRepository.set(key: decryptionKey);

      onSuccess();
      return;
    } catch (e, callstack) {
      if (e is PasswordException) {
        onError(e.message);
      } else if (e is MultipleWalletsException) {
        onError(e.message);
      } else {
        print(e);
        print(callstack);

        onError('An unexpected error occurred importing wallet');
      }
    }
  }

  // Future<void> callHorizon({
  //   required String mnemonic,
  //   required String password,
  //   required Future<Wallet> Function(String, String) deriveWallet,
  // }) async {
  //   Wallet wallet = await deriveWallet(mnemonic, password);
  //   String decryptedPrivKey;
  //   try {
  //     decryptedPrivKey =
  //         await encryptionService.decrypt(wallet.encryptedPrivKey, password);
  //   } catch (e) {
  //     throw PasswordException('invariant: Invalid password');
  //   }
  //
  //   // m/84'/1'/0'/0
  //   Account account0 = Account(
  //     name: 'ACCOUNT 1',
  //     walletUuid: wallet.uuid,
  //     purpose: '84\'',
  //     coinType: '${_getCoinType()}\'',
  //     accountIndex: '0\'',
  //     uuid: uuid.v4(),
  //     importFormat: ImportFormat.horizon,
  //   );
  //
  //   Address address = await addressService.deriveAddressSegwit(
  //     privKey: decryptedPrivKey,
  //     chainCodeHex: wallet.chainCodeHex,
  //     accountUuid: account0.uuid,
  //     purpose: account0.purpose,
  //     coin: account0.coinType,
  //     account: account0.accountIndex,
  //     change: '0',
  //     index: 0,
  //   );
  //
  //   final existingWallet = await walletRepository.getCurrentWallet();
  //   if (existingWallet != null) {
  //     throw MultipleWalletsException(onboardingErrorMessage);
  //   }
  //
  //   await walletRepository.insert(wallet);
  //   await accountRepository.insert(account0);
  //   await addressRepository.insert(address);
  //
  //   // write decryption key to secure storage ( i.e. create a valid session )
  //   final currentWallet = await walletRepository.getCurrentWallet();
  //
  //   if (currentWallet == null) {
  //     throw Exception('Wallet insert failed');
  //   }
  //
  //   String decryptionKey = await encryptionService.getDecryptionKey(
  //       currentWallet.encryptedPrivKey, password);
  //
  //   await inMemoryKeyRepository.set(key: decryptionKey);
  // }

  Future<bool> addressesHaveTransactions(List<Address> addresses) async {
    final List<BitcoinTx> btcTransactions = await bitcoinRepository
        .getTransactions(addresses.map((e) => e.address).toList())
        .then((either) async {
      return either.fold(
        (error) => throw Exception("GetTransactionInfo failure"),
        (transactions) => transactions,
      );
    });

    final int numCounterpartyTransactions =
        await eventsRepository.numEventsForAddresses(
            addresses: addresses.map((e) => e.address).toList());

    return btcTransactions.isNotEmpty || numCounterpartyTransactions > 0;
  }

  String _getCoinType() => switch (config.network) {
        Network.mainnet => "0",
        _ => "1",
      };
}
