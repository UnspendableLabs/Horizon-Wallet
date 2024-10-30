import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/imported_address_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/import_address_pk_form/bloc/import_address_pk_state.dart';
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

// Fake classes for fallback values
class FakeWallet extends Fake implements Wallet {}

class FakeImportedAddress extends Fake implements ImportedAddress {}

void main() {
  late ImportAddressPkBloc bloc;
  late MockWalletRepository mockWalletRepository;
  late MockWalletService mockWalletService;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockAddressRepository mockAddressRepository;
  late MockImportedAddressRepository mockImportedAddressRepository;
  late MockImportedAddressService mockImportedAddressService;

  const testWif = 'test-wif-key';
  const testPassword = 'test-password';
  const testName = 'test-name';
  const testAddress = '1TestAddress123';
  const testWalletUuid = 'test-wallet-uuid';
  const testEncryptedPrivKey = 'encrypted-private-key';

  setUpAll(() {
    registerFallbackValue(FakeWallet());
    registerFallbackValue(FakeImportedAddress());
    registerFallbackValue(ImportAddressPkFormat.segwit);
  });

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockWalletService = MockWalletService();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockAddressRepository = MockAddressRepository();
    mockImportedAddressRepository = MockImportedAddressRepository();
    mockImportedAddressService = MockImportedAddressService();

    bloc = ImportAddressPkBloc(
      walletRepository: mockWalletRepository,
      walletService: mockWalletService,
      encryptionService: mockEncryptionService,
      addressService: mockAddressService,
      addressRepository: mockAddressRepository,
      importedAddressRepository: mockImportedAddressRepository,
      importedAddressService: mockImportedAddressService,
    );
  });

  group('ImportAddressPkBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, isA<ImportAddressPkStep1>());
    });

    blocTest<ImportAddressPkBloc, ImportAddressPkState>(
      'emits Step2Initial when Finalize is added',
      build: () => bloc,
      act: (bloc) => bloc.add(Finalize()),
      expect: () => [
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Initial>(),
        ),
      ],
    );

    blocTest<ImportAddressPkBloc, ImportAddressPkState>(
      'emits error when wallet is null',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet())
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(
        wif: testWif,
        password: testPassword,
        name: testName,
        format: ImportAddressPkFormat.segwit,
      )),
      expect: () => [
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Loading>(),
        ),
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Error>().having(
            (error) => error.error,
            'error',
            'Exception: invariant: wallet is null',
          ),
        ),
      ],
    );

    blocTest<ImportAddressPkBloc, ImportAddressPkState>(
      'emits error when password is incorrect',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
          (_) async => const Wallet(
            uuid: testWalletUuid,
            name: 'Test Wallet',
            publicKey: 'test-public-key',
            encryptedPrivKey: testEncryptedPrivKey,
            chainCodeHex: 'test-chain-code',
          ),
        );
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenThrow(Exception('decrypt error'));
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(
        wif: testWif,
        password: testPassword,
        name: testName,
        format: ImportAddressPkFormat.segwit,
      )),
      expect: () => [
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Loading>(),
        ),
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Error>().having(
            (error) => error.error,
            'error',
            'Incorrect password',
          ),
        ),
      ],
    );

    blocTest<ImportAddressPkBloc, ImportAddressPkState>(
      'successfully imports address',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
          (_) async => const Wallet(
            uuid: testWalletUuid,
            name: 'Test Wallet',
            publicKey: 'test-public-key',
            encryptedPrivKey: testEncryptedPrivKey,
            chainCodeHex: 'test-chain-code',
          ),
        );
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => 'decrypted-key');
        when(() => mockImportedAddressService.getAddressFromWIF(
              wif: any(named: 'wif'),
              format: any(named: 'format'),
            )).thenAnswer((_) async => testAddress);
        when(() => mockAddressRepository.getAddress(any()))
            .thenAnswer((_) async => null);
        when(() => mockEncryptionService.encrypt(any(), any()))
            .thenAnswer((_) async => 'encrypted-wif');
        when(() => mockImportedAddressRepository.insert(any()))
            .thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(
        wif: testWif,
        password: testPassword,
        name: testName,
        format: ImportAddressPkFormat.segwit,
      )),
      expect: () => [
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Loading>(),
        ),
        isA<ImportAddressPkStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Success>(),
        ),
      ],
      verify: (_) {
        verify(() => mockImportedAddressService.getAddressFromWIF(
              wif: testWif,
              format: ImportAddressPkFormat.segwit,
            )).called(1);
        verify(() => mockEncryptionService.encrypt(testWif, testPassword))
            .called(1);
        verify(() => mockImportedAddressRepository.insert(any())).called(1);
      },
    );

    blocTest<ImportAddressPkBloc, ImportAddressPkState>(
      'resets form when ResetForm is added',
      build: () => bloc,
      act: (bloc) => bloc.add(ResetForm()),
      expect: () => [isA<ImportAddressPkStep1>()],
    );
  });
}
