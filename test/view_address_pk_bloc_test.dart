import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/common/constants.dart';
import 'package:mocktail/mocktail.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/imported_address.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/repositories/imported_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_bloc.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_event.dart';
import 'package:horizon/presentation/screens/dashboard/view_address_pk_form/bloc/view_address_pk_state.dart';

// Mock classes
class MockAddressRepository extends Mock implements AddressRepository {}

class MockImportedAddressRepository extends Mock
    implements ImportedAddressRepository {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockWalletService extends Mock implements WalletService {}

// Fake classes for fallback values
class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {}

class FakeImportedAddress extends Fake implements ImportedAddress {}

void main() {
  late ViewAddressPkFormBloc bloc;
  late MockAddressRepository mockAddressRepository;
  late MockImportedAddressRepository mockImportedAddressRepository;
  late MockAddressService mockAddressService;
  late MockWalletRepository mockWalletRepository;
  late MockAccountRepository mockAccountRepository;
  late MockEncryptionService mockEncryptionService;
  late MockWalletService mockWalletService;

  const testAddress = '1TestAddress123';
  const testPassword = 'testPassword123';
  const testWalletUuid = 'test-wallet-uuid';
  const testAccountUuid = 'test-account-uuid';
  const testPrivKeyWif = 'test-private-key-wif';
  const testEncryptedPrivKey = 'encrypted-private-key';
  const testDecryptedPrivKey = 'decrypted-private-key';
  const testChainCodeHex = 'test-chain-code-hex';

  setUpAll(() {
    registerFallbackValue(FakeWallet());
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress());
    registerFallbackValue(FakeImportedAddress());
    registerFallbackValue(ImportFormat.horizon);
  });

  setUp(() {
    mockAddressRepository = MockAddressRepository();
    mockImportedAddressRepository = MockImportedAddressRepository();
    mockAddressService = MockAddressService();
    mockWalletRepository = MockWalletRepository();
    mockAccountRepository = MockAccountRepository();
    mockEncryptionService = MockEncryptionService();
    mockWalletService = MockWalletService();

    bloc = ViewAddressPkFormBloc(
      addressRepository: mockAddressRepository,
      importedAddressRepository: mockImportedAddressRepository,
      addressService: mockAddressService,
      walletRepository: mockWalletRepository,
      accountRepository: mockAccountRepository,
      encryptionService: mockEncryptionService,
      walletService: mockWalletService,
    );
  });

  group('ViewAddressPkFormBloc', () {
    test('initial state is correct', () {
      expect(
        bloc.state,
        const ViewAddressPkState.initial(
            ViewAddressPkStateInitial(error: null)),
      );
    });

    blocTest<ViewAddressPkFormBloc, ViewAddressPkState>(
      'emits error when address not found',
      build: () {
        when(() => mockAddressRepository.getAddress(testAddress))
            .thenAnswer((_) async => null);
        when(() =>
                mockImportedAddressRepository.getImportedAddress(testAddress))
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const ViewAddressPk(
        address: testAddress,
        password: testPassword,
      )),
      expect: () => [
        const ViewAddressPkState.loading(),
        const ViewAddressPkState.error('Address not found'),
      ],
      verify: (bloc) {
        verify(() => mockAddressRepository.getAddress(testAddress)).called(1);
        verify(() =>
                mockImportedAddressRepository.getImportedAddress(testAddress))
            .called(1);
        verifyNever(() => mockAddressService.getAddressWIFFromPrivateKey(
              rootPrivKey: any(named: 'rootPrivKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index'),
              importFormat: any(named: 'importFormat'),
            )).called(0);
        verifyNever(() => mockEncryptionService.decrypt(any(), any()))
            .called(0);
      },
    );

    blocTest<ViewAddressPkFormBloc, ViewAddressPkState>(
      'successfully gets private key for regular address',
      build: () {
        const testAddress = Address(
          accountUuid: testAccountUuid,
          address: '1TestAddress123',
          index: 0,
        );
        final testAccount = Account(
          uuid: testAccountUuid,
          name: 'Test Account',
          walletUuid: testWalletUuid,
          purpose: '84\'',
          coinType: '0\'',
          accountIndex: '0\'',
          importFormat: ImportFormat.horizon,
        );
        const testWallet = Wallet(
          uuid: testWalletUuid,
          name: 'Test Wallet',
          publicKey: 'test-public-key',
          encryptedPrivKey: testEncryptedPrivKey,
          chainCodeHex: testChainCodeHex,
        );

        when(() => mockAddressRepository.getAddress(any()))
            .thenAnswer((_) async => testAddress);
        when(() => mockImportedAddressRepository.getImportedAddress(any()))
            .thenAnswer((_) async => null);
        when(() => mockAccountRepository.getAccountByUuid(any()))
            .thenAnswer((_) async => testAccount);
        when(() => mockWalletRepository.getWallet(any()))
            .thenAnswer((_) async => testWallet);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => testDecryptedPrivKey);
        when(() => mockAddressService.getAddressWIFFromPrivateKey(
              rootPrivKey: any(named: 'rootPrivKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index'),
              importFormat: any(named: 'importFormat'),
            )).thenAnswer((_) async => testPrivKeyWif);

        return bloc;
      },
      act: (bloc) => bloc.add(const ViewAddressPk(
        address: testAddress,
        password: testPassword,
      )),
      expect: () => [
        const ViewAddressPkState.loading(),
        const ViewAddressPkState.success(ViewAddressPkStateSuccess(
          privateKeyWif: testPrivKeyWif,
          address: testAddress,
          name: 'Test Account',
        )),
      ],
      verify: (bloc) {
        verify(() => mockAddressRepository.getAddress(testAddress)).called(1);
        verify(() =>
                mockImportedAddressRepository.getImportedAddress(testAddress))
            .called(1);
        verify(() => mockAccountRepository.getAccountByUuid(testAccountUuid))
            .called(1);
        verify(() => mockWalletRepository.getWallet(testWalletUuid)).called(1);
        verify(() => mockEncryptionService.decrypt(
            testEncryptedPrivKey, testPassword)).called(1);
        verify(() => mockAddressService.getAddressWIFFromPrivateKey(
              rootPrivKey: testDecryptedPrivKey,
              chainCodeHex: testChainCodeHex,
              purpose: '84\'',
              coin: '0\'',
              account: '0\'',
              change: '0',
              index: 0,
              importFormat: ImportFormat.horizon,
            )).called(1);
      },
    );

    blocTest<ViewAddressPkFormBloc, ViewAddressPkState>(
      'successfully gets private key for imported address',
      build: () {
        const importedAddress = ImportedAddress(
          name: 'Imported Address',
          address: testAddress,
          encryptedWIF: testEncryptedPrivKey,
          walletUuid: testWalletUuid,
        );

        when(() => mockAddressRepository.getAddress(any()))
            .thenAnswer((_) async => null);
        when(() => mockImportedAddressRepository.getImportedAddress(any()))
            .thenAnswer((_) async => importedAddress);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenAnswer((_) async => testPrivKeyWif);

        return bloc;
      },
      act: (bloc) => bloc.add(const ViewAddressPk(
        address: testAddress,
        password: testPassword,
      )),
      expect: () => [
        const ViewAddressPkState.loading(),
        const ViewAddressPkState.success(ViewAddressPkStateSuccess(
          privateKeyWif: testPrivKeyWif,
          address: testAddress,
          name: 'Imported Address',
        )),
      ],
      verify: (bloc) {
        verify(() => mockAddressRepository.getAddress(testAddress)).called(1);
        verify(() =>
                mockImportedAddressRepository.getImportedAddress(testAddress))
            .called(1);
        verify(() => mockEncryptionService.decrypt(
            testEncryptedPrivKey, testPassword)).called(1);
      },
    );

    blocTest<ViewAddressPkFormBloc, ViewAddressPkState>(
      'emits error when password is invalid',
      build: () {
        const testAddress = Address(
          accountUuid: testAccountUuid,
          address: '1TestAddress123',
          index: 0,
        );
        final testAccount = Account(
          uuid: testAccountUuid,
          name: 'Test Account',
          walletUuid: testWalletUuid,
          purpose: '84\'',
          coinType: '0\'',
          accountIndex: '0\'',
          importFormat: ImportFormat.horizon,
        );
        const testWallet = Wallet(
          uuid: testWalletUuid,
          name: 'Test Wallet',
          publicKey: 'test-public-key',
          encryptedPrivKey: testEncryptedPrivKey,
          chainCodeHex: testChainCodeHex,
        );

        when(() => mockAddressRepository.getAddress(any()))
            .thenAnswer((_) async => testAddress);
        when(() => mockImportedAddressRepository.getImportedAddress(any()))
            .thenAnswer((_) async => null);
        when(() => mockAccountRepository.getAccountByUuid(any()))
            .thenAnswer((_) async => testAccount);
        when(() => mockWalletRepository.getWallet(any()))
            .thenAnswer((_) async => testWallet);
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenThrow(Exception('Invalid password'));

        return bloc;
      },
      act: (bloc) => bloc.add(const ViewAddressPk(
        address: testAddress,
        password: 'wrong-password',
      )),
      expect: () => [
        const ViewAddressPkState.loading(),
        const ViewAddressPkState.initial(
          ViewAddressPkStateInitial(error: 'Invalid password'),
        ),
      ],
      verify: (bloc) {
        verify(() => mockAddressRepository.getAddress(testAddress)).called(1);
        verify(() =>
                mockImportedAddressRepository.getImportedAddress(testAddress))
            .called(1);
        verify(() => mockAccountRepository.getAccountByUuid(testAccountUuid))
            .called(1);
        verify(() => mockWalletRepository.getWallet(testWalletUuid)).called(1);
        verify(() => mockEncryptionService.decrypt(
            testEncryptedPrivKey, 'wrong-password')).called(1);
        verifyNever(() => mockAddressService.getAddressWIFFromPrivateKey(
              rootPrivKey: any(named: 'rootPrivKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              purpose: any(named: 'purpose'),
              coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              index: any(named: 'index'),
              importFormat: any(named: 'importFormat'),
            )).called(0);
      },
    );
  });
}
