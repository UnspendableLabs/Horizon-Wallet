import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/presentation/shell/account_form/bloc/account_form_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/presentation/shell/account_form/bloc/account_form_bloc.dart';
import 'package:horizon/presentation/shell/account_form/bloc/account_form_event.dart';
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

class MockWalletService extends Mock implements WalletService {}

class MockEncryptionService extends Mock implements EncryptionService {}

class MockAddressService extends Mock implements AddressService {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockAccountRepository extends Mock implements AccountRepository {}

class MockAddressRepository extends Mock implements AddressRepository {}

class FakeWallet extends Fake implements Wallet {}

class FakeAccount extends Fake implements Account {}

class FakeAddress extends Fake implements Address {}

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
    registerFallbackValue(FakeAddress());
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

  group('AccountFormBloc', () {
    const walletUuid = 'test-wallet-uuid';
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

    void setupCommonMocks() {
      when(() => mockWalletRepository.getCurrentWallet())
          .thenAnswer((_) async => wallet);
      when(() => mockEncryptionService.decrypt(any(), any()))
          .thenAnswer((_) async => decryptedPrivKey);
      when(() => mockWalletService.fromPrivateKey(any(), any()))
          .thenAnswer((_) async => wallet);
      when(() => mockAccountRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insert(any())).thenAnswer((_) async {});
      when(() => mockAddressRepository.insertMany(any()))
          .thenAnswer((_) async {});
    }

    // this test isn't super helpful as args are just passed through
    blocTest<AccountFormBloc, AccountFormState>(
      'submits form with Horizon import format',
      build: () {
        setupCommonMocks();
        when(() => mockAddressService.deriveAddressSegwit(
              privKey: any(named: 'privKey'),
              chainCodeHex: any(named: 'chainCodeHex'),
              accountUuid: any(named: 'accountUuid'),
              purpose: '84\'',
              coin: '0\'',
              account: '0\'',
              change: '0',
              index: 0,
            )).thenAnswer((_) async => FakeAddress());
        return AccountFormBloc();
      },
      act: (bloc) => bloc.add(Submit(
        name: 'Test Account',
        walletUuid: walletUuid,
        purpose: '84\'',
        coinType: '0\'',
        accountIndex: '0\'',
        importFormat: ImportFormat.horizon,
        password: password,
      )),
      expect: () => [
        isA<AccountFormStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Loading>(),
        ),
        isA<AccountFormStep2>().having(
          (state) => state.state,
          'state',
          isA<Step2Success>().having(
            (success) => success.account,
            'account',
            isA<Account>()
                .having((a) => a.name, 'name', 'Test Account')
                .having((a) => a.walletUuid, 'walletUuid', walletUuid)
                .having((a) => a.purpose, 'purpose', '84\'')
                .having((a) => a.coinType, 'coinType', '0\'')
                .having((a) => a.accountIndex, 'accountIndex', '0\'')
                .having((a) => a.importFormat, 'importFormat',
                    ImportFormat.horizon),
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockAddressService.deriveAddressSegwit(
              privKey: decryptedPrivKey,
              chainCodeHex: chainCodeHex,
              accountUuid: any(named: 'accountUuid'),
              purpose: '84\'',
              coin: '0\'',
              account: '0\'',
              change: '0',
              index: 0,
            )).called(1);
      },
    );
  });
}
