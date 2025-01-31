import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/bitcoin_tx.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/bitcoin_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/mnemonic_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:horizon/test_config.dart';

// ignore_for_file: constant_identifier_names
const GAP_LIMIT = 20;

class PasswordException implements Exception {
  final String message;
  PasswordException(this.message);
}

class ImportWalletUseCase {
  final InMemoryKeyRepository inMemoryKeyRepository;
  final AddressRepository addressRepository;
  final AccountRepository accountRepository;
  final WalletRepository walletRepository;
  final EncryptionService encryptionService;
  final AddressService addressService;
  final Config config;
  final WalletService walletService;
  final AddressTxRepository addressTxRepository;
  final BalanceRepository balanceRepository;
  final BitcoinRepository bitcoinRepository;
  final MnemonicService mnemonicService;

  ImportWalletUseCase({
    required this.inMemoryKeyRepository,
    required this.addressRepository,
    required this.accountRepository,
    required this.walletRepository,
    required this.encryptionService,
    required this.addressService,
    required this.config,
    required this.walletService,
    required this.addressTxRepository,
    required this.balanceRepository,
    required this.bitcoinRepository,
    required this.mnemonicService,
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
    for (var i = 0; i < GAP_LIMIT; i++) {
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

      Address address = await addressService.deriveAddressSegwit(
        privKey: decryptedPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        accountUuid: account.uuid,
        purpose: account.purpose,
        coin: account.coinType,
        account: account.accountIndex,
        change: '0',
        index: 0,
      );

      // get transactions and balances for the segwit address
      final List<BitcoinTx> transactions =
          await bitcoinRepository.getTransactions([address.address]).then(
        (either) async {
          return either.fold(
            (error) => throw Exception("GetTransactionInfo failure"),
            (transactions) => transactions,
          );
        },
      );

      // if there are any transactions or balances for the address, add the address to the account
      // if there are any transactions or balances for the address, add the address to the account
      if (transactions.isNotEmpty) {
        // add the segwit address to the account if balances or transactions are present
        if (accountsWithBalances.containsKey(account)) {
          accountsWithBalances[account]!.add(address);
        } else {
          accountsWithBalances[account] = [address];
        }
      } else if (i == 0) {
        // if no transactions are found on the first account, we will import just the first account + address and break
        accountsWithBalances[account] = [address];
        break;
      } else {
        // break the loop at the once we reach an account with no transactions
        break;
      }
    }

    return accountsWithBalances;
  }

  Future<(Map<Account, List<Address>>, bool)> createCounterwalletWallet({
    required String password,
    required String mnemonic,
    required Wallet wallet,
  }) async {
    bool hasTransactions = false;

    Map<Account, List<Address>> accountsWithBalances = {};
    // we assume that 99% of imports will be counterwallet
    // first we check if there are any transactions on the counterwallet account
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('Invalid password');
    }

    // https://github.com/CounterpartyXCP/counterwallet/blob/1de386782818aeecd7c23a3d2132746a2f56e4fc/src/js/util.bitcore.js#L17
    Account counterwalletAccount = Account(
        name: 'ACCOUNT 1',
        walletUuid: wallet.uuid,
        purpose: '0\'',
        coinType: _getCoinType(),
        accountIndex: '0\'',
        uuid: uuid.v4(),
        importFormat: ImportFormat.counterwallet);

    // import all 20 addresses for the counterwallet account
    List<Address> addressesBech32 =
        await addressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: counterwalletAccount.uuid,
            account: counterwalletAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    List<Address> addressesLegacy =
        await addressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: counterwalletAccount.uuid,
            account: counterwalletAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    // we will import the first account + addresses, even if there are no transactions
    accountsWithBalances[counterwalletAccount] = [
      ...addressesBech32,
      ...addressesLegacy,
    ];

    final firstAccountTransactions = await bitcoinRepository.getTransactions([
      ...addressesBech32.map((e) => e.address),
      ...addressesLegacy.map((e) => e.address),
    ]).then((either) async {
      return either.fold(
        (error) => throw Exception("GetTransactionInfo failure"),
        (transactions) => transactions,
      );
    });

    // if there are any transactions on the counterwallet account, check any following accounts for transactions, up to 20 accounts
    if (firstAccountTransactions.isNotEmpty) {
      hasTransactions = true;
      // check any subsequent accounts for transactions, up to 20 accounts
      for (int i = 1; i < GAP_LIMIT; i++) {
        Account nextCounterwalletAccount = Account(
            name: 'ACCOUNT ${i + 1}',
            walletUuid: wallet.uuid,
            purpose: counterwalletAccount.purpose,
            coinType: counterwalletAccount.coinType,
            accountIndex: '$i\'',
            uuid: uuid.v4(),
            importFormat: ImportFormat.counterwallet);
        List<Address> nextAddressesBech32 =
            await addressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: nextCounterwalletAccount.uuid,
                account: nextCounterwalletAccount.accountIndex,
                change: '0',
                start: 0,
                end: 9);

        List<Address> nextAddressesLegacy =
            await addressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: decryptedPrivKey,
                chainCodeHex: wallet.chainCodeHex,
                accountUuid: nextCounterwalletAccount.uuid,
                account: nextCounterwalletAccount.accountIndex,
                change: '0',
                start: 0,
                end: 9);

        final allTransactions = await bitcoinRepository.getTransactions([
          ...nextAddressesBech32.map((e) => e.address),
          ...nextAddressesLegacy.map((e) => e.address),
        ]).then((either) async {
          return either.fold(
            (error) => throw Exception("GetTransactionInfo failure"),
            (transactions) => transactions,
          );
        });
        if (allTransactions.isEmpty) {
          // we will break at the first account with no transactions
          break;
        }
        accountsWithBalances[nextCounterwalletAccount] = [
          ...nextAddressesBech32,
          ...nextAddressesLegacy,
        ];
      }
    }
    return (accountsWithBalances, hasTransactions);
  }

  Future<Map<Account, List<Address>>> createFreewalletWallet({
    required String password,
    required String mnemonic,
    required Wallet wallet,
  }) async {
    final Map<Account, List<Address>> accountsWithBalances = {};
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant:Invalid password');
    }
    // create freewallet account
    Account freewalletAccount = Account(
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
            accountUuid: freewalletAccount.uuid,
            account: freewalletAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    List<Address> addressesLegacy =
        await addressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: freewalletAccount.uuid,
            account: freewalletAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    final allTransactionsFreewallet = await bitcoinRepository.getTransactions([
      ...addressesBech32.map((e) => e.address),
      ...addressesLegacy.map((e) => e.address),
    ]).then((either) async {
      return either.fold(
        (error) => throw Exception("GetTransactionInfo failure"),
        (transactions) => transactions,
      );
    });
    if (allTransactionsFreewallet.isEmpty) {
      if (TestConfig.skipCounterwallet) {
        accountsWithBalances[freewalletAccount] = [
          ...addressesBech32,
          ...addressesLegacy,
        ];
        return accountsWithBalances;
      } else {
        return {};
      }
    }
    // import all 20 addresses for the freewallet account
    accountsWithBalances[freewalletAccount] = [
      ...addressesBech32,
      ...addressesLegacy,
    ];
    for (int i = 1; i < GAP_LIMIT; i++) {
      Account nextFreewalletAccount = Account(
          name: 'ACCOUNT ${i + 1}',
          walletUuid: wallet.uuid,
          purpose: freewalletAccount.purpose,
          coinType: freewalletAccount.coinType,
          accountIndex: '$i\'',
          uuid: uuid.v4(),
          importFormat: ImportFormat.freewallet);
      List<Address> addressesBech32 =
          await addressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: nextFreewalletAccount.uuid,
              account: nextFreewalletAccount.accountIndex,
              change: '0',
              start: 0,
              end: 9);

      List<Address> addressesLegacy =
          await addressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: decryptedPrivKey,
              chainCodeHex: wallet.chainCodeHex,
              accountUuid: nextFreewalletAccount.uuid,
              account: nextFreewalletAccount.accountIndex,
              change: '0',
              start: 0,
              end: 9);

      final allTransactions = await bitcoinRepository.getTransactions([
        ...addressesBech32.map((e) => e.address),
        ...addressesLegacy.map((e) => e.address),
      ]).then((either) async {
        return either.fold(
          (error) => throw Exception("GetTransactionInfo failure"),
          (transactions) => transactions,
        );
      });
      if (allTransactions.isEmpty) {
        // we will break at the first account with no transactions
        break;
      }
      accountsWithBalances[nextFreewalletAccount] = [
        ...addressesBech32,
        ...addressesLegacy,
      ];
    }
    return accountsWithBalances;
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
          // for bip32 wallets, assume 99% of users have a counterwallet seed phrase
          // counterwallet seeds are the main freewallet/RPW seed phrases
          bool counterwalletHasTransactions = false;

          // TestConfig is used here in case we want to skip directly to importing freewallet
          if (!TestConfig.skipCounterwallet) {
            wallet =
                await walletService.deriveRootCounterwallet(mnemonic, password);
            (accountsWithBalances, counterwalletHasTransactions) =
                await createCounterwalletWallet(
                    password: password, mnemonic: mnemonic, wallet: wallet);

            if (!counterwalletHasTransactions) {
              // if there are no counterwallet transactions, we will check freewallet
              // however, if the seed phrase is not valid bip39, we can break immediately and import  counterwallet
              final isValidBip39 = mnemonicService.validateMnemonic(mnemonic);
              if (!isValidBip39) {
                break;
              }
              wallet =
                  await walletService.deriveRootFreewallet(mnemonic, password);
              final freewalletAccountsWithBalances =
                  await createFreewalletWallet(
                      password: password, mnemonic: mnemonic, wallet: wallet);

              // we import freewallet ONLY IF THERE ARE TRANSACTIONS ON THE FREEWALLET ACCOUNTS
              // otherwise, we will import counterwallet
              if (freewalletAccountsWithBalances.isNotEmpty) {
                accountsWithBalances = freewalletAccountsWithBalances;
              }
            }
          } else {
            // if we are skipping counterwallet, we will skip to importing freewallet
            wallet =
                await walletService.deriveRootFreewallet(mnemonic, password);
            accountsWithBalances = await createFreewalletWallet(
                password: password, mnemonic: mnemonic, wallet: wallet);
          }

          break;

        default:
          throw UnimplementedError();
      }

      // insert wallet, accounts, and addresses
      await walletRepository.insert(wallet);
      for (var account in accountsWithBalances.keys) {
        await accountRepository.insert(account);
        await addressRepository.insertMany(accountsWithBalances[account]!);
      }
      // write decryption key to secure storage ( i.e. create a valid session )
      // final wallet = await walletRepository.getCurrentWallet();

      String decryptionKey = await encryptionService.getDecryptionKey(
          wallet.encryptedPrivKey, password);

      await inMemoryKeyRepository.set(key: decryptionKey);

      onSuccess();
      return;
    } catch (e) {
      if (e is PasswordException) {
        onError(e.message);
      } else {
        onError('An unexpected error occurred importing wallet');
      }
    }
  }

  Future<void> callHorizon({
    required String mnemonic,
    required String password,
    required Future<Wallet> Function(String, String) deriveWallet,
  }) async {
    Wallet wallet = await deriveWallet(mnemonic, password);
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // m/84'/1'/0'/0
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
  }

  String _getCoinType() => switch (config.network) {
        Network.mainnet => "0",
        _ => "1",
      };
}
