import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/shell/address_form/bloc/address_form_bloc.dart';
import 'package:horizon/presentation/shell/address_form/bloc/address_form_event.dart';
import 'package:horizon/domain/services/wallet_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/repositories/account_repository.dart';
import 'package:horizon/domain/repositories/address_repository.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/common/constants.dart';
import 'package:horizon/remote_data_bloc/remote_data_state.dart';

class MockWalletService extends Mock implements WalletService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {
  FakeAddress({required this.index});
  @override
  final int index;
}

void main() {
  late MockWalletService mockWalletService;
  late MockEncryptionService mockEncryptionService;
  late MockAddressService mockAddressService;
  late MockWalletRepository mockWalletRepository;
  late MockAccountRepository mockAccountRepository;
  late MockAddressRepository mockAddressRepository;

  setUpAll(() {
    registerFallbackValue(FakeWallet());
    registerFallbackValue(FakeAccount());
    registerFallbackValue(FakeAddress(index: 0));
  });

  setUp(() {
    mockWalletService = MockWalletService();
    mockEncryptionService = MockEncryptionService();
    mockAddressService = MockAddressService();
    mockWalletRepository = MockWalletRepository();
    mockAccountRepository = MockAccountRepository();
    mockAddressRepository = MockAddressRepository();

    GetIt.I.registerSingleton<WalletService>(mockWalletService);
    GetIt.I.registerSingleton<EncryptionService>(mockEncryptionService);
    GetIt.I.registerSingleton<AddressService>(mockAddressService);
    GetIt.I.registerSingleton<WalletRepository>(mockWalletRepository);
    GetIt.I.registerSingleton<AccountRepository>(mockAccountRepository);
    GetIt.I.registerSingleton<AddressRepository>(mockAddressRepository);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('AddressFormBloc', () {
    const walletUuid = 'test-wallet-uuid';
    const accountUuid = 'test-account-uuid';
    const password = 'test-password';
    const decryptedPrivKey = 'decrypted-private-key';
    const chainCodeHex = 'chain-code-hex';
    const wallet = Wallet(
      uuid: walletUuid,
      name: 'Test Wallet',
      publicKey: 'public-key',
      encryptedPrivKey: 'encrypted-private-key',
      chainCodeHex: chainCodeHex,
    );

    void setupCommonMocks({
      required ImportFormat importFormat,
      required String purpose,
      required String coinType,
      required String accountIndex,
    }) {
      when(() => mockWalletRepository.getCurrentWallet())
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockWalletService.fromPrivateKey(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockAccountRepository.getAccountByUuid(any()))
          .thenAnswer((_) async => Account(
                uuid: accountUuid,
                name: 'Test Account',
                walletUuid: walletUuid,
                purpose: purpose,
                coinType: coinType,
                accountIndex: accountIndex,
                importFormat: importFormat,
              ));
      when(() => mockAddressRepository.getAllByAccountUuid(any()))
          .thenAnswer((_) async => [
                FakeAddress(index: 0),
                FakeAddress(index: 1),
              ]);
    }

    blocTest<AddressFormBloc, RemoteDataState<List<Address>>>(
      'does nothing for horizon',
      build: () {
        setupCommonMocks(
          importFormat: ImportFormat.horizon,
          purpose: '84\'',
          coinType: '0\'',
          accountIndex: '0\'',
        );
        return AddressFormBloc();
      },
      act: (bloc) => bloc.add(Submit(
        accountUuid: accountUuid,
        password: password,
      )),
      expect: () => [
        const RemoteDataState<List<Address>>.loading(),
        const RemoteDataState<List<Address>>.initial(),
      ],
      verify: (_) {
        verifyNever(() => mockAddressService.deriveAddressSegwit(
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              purpose: any(named: "purpose"),
              coin: any(named: "coin"),
              account: any(named: "account"),
              change: any(named: "change"),
              index: any(named: "index"),
            ));
      },
    );

    blocTest<AddressFormBloc, RemoteDataState<List<Address>>>(
      'submits form with Freewallet import format',
      build: () {
        setupCommonMocks(
          importFormat: ImportFormat.freewallet,
          purpose: '32',
          coinType: '0',
          accountIndex: "0'",
        );
        when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              // purpose: any(named: 'purpose'),
              // coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            )).thenAnswer((_) async => [FakeAddress(index: 2)]);
        when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              // purpose: any(named: 'purpose'),
              // coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            )).thenAnswer((_) async => [FakeAddress(index: 2)]);

        when(() => mockAddressRepository.insertMany(any()))
            .thenAnswer((_) async => null);

        return AddressFormBloc();
      },
      act: (bloc) => bloc.add(Submit(
        accountUuid: accountUuid,
        password: password,
      )),
      expect: () => [
        const RemoteDataState<List<Address>>.loading(),
        isA<RemoteDataState<List<Address>>>().having(
          (state) => state.whenOrNull(
            success: (addresses) => addresses.length,
          ),
          'address count',
          2,
        ),
      ],
      verify: (_) {
        verify(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: "privKey"),
              chainCodeHex: any(named: "chainCodeHex"),
              accountUuid: any(named: "accountUuid"),
              // purpose: '32',
              // coin: '0',
              account: '0\'',
              change: '0',
              start: 2,
              end: 2,
            )).called(1);
        verify(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.bech32,
              privKey: any(named: "privKey"),
              chainCodeHex: any(named: "chainCodeHex"),
              accountUuid: any(named: "accountUuid"),
              // purpose: '32',
              // coin: '0',
              account: '0\'',
              change: '0',
              start: 2,
              end: 2,
            )).called(1);
      },
    );

    blocTest<AddressFormBloc, RemoteDataState<List<Address>>>(
      'submits form with Counterwallet import format',
      build: () {
        setupCommonMocks(
          importFormat: ImportFormat.counterwallet,
          purpose: '0\'',
          coinType: '0',
          accountIndex: "0'",
        );
        when(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              // purpose: any(named: 'purpose'),
              // coin: any(named: 'coin'),
              account: any(named: 'account'),
              change: any(named: 'change'),
              start: any(named: 'start'),
              end: any(named: 'end'),
            )).thenAnswer((_) async => [FakeAddress(index: 2)]);

        when(() => mockAddressRepository.insertMany(any()))
            .thenAnswer((_) async => null);

        return AddressFormBloc();
      },
      act: (bloc) => bloc.add(Submit(
        accountUuid: accountUuid,
        password: password,
      )),
      expect: () => [
        const RemoteDataState<List<Address>>.loading(),
        isA<RemoteDataState<List<Address>>>().having(
          (state) => state.whenOrNull(
            success: (addresses) => addresses.length,
          ),
          'address count',
          1,
        ),
      ],
      verify: (_) {
        verify(() => mockAddressService.deriveAddressFreewalletRange(
              type: AddressType.legacy,
              privKey: any(named: "privKey"),
              chainCodeHex: any(named: "chainCodeHex"),
              accountUuid: any(named: "accountUuid"),
              // purpose: '0\'',
              // coin: '0',
              account: '0\'',
              change: '0',
              start: 2,
              end: 2,
            )).called(1);
      },
    );
  });
}
