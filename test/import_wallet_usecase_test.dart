import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
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
import 'package:horizon/presentation/common/usecase/import_wallet_usecase.dart';
import 'package:horizon/presentation/screens/onboarding/view/import_format_dropdown.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletService extends Mock implements WalletService {}

class MockMnemonicService extends Mock implements MnemonicService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

class MockAddressTxRepository extends Mock implements AddressTxRepository {}

class MockBalanceRepository extends Mock implements BalanceRepository {}

class MockBitcoinRepository extends Mock implements BitcoinRepository {}

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
  late MockAddressTxRepository mockAddressTxRepository;
  late MockBalanceRepository mockBalanceRepository;
  late MockBitcoinRepository mockBitcoinRepository;

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
    mockAddressTxRepository = MockAddressTxRepository();
    mockBalanceRepository = MockBalanceRepository();
    mockBitcoinRepository = MockBitcoinRepository();

    importWalletUseCase = ImportWalletUseCase(
      addressRepository: mockAddressRepository,
      accountRepository: mockAccountRepository,
      walletRepository: mockWalletRepository,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      config: mockConfig,
      inMemoryKeyRepository: mockInMemoryKeyRepository,
      walletService: mockWalletService,
      addressTxRepository: mockAddressTxRepository,
      balanceRepository: mockBalanceRepository,
      bitcoinRepository: mockBitcoinRepository,
    );
  });

  group('ImportWalletUseCase call', () {
    void runImportTest(String description, Network network,
        String expectedCoinType, WalletType walletType) {
      test(description, () async {
        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
        const wallet = Wallet(
            name: "Imported Wallet",
            uuid: 'import-wallet-uuid',
            publicKey: "imported-public-key",
            encryptedPrivKey: 'encrypted',
            chainCodeHex: 'chainCode');
        const decryptedPrivKey = 'decrypted-private-key';

        when(() => mockConfig.network).thenReturn(network);
        when(() => mockWalletService.deriveRoot(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockWalletService.deriveRootFreewallet(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
            .thenAnswer((_) async => wallet);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => decryptedPrivKey);
        when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
            .thenAnswer((_) async {});
        when(() => mockEncryptionService.getDecryptionKey(any(), any()))
            .thenAnswer((_) async => 'test-decryption-key');

        // Mock Bitcoin repository to return transactions only for first few addresses
        var callCount = 0;
        when(() => mockBitcoinRepository.getTransactions(any()))
            .thenAnswer((_) async {
          callCount++;
          // Return transactions only for first 3 addresses/accounts
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
        when(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
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
            wallet.encryptedPrivKey, password)).called(1);

        switch (walletType) {
          case WalletType.horizon:
            verify(() => mockWalletService.deriveRoot(any(), any())).called(1);
            verify(() => mockBitcoinRepository.getTransactions(any()))
                .called(4);
            verify(() => mockWalletRepository.insert(any())).called(1);
            verify(() => mockAccountRepository.insert(any())).called(3);
            verify(() => mockAddressRepository.insertMany(any())).called(3);
            verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
                .called(1);
            verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
                .called(1);
            expect(successCallbackInvoked, true);
            expect(errorCallbackInvoked, false);
            break;

          case WalletType.bip32:
            verify(() =>
                    mockWalletService.deriveRootCounterwallet(any(), any()))
                .called(1);
            verify(() => mockBitcoinRepository.getTransactions(any()))
                .called(4);
            verify(() => mockWalletRepository.insert(any())).called(1);
            verify(() => mockAccountRepository.insert(any())).called(3);
            verify(() => mockAddressRepository.insertMany(any())).called(3);
            verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
                .called(1);
            verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
                .called(1);
            expect(successCallbackInvoked, true);
            expect(errorCallbackInvoked, false);
            break;
        }
      });

      test('error callback is invoked when an error occurs: $walletType',
          () async {
        // Setup
        const mnemonic = 'test mnemonic phrase for import';
        const password = 'testPassword';
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

    // Update test cases to use WalletType instead of ImportFormat
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

    test('imports freewallet when counterwallet has no transactions', () async {
      // Setup
      const mnemonic = 'test mnemonic phrase for import';
      const password = 'testPassword';
      const counterWallet = Wallet(
          name: "Imported Wallet",
          uuid: 'counter-wallet-uuid',
          publicKey: "counter-public-key",
          encryptedPrivKey: 'counter-encrypted',
          chainCodeHex: 'counter-chainCode');
      const freeWallet = Wallet(
          name: "Imported Wallet",
          uuid: 'free-wallet-uuid',
          publicKey: "free-public-key",
          encryptedPrivKey: 'free-encrypted',
          chainCodeHex: 'free-chainCode');
      const decryptedPrivKey = 'decrypted-private-key';

      when(() => mockConfig.network).thenReturn(Network.mainnet);

      // Mock Counterwallet derivation
      when(() => mockWalletService.deriveRootCounterwallet(any(), any()))
          .thenAnswer((_) async => counterWallet);

      // Mock Freewallet derivation (used after Counterwallet fails)
      when(() => mockWalletService.deriveRootFreewallet(any(), any()))
          .thenAnswer((_) async => freeWallet);

      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
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
      verify(() => mockWalletRepository.insert(any())).called(1);
      verify(() => mockAccountRepository.insert(any())).called(1);
      verify(() => mockAddressRepository.insertMany(any())).called(1);
      verify(() => mockEncryptionService.getDecryptionKey(any(), any()))
          .called(1);
      verify(() => mockInMemoryKeyRepository.set(key: any(named: 'key')))
          .called(1);

      expect(successCallbackInvoked, true);
      expect(errorCallbackInvoked, false);
    });
  });

  group('ImportWalletUseCase createHorizonWallet', () {
    test('creates accounts and addresses for horizon wallet with transactions',
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

      // Act
      final result = await importWalletUseCase.createHorizonWallet(
        password: password,
        mnemonic: mnemonic,
        wallet: wallet,
      );

      // Verify
      verify(() =>
              mockEncryptionService.decrypt(wallet.encryptedPrivKey, password))
          .called(1);

      // Should check 4 accounts (3 with transactions + 1 empty)
      verify(() => mockBitcoinRepository.getTransactions(any())).called(4);

      // Should derive 4 addresses (one for each account checked)
      verify(() => mockAddressService.deriveAddressSegwit(
            privKey: decryptedPrivKey,
            chainCodeHex: wallet.chainCodeHex,
            accountUuid: any(named: 'accountUuid'),
            purpose: '84\'',
            coin: '0\'',
            account: any(named: 'account'),
            change: '0',
            index: 0,
          )).called(4);

      // Verify result structure
      expect(result.length, 3); // Should have 3 accounts with transactions

      // Verify each account in the result
      result.forEach((account, addresses) {
        expect(account.walletUuid, equals(wallet.uuid));
        expect(account.purpose, equals('84\''));
        expect(account.coinType, equals('0\''));
        expect(
            addresses.length, equals(1)); // Each account should have 1 address

        // Verify address properties
        expect(addresses.first.accountUuid, equals(account.uuid));
        expect(addresses.first.address, contains('bc1q_test_address_'));
      });

      // Verify account indices
      var accountIndices =
          result.keys.map((account) => account.accountIndex).toList();
      expect(accountIndices, ['0\'', '1\'', '2\'']);
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
  });
}
