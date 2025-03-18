import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/entities/wallet.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_bloc.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_event.dart';
import 'package:horizon/presentation/screens/settings/seed_phrase/bloc/view_seed_phrase_state.dart';
import 'package:mocktail/mocktail.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

class MockEncryptionService extends Mock implements EncryptionService {}

class FakeWallet extends Fake implements Wallet {}

void main() {
  late ViewSeedPhraseBloc bloc;
  late MockWalletRepository mockWalletRepository;
  late MockEncryptionService mockEncryptionService;

  const testPassword = 'test-password';
  const testSeedPhrase = 'test seed phrase';
  const testEncryptedMnemonic = 'encrypted-mnemonic';

  const testWallet = Wallet(
      uuid: 'test-uuid',
      name: 'Test Wallet',
      encryptedPrivKey: 'encrypted-priv-key',
      encryptedMnemonic: testEncryptedMnemonic,
      chainCodeHex: 'chain-code',
      publicKey: 'public-key');

  setUpAll(() {
    registerFallbackValue(FakeWallet());
  });

  setUp(() {
    mockWalletRepository = MockWalletRepository();
    mockEncryptionService = MockEncryptionService();

    bloc = ViewSeedPhraseBloc(
      walletRepository: mockWalletRepository,
      encryptionService: mockEncryptionService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ViewSeedPhraseBloc', () {
    test('initial state is ViewSeedPhraseInitial', () {
      expect(bloc.state, isA<ViewSeedPhraseInitial>());
    });

    group('Submit', () {
      final submitEvent = Submit(password: testPassword);

      blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        'emits [Loading, Success] when seed phrase retrieval is successful',
        build: () {
          // Mock successful wallet retrieval
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);

          // Mock successful decryption
          when(() => mockEncryptionService.decrypt(
                testEncryptedMnemonic,
                testPassword,
              )).thenAnswer((_) async => testSeedPhrase);

          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ViewSeedPhraseLoading>(),
          isA<ViewSeedPhraseSuccess>().having(
              (state) => state.seedPhrase, 'seedPhrase', testSeedPhrase),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verify(() => mockEncryptionService.decrypt(
                testEncryptedMnemonic,
                testPassword,
              )).called(1);
        },
      );

      blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        'emits [Loading, Error] when wallet is null',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => null);
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ViewSeedPhraseLoading>(),
          isA<ViewSeedPhraseError>()
              .having((state) => state.error, 'error', 'Wallet not found'),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verifyNever(() => mockEncryptionService.decrypt(any(), any()));
        },
      );

      blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        'emits [Loading, Error] when wallet has no mnemonic',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
              (_) async => const Wallet(
                  uuid: 'test-uuid',
                  name: 'Test Wallet',
                  encryptedPrivKey: 'encrypted-priv-key',
                  encryptedMnemonic: null,
                  chainCodeHex: 'chain-code',
                  publicKey: 'public-key'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ViewSeedPhraseLoading>(),
          isA<ViewSeedPhraseError>().having(
              (state) => state.error, 'error', 'Wallet mnemonic not found'),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verifyNever(() => mockEncryptionService.decrypt(any(), any()));
        },
      );

      blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        'emits [Loading, Error] when password is incorrect',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenAnswer((_) async => testWallet);

          when(() => mockEncryptionService.decrypt(
                testEncryptedMnemonic,
                testPassword,
              )).thenThrow(Exception('Decryption failed'));

          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ViewSeedPhraseLoading>(),
          isA<ViewSeedPhraseError>()
              .having((state) => state.error, 'error', 'Invalid password'),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verify(() => mockEncryptionService.decrypt(
                testEncryptedMnemonic,
                testPassword,
              )).called(1);
        },
      );

      blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
        'emits [Loading, Error] when wallet repository throws',
        build: () {
          when(() => mockWalletRepository.getCurrentWallet())
              .thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(submitEvent),
        expect: () => [
          isA<ViewSeedPhraseLoading>(),
          isA<ViewSeedPhraseError>().having(
              (state) => state.error, 'error', 'Error decrypting seed phrase'),
        ],
        verify: (_) {
          verify(() => mockWalletRepository.getCurrentWallet()).called(1);
          verifyNever(() => mockEncryptionService.decrypt(any(), any()));
        },
      );
    });
  });
}
