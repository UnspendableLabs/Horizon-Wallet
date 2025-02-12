import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:horizon/common/constants.dart';
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
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletService extends Mock implements WalletService {}

class MockMnemonicService extends Mock implements MnemonicService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

class MockEventsRepository extends Mock implements EventsRepository {}

class MockConfig extends Mock implements Config {}

// Fake classes for fallback values
class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {}

void main() {
  late ImportWalletUseCase importWalletUseCase;
  late MockAddressRepository mockAddressRepository;
  late MockAccountRepository mockAccountRepository;
  late MockWalletRepository mockWalletRepository;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockInMemoryKeyRepository mockInMemoryKeyRepository;
  late MockBitcoinRepository mockBitcoinRepository;
  late MockMnemonicService mockMnemonicService;
  late MockEventsRepository mockEventsRepository;

  late MockConfig mockConfig;
  late MockWalletService mockWalletService;
  setUpAll(() {
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress());
    registerFallbackValue(FakeWallet());
    registerFallbackValue(AddressType.bech32);
    registerFallbackValue(AddressType.legacy);
  });

  setUp(() {
    mockAddressRepository = MockAddressRepository();
    mockAccountRepository = MockAccountRepository();
    mockWalletRepository = MockWalletRepository();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockConfig = MockConfig();
    mockWalletService = MockWalletService();
    mockInMemoryKeyRepository = MockInMemoryKeyRepository();
    mockEventsRepository = MockEventsRepository();

    mockBitcoinRepository = MockBitcoinRepository();
    mockMnemonicService = MockMnemonicService();
    importWalletUseCase = ImportWalletUseCase(
      inMemoryKeyRepository: mockInMemoryKeyRepository,
      addressRepository: mockAddressRepository,
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      config: mockConfig,
      walletService: mockWalletService,
      bitcoinRepository: mockBitcoinRepository,
      mnemonicService: mockMnemonicService,
      eventsRepository: mockEventsRepository,
    );
  });

  group('ImportWalletUseCase call', () {
    void runImportTest(String description, Network network,
        String expectedCoinType, WalletType walletType) {
      test(description, () async {
        final isFreewalletBip39 = description.contains('freewallet');

        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
        const horizonWallet = Wallet(
            name: "Horizon Wallet",
            uuid: 'horizon-wallet-uuid',
            publicKey: "horizon-public-key",
            encryptedPrivKey: 'horizon-encrypted',
            chainCodeHex: 'horizon-chainCode');

        const counterwallet = Wallet(
            name: "Counterwallet",
            uuid: 'counterwallet-uuid',
            publicKey: "counterwallet-public-key",
            encryptedPrivKey: 'counterwallet-encrypted',
            chainCodeHex: 'counterwallet-chainCode');

        const freewallet = Wallet(
            name: "Freewallet",
            uuid: 'freewallet-uuid',
            publicKey: "freewallet-public-key",
            encryptedPrivKey: 'freewallet-encrypted',
            chainCodeHex: 'freewallet-chainCode');

        const decryptedPrivKey = 'decrypted-private-key';
        const decryptionKey = "decryption-key";

        when(() => mockConfig.network).thenReturn(network);

        when(() => mockMnemonicService.validateMnemonic(any()))
            .thenReturn(true);
        when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
            .thenReturn(true);

        when(() => mockWalletService.deriveRoot(any(), any()))
            .thenAnswer((_) async => horizonWallet);
        when(() => mockWalletService.deriveRootFreewallet(any(), any()))
            .thenAnswer((_) async => freewallet);
        when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
            .thenAnswer((_) async => counterwallet);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => decryptedPrivKey);
        when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
            .thenAnswer((_) async {});
        when(() => mockEncryptionService.getDecryptionKey(any(), any()))
            .thenAnswer((_) async => 'test-decryption-key');

        final currentWallet = switch (walletType) {
          WalletType.horizon => horizonWallet,
          WalletType.bip32 => isFreewalletBip39 ? freewallet : counterwallet,
        };

        int getCurrentWalletCallCount = 0;
        when(() => mockWalletRepository.getCurrentWallet())
            .thenAnswer((_) async {
          getCurrentWalletCallCount++;
          if (getCurrentWalletCallCount == 1) {
            return null;
          }
          return currentWallet;
        });

        // Mock Bitcoin repository to return transactions only for first few addresses
        var callCount = 0;
        when(() => mockBitcoinRepository.getTransactions(any()))
            .thenAnswer((_) async {
          callCount++;
          if (isFreewalletBip39 && callCount == 1) {
            // for bip32 wallets, the first transaction call is for counterwallet
            // return an empty list to indicate that no transactions were found on the counterwallet and import should continue with freewallet
            return const Right([]);
          }
          // Return transactions only for first 3 addresses/accounts of the wallet
          if (callCount <= 3) {
            return Right([
              BitcoinTx(
                txid: 'test-tx-id',
                version: 1,
                locktime: 0,
                vin: [],
                vout: [],
                size: 100,
                weight: 400,
                fee: 1000,
                status: Status(
                  confirmed: true,
                  blockHeight: 100,
                  blockHash: 'test-block-hash',
                  blockTime: 1234567890,
                ),
              )
            ]);
          }
          return const Right([]); // Return empty list for subsequent calls
        });

        when(() => mockEventsRepository.numEventsForAddresses(
            addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

        when(() => mockAddressService.deriveAddressSegwit(
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                purpose: any(named: 'purpose'),
                coin: any(named: 'coin'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                index: any(named: 'index')))
            .thenAnswer((_) async => const Address(
                index: 0, address: "0xdeadbeef", accountUuid: 'account-uuid'));

        when(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end')))
            .thenAnswer((_) async => [
                  const Address(
                      index: 0, address: "bc1q...", accountUuid: 'account-uuid')
                ]);

        when(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end')))
            .thenAnswer((_) async => [
                  const Address(
                      index: 1, address: "1M...", accountUuid: 'account-uuid')
                ]);

        when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
        when(() => mockAccountRepository.insert(any()))
            .thenAnswer((_) async {});
        when(() => mockAddressRepository.insert(any()))
            .thenAnswer((_) async {});
        when(() => mockAddressRepository.insertMany(any()))
            .thenAnswer((_) async {});
        when(() => mockEncryptionService.getDecryptionKey(any(), any()))
            .thenAnswer((_) async => 'test-decryption-key');
        when(() => mockInMemoryKeyRepository.set(key: decryptionKey))
            .thenAnswer((_) async {});

        bool successCallbackInvoked = false;
        bool errorCallbackInvoked = false;

        // Act
        await importWalletUseCase.call(
          password: password,
          walletType: walletType,
          mnemonic: mnemonic,
          onError: (error) {
            errorCallbackInvoked = true;
          },
          onSuccess: () {
            successCallbackInvoked = true;
          },
        );

        verify(() => mockEncryptionService.decrypt(
            currentWallet.encryptedPrivKey, password)).called(1);

        // freewallet bip39: decrypt twice, once for counterwallet and once for freewallet
        if (isFreewalletBip39) {
          verify(() => mockEncryptionService.decrypt(
              counterwallet.encryptedPrivKey, password)).called(1);
        }

        switch (walletType) {
          case WalletType.horizon:
            verifyNever(
                () => mockMnemonicService.validateCounterwalletMnemonic(any()));
            verifyNever(() => mockMnemonicService.validateMnemonic(any()));
            verify(() => mockWalletService.deriveRoot(any(), any())).called(1);
            verifyNever(
                () => mockWalletService.deriveRootFreewallet(any(), any()));
            verifyNever(
                () => mockWalletService.deriveRootCounterwallet(any(), any()));
            verify(() => mockAddressService.deriveAddressSegwit(
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                purpose: '84\'',
                coin: expectedCoinType,
                account: any(named: 'account'),
                change: '0',
                index: any(named: 'index'))).called(4);
            verify(() => mockBitcoinRepository.getTransactions(any()))
                .called(4);
            verify(() => mockEventsRepository.numEventsForAddresses(
                addresses: any(named: 'addresses'))).called(4);
            verify(() => mockWalletRepository.insert(horizonWallet)).called(1);
            verify(() => mockAccountRepository.insert(any())).called(3);
            verify(() => mockAddressRepository.insertMany(any())).called(3);
            break;

          case WalletType.bip32:
            verify(() =>
                    mockMnemonicService.validateCounterwalletMnemonic(any()))
                .called(1);
            verify(() => mockMnemonicService.validateMnemonic(any())).called(1);
            verify(() =>
                    mockWalletService.deriveRootCounterwallet(any(), any()))
                .called(1);
            if (isFreewalletBip39) {
              verify(() => mockWalletService.deriveRootFreewallet(any(), any()))
                  .called(1);
            } else {
              verifyNever(
                  () => mockWalletService.deriveRootFreewallet(any(), any()));
            }
            verifyNever(() => mockWalletService.deriveRoot(any(), any()));
            verify(() => mockBitcoinRepository.getTransactions(any()))
                .called(4);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.bech32,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'))).called(4);
            verify(() => mockAddressService.deriveAddressFreewalletRange(
                type: AddressType.legacy,
                privKey: any(named: 'privKey'),
                chainCodeHex: any(named: 'chainCodeHex'),
                accountUuid: any(named: 'accountUuid'),
                account: any(named: 'account'),
                change: any(named: 'change'),
                start: any(named: 'start'),
                end: any(named: 'end'))).called(4);
            verify(() => mockEventsRepository.numEventsForAddresses(
                addresses: any(named: 'addresses'))).called(4);
            verify(() => mockWalletRepository.insert(
                isFreewalletBip39 ? freewallet : counterwallet)).called(1);

            // bip32: insert 2 accounts and 2 addresses for freewallet bip39 since only 2 accounts have transactions, 3 accounts and 3 addresses for counterwallet
            verify(() => mockAccountRepository.insert(any()))
                .called(isFreewalletBip39 ? 2 : 3);
            verify(() => mockAddressRepository.insertMany(any()))
                .called(isFreewalletBip39 ? 2 : 3);
            break;
        }

        verify(() => mockWalletRepository.getCurrentWallet()).called(2);

        verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
            .called(1);
        verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
            .called(1);

        expect(successCallbackInvoked, true);
        expect(errorCallbackInvoked, false);
      });

      test('error callback is invoked when an error occurs: $walletType',
          () async {
        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
        when(() => mockMnemonicService.validateMnemonic(any()))
            .thenReturn(true);
        when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
            .thenReturn(true);
        when(() => mockWalletService.deriveRoot(any(), any()))
            .thenThrow(Exception('error'));
        when(() => mockWalletService.deriveRootFreewallet(any(), any()))
            .thenThrow(Exception('error'));
        when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
            .thenThrow(Exception('error'));

        bool errorCallbackInvoked = false;
        bool successCallbackInvoked = false;

        // Act
        await importWalletUseCase.call(
          password: password,
          walletType: walletType,
          mnemonic: mnemonic,
          onError: (error) {
            errorCallbackInvoked = true;
          },
          onSuccess: () {
            successCallbackInvoked = true;
          },
        );

        switch (walletType) {
          case WalletType.horizon:
            verify(() => mockWalletService.deriveRoot(any(), any())).called(1);
            break;
          case WalletType.bip32:
            verify(() =>
                    mockWalletService.deriveRootCounterwallet(any(), any()))
                .called(1);
            break;
        }

        // Assert
        expect(errorCallbackInvoked, true);
        expect(successCallbackInvoked, false);
      });
    }

    // Run tests for all formats
    runImportTest(
        'emits correct states when importing wallet for mainnet using Horizon format',
        Network.mainnet,
        "0'",
        WalletType.horizon);
    runImportTest(
        'emits correct states when importing wallet for testnet using Horizon format',
        Network.testnet,
        "1'",
        WalletType.horizon);
    runImportTest(
        'emits correct states when importing wallet for regtest using Horizon format',
        Network.regtest,
        "1'",
        WalletType.horizon);

    runImportTest(
        'emits correct states when importing wallet for mainnet using BIP32 format',
        Network.mainnet,
        "0",
        WalletType.bip32);
    runImportTest(
        'emits correct states when importing wallet for testnet using BIP32 format',
        Network.testnet,
        "1",
        WalletType.bip32);
    runImportTest(
        'emits correct states when importing wallet for regtest using BIP32 format',
        Network.regtest,
        "1",
        WalletType.bip32);

    runImportTest(
        'freewallet bip39: emits correct states when importing wallet for mainnet using BIP32 format',
        Network.mainnet,
        "0",
        WalletType.bip32);
    runImportTest(
        'freewallet bip39: emits correct states when importing wallet for testnet using BIP32 format',
        Network.testnet,
        "1",
        WalletType.bip32);
    runImportTest(
        'freewallet bip39: emits correct states when importing wallet for regtest using BIP32 format',
        Network.regtest,
        "1",
        WalletType.bip32);

    test(
        'imports freewallet if txs are found on freewallet and counterwallet has no transactions',
        () async {
      // Setup
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';

      const counterwallet = Wallet(
          name: "Counterwallet",
          uuid: 'counter-wallet-uuid',
          publicKey: "counter-public-key",
          encryptedPrivKey: 'counter-encrypted',
          chainCodeHex: 'counter-chainCode');
      const freeWallet = Wallet(
          name: "Freewallet",
          uuid: 'free-wallet-uuid',
          publicKey: "free-public-key",
          encryptedPrivKey: 'free-encrypted',
          chainCodeHex: 'free-chainCode');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockMnemonicService.validateMnemonic(any()))
          .thenAnswer((_) => true);
      when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
          .thenAnswer((_) => true);
      when(() => mockConfig.network).thenReturn(Network.mainnet);

      // Mock Counterwallet derivation
      when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .thenAnswer((_) async => counterwallet);

      // Mock Freewallet derivation (used after Counterwallet fails)
      when(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .thenAnswer((_) async => freeWallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .thenAnswer((_) async => 'test-decryption-key');

      // Add mock for getCurrentWallet to return the freewallet (since that's what we end up using)
      int getCurrentWalletCallCount = 0;
      when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
        getCurrentWalletCallCount++;
        if (getCurrentWalletCallCount == 1) {
          return null;
        }
        return freeWallet;
      });
      // Mock address derivation for both types
      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 0, address: "bc1q...", accountUuid: 'account-uuid')
              ]);

      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 1, address: "1M...", accountUuid: 'account-uuid')
              ]);

      // Mock Bitcoin repository to return no transactions for Counterwallet addresses
      // but return transactions for Freewallet addresses
      var callCount = 0;
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // First call (Counterwallet addresses) - return empty
          return const Right([]);
        } else if (callCount == 2) {
          // Second call (Freewallet addresses) - return transactions
          return Right([
            BitcoinTx(
              txid: 'test-tx-id',
              version: 1,
              locktime: 0,
              vin: [],
              vout: [],
              size: 100,
              weight: 400,
              fee: 1000,
              status: Status(
                confirmed: true,
                blockHeight: 100,
                blockHash: 'test-block-hash',
                blockTime: 1234567890,
              ),
            )
          ]);
        } else if (callCount == 3) {
          // Third call (next account's addresses) - return empty to stop scanning
          return const Right([]);
        }
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});
      when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .thenAnswer((_) async {});

      bool successCallbackInvoked = false;
      bool errorCallbackInvoked = false;

      // Act
      await importWalletUseCase.call(
        password: password,
        walletType: WalletType.bip32,
        mnemonic: mnemonic,
        onError: (error) {
          errorCallbackInvoked = true;
        },
        onSuccess: () {
          successCallbackInvoked = true;
        },
      );

      // Verify
      verify(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .called(1);
      verify(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .called(1);
      verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(3);
      verify(() => mockWalletRepository.insert(freeWallet)).called(1);
      verify(() => mockAccountRepository.insert(any())).called(1);
      verify(() => mockAddressRepository.insertMany(any())).called(1);
      verify(() => mockWalletRepository.getCurrentWallet()).called(2);
      verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .called(1);
      verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .called(1);

      expect(successCallbackInvoked, true);
      expect(errorCallbackInvoked, false);
    });

    test(
        'imports counterwallet if no txs are found on counterwallet or freewallet',
        () async {
      // Setup
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';

      const counterwallet = Wallet(
          name: "Counterwallet",
          uuid: 'counter-wallet-uuid',
          publicKey: "counter-public-key",
          encryptedPrivKey: 'counter-encrypted',
          chainCodeHex: 'counter-chainCode');
      const freeWallet = Wallet(
          name: "Freewallet",
          uuid: 'free-wallet-uuid',
          publicKey: "free-public-key",
          encryptedPrivKey: 'free-encrypted',
          chainCodeHex: 'free-chainCode');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockMnemonicService.validateMnemonic(any()))
          .thenAnswer((_) => true);
      when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
          .thenAnswer((_) => true);
      when(() => mockConfig.network).thenReturn(Network.mainnet);

      // Mock Counterwallet derivation
      when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .thenAnswer((_) async => counterwallet);

      // Mock Freewallet derivation (used after Counterwallet fails)
      when(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .thenAnswer((_) async => freeWallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .thenAnswer((_) async => 'test-decryption-key');

      // Add mock for getCurrentWallet to return the freewallet (since that's what we end up using)
      int getCurrentWalletCallCount = 0;
      when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
        getCurrentWalletCallCount++;
        if (getCurrentWalletCallCount == 1) {
          return null;
        }
        return counterwallet;
      });
      // Mock address derivation for both types
      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 0, address: "bc1q...", accountUuid: 'account-uuid')
              ]);

      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 1, address: "1M...", accountUuid: 'account-uuid')
              ]);

      // Mock Bitcoin repository to return no transactions for Counterwallet addresses
      // but return transactions for Freewallet addresses
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});
      when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .thenAnswer((_) async {});

      bool successCallbackInvoked = false;
      bool errorCallbackInvoked = false;

      // Act
      await importWalletUseCase.call(
        password: password,
        walletType: WalletType.bip32,
        mnemonic: mnemonic,
        onError: (error) {
          errorCallbackInvoked = true;
        },
        onSuccess: () {
          successCallbackInvoked = true;
        },
      );

      // Verify
      verify(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .called(1);
      verify(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .called(1);
      verify(() => mockBitcoinRepository.getTransactions(any()))
          .called(2); // once for empty counterwallet, once for empty freewallet
      verify(() => mockWalletRepository.insert(counterwallet)).called(1);
      verify(() => mockAccountRepository.insert(any())).called(1);
      verify(() => mockAddressRepository.insertMany(any())).called(1);
      verify(() => mockWalletRepository.getCurrentWallet()).called(2);
      verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .called(1);
      verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .called(1);

      expect(successCallbackInvoked, true);
      expect(errorCallbackInvoked, false);
    });

    test('throws error when current wallet is not found', () async {
      // Setup
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';
      const wallet = Wallet(
          name: "Imported Wallet",
          uuid: 'import-wallet-uuid',
          publicKey: "imported-public-key",
          encryptedPrivKey: 'encrypted',
          chainCodeHex: 'chainCode');

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockWalletService.deriveRoot(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => 'decrypted');
      when(() => mockAddressService.deriveAddressSegwit(
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index')))
          .thenAnswer((_) async => const Address(
              index: 0, address: "0xdeadbeef", accountUuid: 'account-uuid'));
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async => const Right([]));
      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});

      // Mock getCurrentWallet to return null
      when(() => mockWalletRepository.getCurrentWallet())
          .thenAnswer((_) async => null);

      bool errorCallbackInvoked = false;
      String? errorMessage;

      // Act
      await importWalletUseCase.call(
        password: password,
        walletType: WalletType.horizon,
        mnemonic: mnemonic,
        onError: (error) {
          errorCallbackInvoked = true;
          errorMessage = error;
        },
        onSuccess: () {},
      );

      // Assert
      expect(errorCallbackInvoked, true);
      expect(errorMessage, 'An unexpected error occurred importing wallet');
      verify(() => mockWalletRepository.getCurrentWallet()).called(2);
      verifyNever(() => mockEncryptionService.getDecryptionKey(any(), any()));
      verifyNever(() => mockInMemoryKeyRepository.set(key: any(named: 'key')));
    });

    test('throws MultipleWalletsException when wallet already exists',
        () async {
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';

      const counterwallet = Wallet(
          name: "Counterwallet",
          uuid: 'counter-wallet-uuid',
          publicKey: "counter-public-key",
          encryptedPrivKey: 'counter-encrypted',
          chainCodeHex: 'counter-chainCode');
      const freewallet = Wallet(
          name: "Freewallet",
          uuid: 'free-wallet-uuid',
          publicKey: "free-public-key",
          encryptedPrivKey: 'free-encrypted',
          chainCodeHex: 'free-chainCode');
      const decryptedPrivKey = 'decrypted-private-key';

      // Change these from thenAnswer to thenReturn
      when(() => mockMnemonicService.validateMnemonic(any())).thenReturn(false);
      when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
          .thenReturn(true);
      when(() => mockConfig.network).thenReturn(Network.mainnet);

      // Mock Counterwallet derivation
      when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .thenAnswer((_) async => counterwallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .thenAnswer((_) async => 'test-decryption-key');

      // mock getCurrentWallet to return an existing freewallet, which is invalid
      when(() => mockWalletRepository.getCurrentWallet())
          .thenAnswer((_) async => freewallet);

      // Mock address derivation for both types
      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 0, address: "bc1q...", accountUuid: 'account-uuid')
              ]);

      when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end')))
          .thenAnswer((_) async => [
                const Address(
                    index: 1, address: "1M...", accountUuid: 'account-uuid')
              ]);

      // Mock Bitcoin repository to return no transactions for Counterwallet addresses
      // but return transactions for Freewallet addresses
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      bool successCallbackInvoked = false;

      bool errorCallbackInvoked = false;
      String? errorMessage;

      // Act
      await importWalletUseCase.call(
        password: password,
        walletType: WalletType.bip32,
        mnemonic: mnemonic,
        onError: (error) {
          errorCallbackInvoked = true;
          errorMessage = error;
        },
        onSuccess: () {
          successCallbackInvoked = true;
        },
      );

      // Assert
      expect(errorCallbackInvoked, true);
      expect(successCallbackInvoked, false);
      expect(errorMessage,
          'Something went wrong while opening your wallet. Please reach out to support@unspendablelabs.com or the Horizon Telegram channel https://t.me/horizonxcp for support.');
      verify(() => mockWalletRepository.getCurrentWallet()).called(1);
      verifyNever(() => mockWalletRepository.insert(any()));
      verifyNever(() => mockAccountRepository.insert(any()));
      verifyNever(() => mockAddressRepository.insertMany(any()));
    });

    test(
        'throws MultipleWalletsException when wallet already exists in callHorizon',
        () async {
      // Setup
      const mnemonic = 'test mnemonic';
      const password = 'test-password';
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockConfig.network).thenReturn(Network.testnet);

      // Mock deriveRoot to return the wallet
      when(() => mockWalletService.deriveRoot(any(), any()))
          .thenAnswer((_) async => wallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Add mock for getCurrentWallet
      when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
        return wallet;
      });

      when(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .thenAnswer((_) async => 'test-decryption-key');

      when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .thenAnswer((_) async {});

      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '1\'', // testnet
            account: '0\'',
            change: '0',
            index: 0,
          )).thenAnswer((_) async => const Address(
            index: 0,
            address: "tb1q_test_address",
            accountUuid: 'test-uuid',
          ));

      try {
        // Act
        await importWalletUseCase.callHorizon(
          password: password,
          mnemonic: mnemonic,
          deriveWallet: mockWalletService.deriveRoot,
        );
      } catch (e) {
        expect(e, isA<MultipleWalletsException>());
        expect((e as MultipleWalletsException).message,
            'Something went wrong while opening your wallet. Please reach out to support@unspendablelabs.com or the Horizon Telegram channel https://t.me/horizonxcp for support.');
      }

      // Assert

      verify(() => mockWalletRepository.getCurrentWallet()).called(1);
      verifyNever(() => mockWalletRepository.insert(any()));
      verifyNever(() => mockAccountRepository.insert(any()));
      verifyNever(() => mockAddressRepository.insert(any()));
    });
  });

  group('ImportWalletUseCase createHorizonWallet', () {
    test('creates accounts and addresses when transactions exist', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: any(named: 'purpose'),
            coin: any(named: 'coin'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            index: any(named: 'index'),
          )).thenAnswer((invocation) async => Address(
            index: 0,
            address:
                "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
            accountUuid: invocation.namedArguments[const Symbol('accountUuid')]
                as String,
          ));

      var callCount = 0;
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        callCount++;
        // Return transactions for first 3 accounts
        if (callCount <= 3) {
          return Right([
            BitcoinTx(
              txid: 'test-tx-id-$callCount',
              version: 1,
              locktime: 0,
              vin: [],
              vout: [],
              size: 100,
              weight: 400,
              fee: 1000,
              status: Status(
                confirmed: true,
                blockHeight: 100,
                blockHash: 'test-block-hash',
                blockTime: 1234567890,
              ),
            )
          ]);
        }
        // Return empty list for 4th account to stop scanning
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final accountsWithBalances =
          await importWalletUseCase.createHorizonWallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
      );

      // Assert
      expect(accountsWithBalances.length,
          3); // Should have 3 accounts with transactions

      // Verify each account
      var accounts = accountsWithBalances.keys.toList();
      for (var i = 0; i < accounts.length; i++) {
        expect(accounts[i].walletUuid, equals(wallet.uuid));
        expect(accounts[i].purpose, equals('84\''));
        expect(accounts[i].coinType, equals('0\''));
        expect(accounts[i].accountIndex, equals('$i\''));
        expect(accounts[i].importFormat, equals(ImportFormat.horizon));

        // Each account should have one segwit address
        var addresses = accountsWithBalances[accounts[i]]!;
        expect(addresses.length, 1);
        expect(addresses.first.address.startsWith('bc1q'), true);
        expect(addresses.first.accountUuid, equals(accounts[i].uuid));
      }

      // Verify number of calls
      verify(() => mockBitcoinRepository.getTransactions(any())).called(4);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(4);
      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);
    });

    test('creates single account when first account has no transactions',
        () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: any(named: 'purpose'),
            coin: any(named: 'coin'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            index: any(named: 'index'),
          )).thenAnswer((invocation) async => Address(
            index: 0,
            address:
                "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
            accountUuid: invocation.namedArguments[const Symbol('accountUuid')]
                as String,
          ));

      // Mock no transactions for any account
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async => const Right([]));
      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final accountsWithBalances =
          await importWalletUseCase.createHorizonWallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
      );

      // Assert
      expect(accountsWithBalances.length, 1); // Should have only first account

      // Verify first account structure
      var firstAccount = accountsWithBalances.keys.first;
      expect(firstAccount.walletUuid, equals(wallet.uuid));
      expect(firstAccount.purpose, equals('84\''));
      expect(firstAccount.coinType, equals('0\''));
      expect(firstAccount.accountIndex, equals('0\''));
      expect(firstAccount.importFormat, equals(ImportFormat.horizon));

      // Verify first account address
      var addresses = accountsWithBalances[firstAccount]!;
      expect(addresses.length, 1);
      expect(addresses.first.address.startsWith('bc1q'), true);
      expect(addresses.first.accountUuid, equals(firstAccount.uuid));

      // Verify we only called getTransactions once
      verify(() => mockBitcoinRepository.getTransactions(any())).called(1);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(1);
      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);
    });

    test('throws PasswordException for invalid password', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const password = 'wrong-password';
      const mnemonic = 'test mnemonic';

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenThrow(Exception('Decryption failed'));

      // Act & Assert
      expect(
        () => importWalletUseCase.createHorizonWallet(
          password: password,
          mnemonic: mnemonic,
          wallet: wallet,
        ),
        throwsA(isA<PasswordException>().having(
            (e) => e.message, 'message', 'invariant: Invalid password')),
      );

      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);
    });

    test('handles testnet network type correctly', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.testnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: any(named: 'purpose'),
            coin: any(named: 'coin'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            index: any(named: 'index'),
          )).thenAnswer((invocation) async => Address(
            index: 0,
            address: "tb1q_test_address",
            accountUuid: invocation.namedArguments[const Symbol('accountUuid')]
                as String,
          ));

      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async => const Right([]));

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final accountsWithBalances =
          await importWalletUseCase.createHorizonWallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
      );

      // Assert
      var firstAccount = accountsWithBalances.keys.first;
      expect(
          firstAccount.coinType, equals('1\'')); // Should use testnet coin type

      verify(() => mockAddressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '1\'', // Should use testnet coin type
            account: '0\'',
            change: '0',
            index: 0,
          )).called(1);
    });
  });

  group('ImportWalletUseCase createBip32Wallet Counterwallet', () {
    test('creates account and addresses when transactions exist', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Mock address derivation for both types
      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((invocation) async => [
            Address(
              index: 0,
              address:
                  "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
              accountUuid: invocation
                  .namedArguments[const Symbol('accountUuid')] as String,
            )
          ]);

      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((invocation) async => [
            Address(
              index: 1,
              address:
                  "1_test_address_${invocation.namedArguments[const Symbol('account')]}",
              accountUuid: invocation
                  .namedArguments[const Symbol('accountUuid')] as String,
            )
          ]);

      var callCount = 0;
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        callCount++;
        // Return transactions for first 2 accounts
        if (callCount <= 2) {
          return Right([
            BitcoinTx(
              txid: 'test-tx-id-$callCount',
              version: 1,
              locktime: 0,
              vin: [],
              vout: [],
              size: 100,
              weight: 400,
              fee: 1000,
              status: Status(
                confirmed: true,
                blockHeight: 100,
                blockHash: 'test-block-hash',
                blockTime: 1234567890,
              ),
            )
          ]);
        }
        // Return empty list for 3rd account to stop scanning
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final (accountsWithBalances, hasTransactions) =
          await importWalletUseCase.createBip32Wallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
        importFormat: ImportFormat.counterwallet,
      );

      // Assert
      expect(hasTransactions, true);
      expect(accountsWithBalances.length,
          2); // Should have 2 accounts with transactions

      // Verify each account
      var accounts = accountsWithBalances.keys.toList();
      for (var i = 0; i < accounts.length; i++) {
        expect(accounts[i].walletUuid, equals(wallet.uuid));
        expect(accounts[i].purpose, equals('0\''));
        expect(accounts[i].coinType, equals('0'));
        expect(accounts[i].accountIndex, equals('$i\''));
        expect(accounts[i].importFormat, equals(ImportFormat.counterwallet));

        // Each account should have both legacy and bech32 addresses
        var addresses = accountsWithBalances[accounts[i]]!;
        expect(addresses.length, 2);
        expect(addresses.any((addr) => addr.address.startsWith('bc1q')), true);
        expect(addresses.any((addr) => addr.address.startsWith('1')), true);
      }

      // Verify number of calls
      verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(3);
    });

    test('returns single account map when no transactions exist', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Mock address derivation (simplified for this test case)
      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: any(named: 'type'),
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((_) async => [
            const Address(
              index: 0,
              address: "test_address",
              accountUuid: "test_account_uuid",
            )
          ]);

      // Mock no transactions
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async => const Right([]));

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final (accountsWithBalances, hasTransactions) =
          await importWalletUseCase.createBip32Wallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
        importFormat: ImportFormat.counterwallet,
      );

      // Assert
      expect(hasTransactions, false);
      expect(
          accountsWithBalances.length, 1); // Should have just the first account

      // Verify first account structure
      var firstAccount = accountsWithBalances.keys.first;
      expect(firstAccount.walletUuid, equals(wallet.uuid));
      expect(firstAccount.purpose, equals('0\''));
      expect(firstAccount.coinType, equals('0'));
      expect(firstAccount.accountIndex, equals('0\''));
      expect(firstAccount.importFormat, equals(ImportFormat.counterwallet));

      // Verify we only called getTransactions once
      verify(() => mockBitcoinRepository.getTransactions(any())).called(1);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(1);
    });

    test('throws PasswordException for invalid password', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const password = 'wrong-password';
      const mnemonic = 'test mnemonic';

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenThrow(Exception('Decryption failed'));

      // Act & Assert
      expect(
        () => importWalletUseCase.createBip32Wallet(
          password: password,
          mnemonic: mnemonic,
          wallet: wallet,
          importFormat: ImportFormat.counterwallet,
        ),
        throwsA(isA<PasswordException>().having(
            (e) => e.message, 'message', 'invariant: Invalid password')),
      );

      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);
    });
  });

  group('ImportWalletUseCase createBip32Wallet Freewallet', () {
    test('creates accounts and addresses when transactions exist', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Mock address derivation for both types
      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((invocation) async => [
            Address(
              index: 0,
              address:
                  "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
              accountUuid: invocation
                  .namedArguments[const Symbol('accountUuid')] as String,
            )
          ]);

      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((invocation) async => [
            Address(
              index: 1,
              address:
                  "1_test_address_${invocation.namedArguments[const Symbol('account')]}",
              accountUuid: invocation
                  .namedArguments[const Symbol('accountUuid')] as String,
            )
          ]);

      var callCount = 0;
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async {
        callCount++;
        // Return transactions for first 2 accounts
        if (callCount <= 2) {
          return Right([
            BitcoinTx(
              txid: 'test-tx-id-$callCount',
              version: 1,
              locktime: 0,
              vin: [],
              vout: [],
              size: 100,
              weight: 400,
              fee: 1000,
              status: Status(
                confirmed: true,
                blockHeight: 100,
                blockHash: 'test-block-hash',
                blockTime: 1234567890,
              ),
            )
          ]);
        }
        // Return empty list for subsequent accounts
        return const Right([]);
      });

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final (accountsWithBalances, hasTransactions) =
          await importWalletUseCase.createBip32Wallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
        importFormat: ImportFormat.freewallet,
      );

      // Assert
      expect(hasTransactions, true);
      expect(accountsWithBalances.length,
          2); // Should have 2 accounts with transactions

      // Verify each account
      var accounts = accountsWithBalances.keys.toList();
      for (var i = 0; i < accounts.length; i++) {
        expect(accounts[i].walletUuid, equals(wallet.uuid));
        expect(accounts[i].purpose, equals('32')); // Freewallet uses purpose 32
        expect(accounts[i].coinType, equals('0')); // mainnet
        expect(accounts[i].accountIndex, equals('$i\''));
        expect(accounts[i].importFormat, equals(ImportFormat.freewallet));

        // Each account should have both legacy and bech32 addresses
        var addresses = accountsWithBalances[accounts[i]]!;
        expect(addresses.length, 2);
        expect(addresses.any((addr) => addr.address.startsWith('bc1q')), true);
        expect(addresses.any((addr) => addr.address.startsWith('1')), true);
      }

      // Verify number of calls
      verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(3);
    });

    test('returns single account map when no transactions exist', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';
      const password = 'test-password';
      const mnemonic = 'test mnemonic';

      when(() => mockConfig.network).thenReturn(Network.mainnet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Mock address derivation (simplified for this test case)
      when(() => mockAddressService.deriveAddressFreewalletRange(
            type: any(named: 'type'),
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'),
          )).thenAnswer((_) async => [
            const Address(
              index: 0,
              address: "test_address",
              accountUuid: "test_account_uuid",
            )
          ]);

      // Mock no transactions
      when(() => mockBitcoinRepository.getTransactions(any()))
          .thenAnswer((_) async => const Right([]));

      when(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

      // Act
      final (accountsWithBalances, hasTransactions) =
          await importWalletUseCase.createBip32Wallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
        importFormat: ImportFormat.freewallet,
      );

      // Assert
      expect(hasTransactions, false);
      expect(
          accountsWithBalances.length, 1); // Should have just the first account

      // Verify first account structure
      var firstAccount = accountsWithBalances.keys.first;
      expect(firstAccount.walletUuid, equals(wallet.uuid));
      expect(firstAccount.purpose, equals('32'));
      expect(firstAccount.coinType, equals('0'));
      expect(firstAccount.accountIndex, equals('0\''));
      expect(firstAccount.importFormat, equals(ImportFormat.freewallet));

      // Verify we only called getTransactions once
      verify(() => mockBitcoinRepository.getTransactions(any())).called(1);
      verify(() => mockEventsRepository.numEventsForAddresses(
          addresses: any(named: 'addresses'))).called(1);
    });

    test('throws PasswordException for invalid password', () async {
      // Setup
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-wallet-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const password = 'wrong-password';
      const mnemonic = 'test mnemonic';

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenThrow(Exception('Decryption failed'));

      // Act & Assert
      expect(
        () => importWalletUseCase.createBip32Wallet(
          password: password,
          mnemonic: mnemonic,
          wallet: wallet,
          importFormat: ImportFormat.freewallet,
        ),
        throwsA(isA<PasswordException>().having(
            (e) => e.message, 'message', 'invariant: Invalid password')),
      );

      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);
    });
  });

  test('creates only counterwallet when mnemonic is not valid BIP39', () async {
    const mnemonic = 'invalid bip39 mnemonic';
    const password = 'test-password';
    const counterwallet = Wallet(
        name: "Counterwallet",
        uuid: 'counter-wallet-uuid',
        publicKey: "counter-public-key",
        encryptedPrivKey: 'counter-encrypted',
        chainCodeHex: 'counter-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockMnemonicService.validateMnemonic(any()))
        .thenAnswer((_) => false);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenAnswer((_) => true);
    when(() => mockConfig.network).thenReturn(Network.mainnet);

    // Mock Counterwallet derivation
    when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
        .thenAnswer((_) async => counterwallet);

    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Add mock for getCurrentWallet to return the freewallet (since that's what we end up using)
    int callCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return null;
      }
      return counterwallet;
    });
    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end')))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() =>
        mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'))).thenAnswer((_) async => [
          const Address(index: 1, address: "1M...", accountUuid: 'account-uuid')
        ]);

    // Mock Bitcoin repository to return no transactions for Counterwallet addresses
    // but return transactions for Freewallet addresses
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async {
      return const Right([]);
    });

    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});
    when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
        .thenAnswer((_) async {});

    // ACT
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockWalletService.deriveRootCounterwallet(mnemonic, password))
        .called(1);
    verifyNever(() => mockWalletService.deriveRootFreewallet(any(), any()));

    verify(() => mockWalletRepository.insert(counterwallet)).called(1);
  });

  test('creates only freewallet when mnemonic is not valid counterwallet',
      () async {
    // Setup
    const mnemonic = 'invalid legacy mnemonic';
    const password = 'test-password';
    const freewallet = Wallet(
        name: "Freewallet",
        uuid: 'free-wallet-uuid',
        publicKey: "free-public-key",
        encryptedPrivKey: 'free-encrypted',
        chainCodeHex: 'free-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockMnemonicService.validateMnemonic(any()))
        .thenAnswer((_) => true);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenAnswer((_) => false);
    when(() => mockConfig.network).thenReturn(Network.mainnet);

    // Mock Counterwallet derivation
    when(() => mockWalletService.deriveRootFreewallet(any(), any()))
        .thenAnswer((_) async => freewallet);

    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Add mock for getCurrentWallet to return the freewallet (since that's what we end up using)
    int callCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return null;
      }
      return freewallet;
    });
    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.bech32,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end')))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() =>
        mockAddressService.deriveAddressFreewalletRange(
            type: AddressType.legacy,
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            account: any(named: 'account'),
            change: any(named: 'change'),
            start: any(named: 'start'),
            end: any(named: 'end'))).thenAnswer((_) async => [
          const Address(index: 1, address: "1M...", accountUuid: 'account-uuid')
        ]);

    // Mock Bitcoin repository to return no transactions for Counterwallet addresses
    // but return transactions for Freewallet addresses
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async {
      return const Right([]);
    });

    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async => 0);

    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});
    when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockWalletService.deriveRootFreewallet(mnemonic, password))
        .called(1);
    verifyNever(() => mockWalletService.deriveRootCounterwallet(any(), any()));
    verify(() => mockWalletRepository.insert(freewallet)).called(1);
  });

  group('ImportWalletUseCase callHorizon', () {
    test('successfully creates a horizon wallet', () async {
      // Setup
      const mnemonic = 'test mnemonic';
      const password = 'test-password';
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockConfig.network).thenReturn(Network.testnet);

      // Mock deriveRoot to return the wallet
      when(() => mockWalletService.deriveRoot(any(), any()))
          .thenAnswer((_) async => wallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);

      // Add mock for getCurrentWallet
      int callCount = 0;
      when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          return null;
        }
        return wallet;
      });

      when(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .thenAnswer((_) async => 'test-decryption-key');

      when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .thenAnswer((_) async {});

      when(() => mockAddressService.deriveAddressSegwit(
            privKey: any(named: 'privKey'),
            chainCodeHex: any(named: 'chainCodeHex'),
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '1\'', // testnet
            account: '0\'',
            change: '0',
            index: 0,
          )).thenAnswer((_) async => const Address(
            index: 0,
            address: "tb1q_test_address",
            accountUuid: 'test-uuid',
          ));

      // Add these mock responses
      when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any())).thenAnswer((_) async {});

      // Capture the account that will be inserted
      Account? capturedAccount;
      when(() => mockAccountRepository.insert(any()))
          .thenAnswer((invocation) async {
        capturedAccount = invocation.positionalArguments.first as Account;
      });

      // Act
      await importWalletUseCase.callHorizon(
        mnemonic: mnemonic,
        password: password,
        deriveWallet: mockWalletService.deriveRoot,
      );

      // Verify
      verify(() => mockWalletRepository.insert(wallet)).called(1);

      // Verify account properties using the captured account
      expect(capturedAccount, isNotNull);
      expect(capturedAccount?.purpose, equals('84\''));
      expect(capturedAccount?.coinType, equals('1\'')); // testnet
      expect(capturedAccount?.accountIndex, equals('0\''));
      expect(capturedAccount?.importFormat, equals(ImportFormat.horizon));

      verify(() => mockAddressRepository.insert(any())).called(1);

      verify(() => mockWalletRepository.getCurrentWallet()).called(2);
      verify(() => mockEncryptionService.getDecryptionKey(
          wallet.encryptedPrivKey, password)).called(1);
      verify(() => mockInMemoryKeyRepository.set(key: 'test-decryption-key'))
          .called(1);
    });

    test('throws PasswordException on decrypt failure', () async {
      // Setup
      const mnemonic = 'test mnemonic';
      const password = 'wrong-password';
      const wallet = Wallet(
          name: "Test Wallet",
          uuid: 'test-uuid',
          publicKey: "test-public-key",
          encryptedPrivKey: 'encrypted-key',
          chainCodeHex: 'test-chain-code');

      Future<Wallet> deriveWallet(String m, String p) async => wallet;

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenThrow(Exception('Decrypt failed'));

      // Act & Assert
      expect(
        () => importWalletUseCase.callHorizon(
          mnemonic: mnemonic,
          password: password,
          deriveWallet: deriveWallet,
        ),
        throwsA(isA<PasswordException>().having(
            (e) => e.message, 'message', 'invariant: Invalid password')),
      );

      // Verify no repositories were called
      verifyNever(() => mockWalletRepository.insert(any()));
      verifyNever(() => mockAccountRepository.insert(any()));
      verifyNever(() => mockAddressRepository.insert(any()));
    });
  });

  test(
      'imports horizon wallet with multiple accounts when only counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Test Wallet",
        uuid: 'test-wallet-uuid',
        publicKey: "test-public-key",
        encryptedPrivKey: 'encrypted-key',
        chainCodeHex: 'test-chain-code');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockWalletService.deriveRoot(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);

    // Mock getCurrentWallet
    int getCurrentWalletCallCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      getCurrentWalletCallCount++;
      if (getCurrentWalletCallCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
        .thenAnswer((_) async {});

    // Mock address derivation
    when(() => mockAddressService.deriveAddressSegwit(
          privKey: any(named: 'privKey'),
          chainCodeHex: any(named: 'chainCodeHex'),
          accountUuid: any(named: 'accountUuid'),
          purpose: any(named: 'purpose'),
          coin: any(named: 'coin'),
          account: any(named: 'account'),
          change: any(named: 'change'),
          index: any(named: 'index'),
        )).thenAnswer((invocation) async => Address(
          index: 0,
          address:
              "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
          accountUuid:
              invocation.namedArguments[const Symbol('accountUuid')] as String,
        ));

    // Mock no bitcoin transactions but have counterparty transactions for first 3 accounts
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async => const Right([]));

    var callCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      callCount++;
      // Return 1 counterparty event for first 3 accounts, 0 for the 4th
      if (callCount <= 3) {
        return 1;
      }
      return 0;
    });

    // Mock repository inserts
    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.horizon,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(4);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(4);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(3); // Should create 3 accounts
    verify(() => mockAddressRepository.insertMany(any()))
        .called(3); // Should create 3 addresses
  });

  test(
      'imports counterwallet with multiple accounts when only counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Counterwallet",
        uuid: 'counterwallet-uuid',
        publicKey: "counterwallet-public-key",
        encryptedPrivKey: 'counterwallet-encrypted',
        chainCodeHex: 'counterwallet-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockMnemonicService.validateMnemonic(any())).thenReturn(true);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenReturn(true);
    when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);

    // Mock getCurrentWallet
    int getCurrentWalletCallCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      getCurrentWalletCallCount++;
      if (getCurrentWalletCallCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 1, address: "1...", accountUuid: 'account-uuid')
            ]);

    // Mock no bitcoin transactions but have counterparty transactions for first 2 accounts
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async => const Right([]));

    var callCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      callCount++;
      // Return 1 counterparty event for first 2 accounts, 0 for the 3rd
      if (callCount <= 2) {
        return 1;
      }
      return 0;
    });

    // Mock repository inserts
    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(3);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(2); // Should create 2 accounts
    verify(() => mockAddressRepository.insertMany(any()))
        .called(2); // Should create addresses for 2 accounts
  });

  test(
      'imports freewallet with multiple accounts when only counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Freewallet",
        uuid: 'freewallet-uuid',
        publicKey: "freewallet-public-key",
        encryptedPrivKey: 'freewallet-encrypted',
        chainCodeHex: 'freewallet-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockMnemonicService.validateMnemonic(any())).thenReturn(true);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenReturn(false);
    when(() => mockWalletService.deriveRootFreewallet(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);

    // Mock getCurrentWallet
    int getCurrentWalletCallCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      getCurrentWalletCallCount++;
      if (getCurrentWalletCallCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 1, address: "1...", accountUuid: 'account-uuid')
            ]);

    // Mock no bitcoin transactions but have counterparty transactions for first 2 accounts
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async => const Right([]));

    var callCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      callCount++;
      // Return 1 counterparty event for first 2 accounts, 0 for the 3rd
      if (callCount <= 2) {
        return 1;
      }
      return 0;
    });

    // Mock repository inserts
    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(3);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(2); // Should create 2 accounts
    verify(() => mockAddressRepository.insertMany(any()))
        .called(2); // Should create addresses for 2 accounts
  });

  // Add these new tests after the existing tests, just before the final closing brace

  test(
      'imports horizon wallet when both bitcoin and counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Test Wallet",
        uuid: 'test-wallet-uuid',
        publicKey: "test-public-key",
        encryptedPrivKey: 'encrypted-key',
        chainCodeHex: 'test-chain-code');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockWalletService.deriveRoot(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);
    int callCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');
    when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
        .thenAnswer((_) async {});

    // Mock address derivation
    when(() => mockAddressService.deriveAddressSegwit(
          privKey: any(named: 'privKey'),
          chainCodeHex: any(named: 'chainCodeHex'),
          accountUuid: any(named: 'accountUuid'),
          purpose: any(named: 'purpose'),
          coin: any(named: 'coin'),
          account: any(named: 'account'),
          change: any(named: 'change'),
          index: any(named: 'index'),
        )).thenAnswer((invocation) async => Address(
          index: 0,
          address:
              "bc1q_test_address_${invocation.namedArguments[const Symbol('account')]}",
          accountUuid:
              invocation.namedArguments[const Symbol('accountUuid')] as String,
        ));

    // Mock bitcoin transactions for accounts 0-1, counterparty transactions for accounts 1-2
    var btcCallCount = 0;
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async {
      btcCallCount++;
      if (btcCallCount <= 2) {
        return Right([
          BitcoinTx(
            txid: 'test-tx-id',
            version: 1,
            locktime: 0,
            vin: [],
            vout: [],
            size: 100,
            weight: 400,
            fee: 1000,
            status: Status(
              confirmed: true,
              blockHeight: 100,
              blockHash: 'test-block-hash',
              blockTime: 1234567890,
            ),
          )
        ]);
      }
      return const Right([]);
    });

    var xcpCallCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      xcpCallCount++;
      // Return 1 counterparty event for accounts 1-2, 0 for others
      if (xcpCallCount == 2 || xcpCallCount == 3) {
        return 1;
      }
      return 0;
    });

    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.horizon,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(4);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(4);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(3); // Should create 3 accounts (0,1,2)
    verify(() => mockAddressRepository.insertMany(any()))
        .called(3); // Should create 3 addresses
  });

  test(
      'imports counterwallet when both bitcoin and counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Counterwallet",
        uuid: 'counterwallet-uuid',
        publicKey: "counterwallet-public-key",
        encryptedPrivKey: 'counterwallet-encrypted',
        chainCodeHex: 'counterwallet-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockMnemonicService.validateMnemonic(any())).thenReturn(true);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenReturn(true);
    when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);
    int callCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 1, address: "1...", accountUuid: 'account-uuid')
            ]);

    // Mock bitcoin transactions for account 0, counterparty transactions for accounts 0-1
    var btcCallCount = 0;
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async {
      btcCallCount++;
      if (btcCallCount == 1) {
        return Right([
          BitcoinTx(
            txid: 'test-tx-id',
            version: 1,
            locktime: 0,
            vin: [],
            vout: [],
            size: 100,
            weight: 400,
            fee: 1000,
            status: Status(
              confirmed: true,
              blockHeight: 100,
              blockHash: 'test-block-hash',
              blockTime: 1234567890,
            ),
          )
        ]);
      }
      return const Right([]);
    });

    var xcpCallCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      xcpCallCount++;
      // Return 1 counterparty event for first 2 accounts, 0 for the 3rd
      if (xcpCallCount <= 2) {
        return 1;
      }
      return 0;
    });

    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(3);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(3);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(2); // Should create 2 accounts (0,1)
    verify(() => mockAddressRepository.insertMany(any()))
        .called(2); // Should create addresses for 2 accounts
  });

  test(
      'imports freewallet when both bitcoin and counterparty transactions exist',
      () async {
    // Setup
    const mnemonic = 'test mnemonic';
    const password = 'test-password';
    const wallet = Wallet(
        name: "Freewallet",
        uuid: 'freewallet-uuid',
        publicKey: "freewallet-public-key",
        encryptedPrivKey: 'freewallet-encrypted',
        chainCodeHex: 'freewallet-chainCode');
    const decryptedPrivKey = 'decrypted-private-key';

    when(() => mockConfig.network).thenReturn(Network.mainnet);
    when(() => mockMnemonicService.validateMnemonic(any())).thenReturn(true);
    when(() => mockMnemonicService.validateCounterwalletMnemonic(any()))
        .thenReturn(false);
    when(() => mockWalletService.deriveRootFreewallet(any(), any()))
        .thenAnswer((_) async => wallet);
    when(() => mockEncryptionService.decrypt(any(), any()))
        .thenAnswer((_) async => decryptedPrivKey);
    int callCount = 0;
    when(() => mockWalletRepository.getCurrentWallet()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return null;
      }
      return wallet;
    });
    when(() => mockEncryptionService.getDecryptionKey(any(), any()))
        .thenAnswer((_) async => 'test-decryption-key');

    // Mock address derivation for both types
    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 0, address: "bc1q...", accountUuid: 'account-uuid')
            ]);

    when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            ))
        .thenAnswer((_) async => [
              const Address(
                  index: 1, address: "1...", accountUuid: 'account-uuid')
            ]);

    // Mock bitcoin transactions for accounts 0-1, counterparty transactions for accounts 1-2
    var btcCallCount = 0;
    when(() => mockBitcoinRepository.getTransactions(any()))
        .thenAnswer((_) async {
      btcCallCount++;
      if (btcCallCount <= 2) {
        return Right([
          BitcoinTx(
            txid: 'test-tx-id',
            version: 1,
            locktime: 0,
            vin: [],
            vout: [],
            size: 100,
            weight: 400,
            fee: 1000,
            status: Status(
              confirmed: true,
              blockHeight: 100,
              blockHash: 'test-block-hash',
              blockTime: 1234567890,
            ),
          )
        ]);
      }
      return const Right([]);
    });

    var xcpCallCount = 0;
    when(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).thenAnswer((_) async {
      xcpCallCount++;
      // Return 1 counterparty event for accounts 1-2, 0 for others
      if (xcpCallCount == 2 || xcpCallCount == 3) {
        return 1;
      }
      return 0;
    });

    when(() => mockWalletRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
    when(() => mockAddressRepository.insertMany(any()))
        .thenAnswer((_) async {});

    // Act
    await importWalletUseCase.call(
      password: password,
      walletType: WalletType.bip32,
      mnemonic: mnemonic,
      onError: (_) {},
      onSuccess: () {},
    );

    // Verify
    verify(() => mockBitcoinRepository.getTransactions(any())).called(4);
    verify(() => mockEventsRepository.numEventsForAddresses(
        addresses: any(named: 'addresses'))).called(4);
    verify(() => mockWalletRepository.insert(wallet)).called(1);
    verify(() => mockAccountRepository.insert(any()))
        .called(3); // Should create 3 accounts (0,1,2)
    verify(() => mockAddressRepository.insertMany(any()))
        .called(3); // Should create addresses for 3 accounts
  });
}
