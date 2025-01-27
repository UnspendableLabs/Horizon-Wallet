import 'package:horizon/common/constants.dart';
import 'package:horizon/common/uuid.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/balance.dart';
import 'package:horizon/domain/entities/transaction.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/address_tx_repository.dart';
import 'package:horizon/domain/repositories/balance_repository.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';

// ignore_for_file: constant_identifier_names
const GAP_LIMIT = 20;
const SKIP_LIMIT = 3;

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
  });

  Future<void> callAllWallets({
    required String password,
    required String mnemonic,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      Wallet wallet;
      Map<Account, List<Address>> accountsWithBalances;

      (wallet, accountsWithBalances) = await createWalletForImportFormat(
        password: password,
        importFormat: ImportFormat.horizon,
        mnemonic: mnemonic,
      );
      if (accountsWithBalances.isEmpty) {
        print('no accounts with balances for horizon');
        // TODO: try freewallet
        (wallet, accountsWithBalances) = await createWalletForImportFormat(
          password: password,
          importFormat: ImportFormat.freewallet,
          mnemonic: mnemonic,
        );
      }

      if (accountsWithBalances.isEmpty) {
        print('no accounts with balances for freewallet');
        // TODO: try counterwallet
        (wallet, accountsWithBalances) = await createWalletForImportFormat(
          password: password,
          importFormat: ImportFormat.counterwallet,
          mnemonic: mnemonic,
        );
      }

      if (accountsWithBalances.isEmpty) {
        print('no accounts with balances for counterwallet');
        throw Exception('invariant: no accounts have balances');
      }

      // proceed with inserting wallet/accounts/addresses
      print('inserting wallet');
      walletRepository.insert(wallet);

      for (var account in accountsWithBalances.keys) {
        print('inserting account ${account.name}');
        await accountRepository.insert(account);
        print('inserting addresses for account ${account.name}');
        await addressRepository.insertMany(accountsWithBalances[account]!);
      }

      print('writing decryption key to secure storage');
      // write decryption key to secure storage ( i.e. create a valid session )
      final currentWallet = await walletRepository.getCurrentWallet();

      String decryptionKey = await encryptionService.getDecryptionKey(
          currentWallet!.encryptedPrivKey, password);

      await inMemoryKeyRepository.set(key: decryptionKey);

      print('calling onSuccess');
      onSuccess();
      return;
    } on PasswordException catch (e) {
      onError(e.message);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<(Wallet, Map<Account, List<Address>>)> createWalletForImportFormat({
    required String password,
    required ImportFormat importFormat,
    required String mnemonic,
  }) async {
    Map<Account, List<Address>> accountsWithBalances = {};
    print('creating wallet for import format $importFormat');

    final wallet = switch (importFormat) {
      ImportFormat.horizon =>
        await walletService.deriveRoot(mnemonic, password),
      ImportFormat.freewallet =>
        await walletService.deriveRootFreewallet(mnemonic, password),
      ImportFormat.counterwallet =>
        await walletService.deriveRootCounterwallet(mnemonic, password),
    };
    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // Track accounts that have no balance; once 3 accounts have been skipped, stop importing
    int skippedAccounts = 0;
    Account? lastAccountWithBalances;

    // Attempt to find balances/transactions for up to 20 accounts, checking up to 20 addresses per account
    for (var i = 0; i < GAP_LIMIT; i++) {
      print("ACCOUNT $i");
      // m/84'/0'/0'/0
      Account account = Account(
        name: 'ACCOUNT ${i + 1}',
        walletUuid: wallet.uuid,
        purpose: '84\'',
        coinType: '${_getCoinType()}\'',
        accountIndex: '$i\'',
        uuid: uuid.v4(),
        importFormat: importFormat,
      );

      // Track addresses that have no balance; once 3 addresses have been skipped, stop importing
      int skippedAddresses = 0;
      Address? firstAddressForAccount;

      for (var j = 0; j < GAP_LIMIT; j++) {
        if (j == 0) {
          // reset the skippedAddresses counter since we are starting a new account
          skippedAddresses = 0;
        }
        print("ADDRESS $j");
        Address addressSegwit;
        Address? addressLegacy;
        if (importFormat == ImportFormat.horizon) {
          // derive single segwit address for horizon
          addressSegwit = await addressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: account.uuid,
            purpose: account.purpose,
            coin: account.coinType,
            account: account.accountIndex,
            change: '0',
            index: j,
          );
        } else {
          // derive single bech32 address and single legacy address for freewallet and counterwallet
          List<Address> singleAddressSegwit =
              await addressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: account.uuid,
            account: account.accountIndex,
            change: '0',
            start: j,
            end: j,
          );
          addressSegwit = singleAddressSegwit[0];

          List<Address> singleAddressLegacy =
              await addressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: account.uuid,
            account: account.accountIndex,
            change: '0',
            start: j,
            end: j,
          );

          addressLegacy = singleAddressLegacy[0];
        }

        if (j == 0) {
          // capture the first address for the account
          // at the end, if the account has no balances, we will add the first address to the account
          firstAddressForAccount = addressSegwit;
        }

        // get transactions and balances for the segwit address
        final List<Transaction> transactionsSegwit = await addressTxRepository
            .getTransactionsByAddress(addressSegwit.address);
        List<Balance> balancesSegwit = await balanceRepository
            .getBalancesForAddress(addressSegwit.address);

        List<Balance>? balancesLegacy;
        List<Transaction>? transactionsLegacy;

        // get transactions and balances for the legacy address, when present
        if (addressLegacy != null) {
          balancesLegacy = await balanceRepository
              .getBalancesForAddress(addressLegacy.address);
          transactionsLegacy = await addressTxRepository
              .getTransactionsByAddress(addressLegacy.address);
        }

        // The balances method always returns a BTC balance, even if it's 0.
        // If the BTC balance is 0, remove it from the list
        if (balancesSegwit.length == 1 &&
            balancesSegwit.first.asset == 'BTC' &&
            balancesSegwit.first.quantity == 0) {
          balancesSegwit = [];
        }

        if (balancesLegacy != null &&
            balancesLegacy.length == 1 &&
            balancesLegacy.first.asset == 'BTC' &&
            balancesLegacy.first.quantity == 0) {
          balancesLegacy = [];
        }

        // if there are any transactions or balances for the segwit address or the legacy address, add the address to the account
        if (transactionsSegwit.isNotEmpty ||
            balancesSegwit.isNotEmpty ||
            (balancesLegacy != null && balancesLegacy.isNotEmpty) ||
            (transactionsLegacy != null && transactionsLegacy.isNotEmpty)) {
          // reset the skippedAddresses and skippedAccounts counter since we have just added an address
          skippedAddresses = 0;
          skippedAccounts = 0;

          // capture the most recent account with balances
          lastAccountWithBalances = account;
          print("ADDED ADDRESS $j for account $i");

          if (balancesSegwit.isNotEmpty || transactionsSegwit.isNotEmpty) {
            // add the segwit address to the account if balances or transactions are present
            if (accountsWithBalances.containsKey(account)) {
              accountsWithBalances[account]!.add(addressSegwit);
            } else {
              accountsWithBalances[account] = [addressSegwit];
            }
          } else if (balancesLegacy != null && balancesLegacy.isNotEmpty ||
              transactionsLegacy != null && transactionsLegacy.isNotEmpty) {
            // add the legacy address to the account if balances or transactions are present
            if (accountsWithBalances.containsKey(account)) {
              accountsWithBalances[account]!.add(addressLegacy!);
            } else {
              accountsWithBalances[account] = [addressLegacy!];
            }
          }
        } else {
          // if the current address has no balances or transactions for either the segwit or legacy address, add it to the skippedAddresses list
          skippedAddresses++;
        }

        // If 3 consecutive addresss have no balance, break the loop and move to the next account
        if (skippedAddresses >= SKIP_LIMIT) {
          break;
        }
      }
      // If we have not yet reached the skip limit,
      // if the current account has no balances, add to the skip limit
      if (skippedAccounts < SKIP_LIMIT &&
          (!accountsWithBalances.containsKey(account))) {
        print('skipping account $i');
        skippedAccounts++;

        if (firstAddressForAccount == null ||
            firstAddressForAccount.accountUuid != account.uuid) {
          throw Exception(
              'invariant: first address for account $i is null or does not match account uuid');
        }
        // we capture skipped accounts in case it falls between accounts with balances
        // for example, if I have balances for accounts 1-3, no balances for account 4, but account 5 has balances, then we want to add account 4 to the list of accounts to be imported
        accountsWithBalances[account] = [firstAddressForAccount];
      }

      // once we have passed 3 accounts with no balances, break the loop and proceed with inserting wallet/accounts/addresses
      if (skippedAccounts >= SKIP_LIMIT) {
        // Remove all empty accounts beyond the last account with balances
        if (lastAccountWithBalances != null) {
          accountsWithBalances.removeWhere(
            (acc, _) =>
                int.parse(acc.accountIndex.replaceAll("'", '')) >
                int.parse(
                    lastAccountWithBalances!.accountIndex.replaceAll("'", '')),
          );
        } else {
          // If no accounts have balances, clear the accountsWithBalances map
          accountsWithBalances.clear();
        }
        break;
      }
    }

    return (wallet, accountsWithBalances);
  }

  Future<void> call({
    required String password,
    required ImportFormat importFormat,
    required String mnemonic,
    required Future<Wallet> Function(String, String) deriveWallet,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      switch (importFormat) {
        case ImportFormat.horizon:
          await callHorizon(
              mnemonic: mnemonic,
              password: password,
              deriveWallet: deriveWallet);
          break;

        case ImportFormat.freewallet:
          Wallet wallet = await deriveWallet(mnemonic, password);
          String decryptedPrivKey;
          try {
            decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);
          } catch (e) {
            throw PasswordException('invariant:Invalid password');
          }
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
          Wallet wallet = await deriveWallet(mnemonic, password);
          String decryptedPrivKey;
          try {
            decryptedPrivKey = await encryptionService.decrypt(
                wallet.encryptedPrivKey, password);
          } catch (e) {
            throw PasswordException('Invalid password');
          }
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

      // write decryption key to secure storage ( i.e. create a valid session )
      final wallet = await walletRepository.getCurrentWallet();

      String decryptionKey = await encryptionService.getDecryptionKey(
          wallet!.encryptedPrivKey, password);

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
