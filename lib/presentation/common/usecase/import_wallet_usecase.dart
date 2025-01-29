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
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';

// ignore_for_file: constant_identifier_names
const GAP_LIMIT = 20;
const SKIP_LIMIT = 1;

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
  });

  Future<void> callAllWallets({
    required String password,
    required String mnemonic,
    required WalletType walletType,
    required Function(String) onError,
    required Function() onSuccess,
  }) async {
    try {
      print('walletType: $walletType');
      Map<Account, List<Address>> accountsWithBalances;
      Wallet wallet;

      print('deriving accounts and addresses');

      if (walletType == WalletType.horizon) {
        // derive a horizon wallet
        wallet = await walletService.deriveRoot(mnemonic, password);
        accountsWithBalances = await createHorizonWallet(
          password: password,
          mnemonic: mnemonic,
          wallet: wallet,
        );
      } else {
        // if bip32 wallet is selected, we default to counterwallet
        // the assumption here is that 99% of imports will be counterwallet
        wallet =
            await walletService.deriveRootCounterwallet(mnemonic, password);
        accountsWithBalances = await createBip32Wallet(
          password: password,
          importFormat: ImportFormat.counterwallet,
          mnemonic: mnemonic,
          wallet: wallet,
        );
      }

      // if counterwallet
      if (walletType == WalletType.bip32 && accountsWithBalances.isEmpty) {
        wallet = await walletService.deriveRootFreewallet(mnemonic, password);
        print('no counterwallet balances found, checking freewallet');
        // after checking counterwallet, if there are no balances, we will check freewallet
        accountsWithBalances = await createBip32Wallet(
          password: password,
          importFormat: ImportFormat.freewallet,
          mnemonic: mnemonic,
          wallet: wallet,
        );
      }

      if (accountsWithBalances.isEmpty) {
        throw Exception('invariant: no balances found');
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

    // Track accounts that have no balance; once the SKIP_LIMIT is reached, stop importing
    int skippedAccounts = 0;

    // Attempt to find balances/transactions for up to 20 accounts, checking only the first address for each horizon account
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
        importFormat: ImportFormat.horizon,
      );

      print("ADDRESS SEGWIT 0");
      print('time before segwit: ${DateTime.now()}');
      // derive single segwit address for horizon
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
      print('time after segwit: ${DateTime.now()}');

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
        // reset the skippedAddresses and skippedAccounts counter since we have just added an address
        skippedAccounts = 0;

        // capture the most recent account with balances
        print("ADDED ADDRESS 0 for account $i");

        // add the segwit address to the account if balances or transactions are present
        if (accountsWithBalances.containsKey(account)) {
          accountsWithBalances[account]!.add(address);
        } else {
          accountsWithBalances[account] = [address];
        }
      }

      // If we have not yet reached the skip limit,
      // if the current account has no balances, add to the skip limit
      if (skippedAccounts < SKIP_LIMIT &&
          (!accountsWithBalances.containsKey(account))) {
        print('skipping account $i');
        skippedAccounts++;
      }

      if (skippedAccounts >= SKIP_LIMIT) {
        break;
      }
    }

    return accountsWithBalances;
  }

  Future<Map<Account, List<Address>>> createBip32Wallet({
    required String password,
    required ImportFormat importFormat,
    required String mnemonic,
    required Wallet wallet,
  }) async {
    Map<Account, List<Address>> accountsWithBalances = {};
    print('creating wallet for import format $importFormat');

    String decryptedPrivKey;
    try {
      decryptedPrivKey =
          await encryptionService.decrypt(wallet.encryptedPrivKey, password);
    } catch (e) {
      throw PasswordException('invariant: Invalid password');
    }

    // for freewallet and counterwallet imports, always import the first 20 addresses
    Account firstAccount = Account(
      name: 'ACCOUNT 1',
      walletUuid: wallet.uuid,
      purpose: '0\'', // unused in Freewallet path
      coinType: _getCoinType(),
      accountIndex: '0\'',
      uuid: uuid.v4(),
      importFormat: importFormat,
    );

    List<Address> addressesBech32 =
        await addressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: firstAccount.uuid,
            account: firstAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    List<Address> addressesLegacy =
        await addressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: firstAccount.uuid,
            account: firstAccount.accountIndex,
            change: '0',
            start: 0,
            end: 9);

    accountsWithBalances[firstAccount] = [
      ...addressesBech32,
      ...addressesLegacy,
    ];

    // Track accounts that have no balance; once 3 accounts have been skipped, stop importing
    int skippedAccounts = 0;

    // Attempt to find balances/transactions for all subsequent accounts, up to 20 accounts, checking up to 20 addresses per account
    for (var i = 1; i < GAP_LIMIT; i++) {
      print("ACCOUNT $i");
      //  m/0'/0/0
      // create an account to house
      Account account = Account(
        name: 'ACCOUNT ${i + 1}',
        walletUuid: wallet.uuid,
        purpose: '0\'', // unused in Freewallet path
        coinType: _getCoinType(),
        accountIndex: '$i\'',
        uuid: uuid.v4(),
        importFormat: importFormat,
      );
      // Track addresses that have no balance; once 3 addresses have been skipped, stop importing
      int skippedAddresses = 0;

      for (var j = 0; j < GAP_LIMIT; j++) {
        if (j == 0) {
          // reset the skippedAddresses counter since we are starting a new account
          skippedAddresses = 0;
        }
        print('legacy addresses $j');
        print('time before legacy: ${DateTime.now()}');
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
        print('time after legacy: ${DateTime.now()}');

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

        Address addressSegwit = singleAddressSegwit[0];
        Address addressLegacy = singleAddressLegacy[0];

        // get transactions and balances for the segwit address
        final List<BitcoinTx> transactionsSegwit = await bitcoinRepository
            .getTransactions([addressSegwit.address]).then((either) async {
          return either.fold(
            (error) => throw Exception("GetTransactionInfo failure"),
            (transactions) => transactions,
          );
        });
        List<BitcoinTx> transactionsLegacy = await bitcoinRepository
            .getTransactions([addressLegacy.address]).then((either) async {
          return either.fold(
            (error) => throw Exception("GetTransactionInfo failure"),
            (transactions) => transactions,
          );
        });

        // if there are any transactions or balances for the segwit address or the legacy address, add the address to the account
        if (transactionsSegwit.isNotEmpty || transactionsLegacy.isNotEmpty) {
          // reset the skippedAddresses and skippedAccounts counter since we have just added an address
          skippedAddresses = 0;
          skippedAccounts = 0;

          // capture the most recent account with balances
          print("ADDED ADDRESS $j for account $i");

          // add the legacy address to the account if balances or transactions are present
          if (accountsWithBalances.containsKey(account)) {
            accountsWithBalances[account]!.add(addressLegacy);
          } else {
            accountsWithBalances[account] = [addressLegacy];
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
      }

      // once we have passed 3 accounts with no balances, break the loop and proceed with inserting wallet/accounts/addresses
      if (skippedAccounts >= SKIP_LIMIT) {
        break;
      }
    }

    return accountsWithBalances;
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
