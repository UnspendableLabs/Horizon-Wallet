import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/in_memory_key_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/settings/import_address/bloc/import_address_pk_state.dart';
import 'package:horizon/common/constants.dart';

// Mock classes
class MockWalletRepository extends Mock implements WalletRepository {}

class MockWalletService extends Mock implements WalletService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockAddressRepository extends Mock implements AddressRepository {}

class MockImportedAddressRepository extends Mock
    implements ImportedAddressRepository {}

class MockImportedAddressService extends Mock
    implements ImportedAddressService {}

class MockInMemoryKeyRepository extends Mock implements InMemoryKeyRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ImportedAddress(
        address: 'fallback-address',
        name: 'fallback-name',
        encryptedWif: 'fallback-encrypted-wif',
      ),
    );
  });

  late ImportAddressPkBloc bloc;
  late MockWalletRepository mockWalletRepository;
  late MockWalletService mockWalletService;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockAddressRepository mockAddressRepository;
  late MockImportedAddressRepository mockImportedAddressRepository;
  late MockImportedAddressService mockImportedAddressService;
  late MockInMemoryKeyRepository mockInMemoryKeyRepository;

  const testWallet = Wallet(
      uuid: 'test-uuid',
      name: 'Test Wallet',
      encryptedPrivKey: 'encrypted-priv-key',
      encryptedMnemonic: 'encrypted-mnemonic',
      chainCodeHex: 'chain-code',
      publicKey: 'public-key');

  const testWIF = 'test-wif';
  const testPassword = 'test-password';
  const testAddress = 'test-address';
  const testName = 'Test Address';
  const testFormat = ImportAddressPkFormat.segwit;
  const testEncryptedWIF = 'encrypted-wif';
  const testEncryptionKey = 'encryption-key';

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockWalletService = MockWalletService();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockAddressRepository = MockAddressRepository();
    mockImportedAddressRepository = MockImportedAddressRepository();
    mockImportedAddressService = MockImportedAddressService();
    mockInMemoryKeyRepository = MockInMemoryKeyRepository();

    bloc = ImportAddressPkBloc(
      walletRepository: mockWalletRepository,
      walletService: mockWalletService,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      addressRepository: mockAddressRepository,
      importedAddressRepository: mockImportedAddressRepository,
      importedAddressService: mockImportedAddressService,
      inMemoryKeyRepository: mockInMemoryKeyRepository,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ImportAddressPkBloc', () {
    test('initial state is ImportAddressPkInitial', () {
      expect(bloc.state, isA<ImportAddressPkInitial>());
    });

    group('Submit', () {
      final submitEvent = Submit(
        wif: testWIF,
        password: testPassword,
        format: testFormat,
        name: testName,
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Success] when import is successful',
        build: () {
          // Mock successful wallet retrieval
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);

          // Mock successful password verification
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');

          // Mock successful address derivation
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenAnswer((_) async => testAddress);

          // Mock address not existing
          when(() => mockAddressRepository.getAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .thenAnswer((_) async => null);

          // Mock successful WIF encryption
          when(() => mockEncryptionService.encrypt(testWIF, testPassword))
              .thenAnswer((_) async => testEncryptedWIF);

          // Mock successful encryption key retrieval
          when(() => mockEncryptionService.getDecryptionKey(
                  testEncryptedWIF, testPassword))
              .thenAnswer((_) async => testEncryptionKey);

          // Mock successful in-memory key operations
          when(() => mockInMemoryKeyRepository.getMap())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository
                  .setMap(map: {testAddress: testEncryptionKey}))
              .thenAnswer((_) async => {});

          // Mock successful address insertion
          when(() =>
                  mockImportedAddressRepository.insert(any<ImportedAddress>()))
              .thenAnswer((_) async => {});

          return bloc;
        },
        act: (bloc) async {
          bloc.add(submitEvent);
          await Future.delayed(const Duration(milliseconds: 100));
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkSuccess>().having(
            (state) => state.address,
            'address',
            isA<ImportedAddress>()
                .having((addr) => addr.address, 'address', testAddress)
                .having((addr) => addr.encryptedWif, 'encryptedWif',
                    testEncryptedWIF)
                .having((addr) => addr.name, 'name', testName),
          ),
        ],
        verify: (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verify(() => mockEncryptionService.decrypt(
              testWallet.encryptedPrivKey, testPassword)).called(1);
          verify(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).called(1);
          verify(() => mockAddressRepository.getAddress(testAddress)).called(1);
          verify(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .called(1);
          verify(() => mockEncryptionService.encrypt(testWIF, testPassword))
              .called(1);
          verify(() => mockEncryptionService.getDecryptionKey(
              testEncryptedWIF, testPassword)).called(1);
          verify(() => mockInMemoryKeyRepository.getMap()).called(1);
          verify(() => mockInMemoryKeyRepository
              .setMap(map: {testAddress: testEncryptionKey})).called(1);
          verify(() =>
                  mockImportedAddressRepository.insert(any<ImportedAddress>()))
              .called(1);
        },
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when wallet is null',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => null);
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Exception: invariant: wallet is null',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when password is incorrect',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenThrow(Exception('Decryption failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Incorrect password',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when WIF is invalid',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenThrow(Exception('Invalid WIF'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Invalid address private key',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when address already exists',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenAnswer((_) async => testAddress);
          when(() => mockAddressRepository.getAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .thenAnswer((_) async => const ImportedAddress(
                    address: testAddress,
                    encryptedWif: testEncryptedWIF,
                    name: testName,
                  ));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Address ${testFormat.name} $testAddress already exists in your wallet',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when address insertion fails with UNIQUE constraint',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenAnswer((_) async => testAddress);
          when(() => mockAddressRepository.getAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() => mockEncryptionService.encrypt(testWIF, testPassword))
              .thenAnswer((_) async => testEncryptedWIF);
          when(() => mockEncryptionService.getDecryptionKey(
                  testEncryptedWIF, testPassword))
              .thenAnswer((_) async => testEncryptionKey);
          when(() => mockInMemoryKeyRepository.getMap())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository
                  .setMap(map: {testAddress: testEncryptionKey}))
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.insert(any()))
              .thenThrow(Exception('UNIQUE constraint failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Address ${testFormat.name} $testAddress already exists in your wallet',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when address insertion fails with other error',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenAnswer((_) async => testAddress);
          when(() => mockAddressRepository.getAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() => mockEncryptionService.encrypt(testWIF, testPassword))
              .thenAnswer((_) async => testEncryptedWIF);
          when(() => mockEncryptionService.getDecryptionKey(
                  testEncryptedWIF, testPassword))
              .thenAnswer((_) async => testEncryptionKey);
          when(() => mockInMemoryKeyRepository.getMap())
              .thenAnswer((_) async => {});
          when(() => mockInMemoryKeyRepository
                  .setMap(map: {testAddress: testEncryptionKey}))
              .thenAnswer((_) async => {});
          when(() => mockImportedAddressRepository.insert(any()))
              .thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Exception: Database error',
          ),
        ],
      );

      blocTest<ImportAddressPkBloc, ImportAddressPkState>(
        'emits [Loading, Error] when in-memory key operations fail',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);
          when(() => mockEncryptionService.decrypt(
                  testWallet.encryptedPrivKey, testPassword))
              .thenAnswer((_) async => 'decrypted-key');
          when(() => mockImportedAddressService.getAddressFromWIF(
                wif: testWIF,
                format: testFormat,
              )).thenAnswer((_) async => testAddress);
          when(() => mockAddressRepository.getAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() =>
                  mockImportedAddressRepository.getImportedAddress(testAddress))
              .thenAnswer((_) async => null);
          when(() => mockEncryptionService.encrypt(testWIF, testPassword))
              .thenAnswer((_) async => testEncryptedWIF);
          when(() => mockEncryptionService.getDecryptionKey(
                  testEncryptedWIF, testPassword))
              .thenAnswer((_) async => testEncryptionKey);
          when(() => mockInMemoryKeyRepository.getMap())
              .thenThrow(Exception('Failed to get in-memory keys'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ImportAddressPkLoading>(),
          isA<ImportAddressPkError>().having(
            (state) => state.error,
            'error',
            'Exception: Failed to get in-memory keys',
          ),
        ],
      );
    });
  });
}
