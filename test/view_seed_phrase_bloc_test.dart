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
  const testEncryptedMnemonic = 'encrypted-mnemonic';
  const testDecryptedMnemonic = 'test seed phrase';

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

  group('ViewSeedPhraseBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, isA<ViewSeedPhraseInitial>());
    });

    blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
      'emits error when wallet not found',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet())
            .thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(password: testPassword)),
      expect: () => [
        isA<ViewSeedPhraseLoading>(),
        isA<ViewSeedPhraseError>().having(
          (state) => state.error,
          'error',
          'Wallet not found',
        ),
      ],
    );

    blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
      'emits error when wallet mnemonic not found',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
          (_) async => const Wallet(
            uuid: 'test-uuid',
            name: 'Test Wallet',
            publicKey: 'test-public-key',
            encryptedPrivKey: 'test-encrypted-key',
            encryptedMnemonic: null,
            chainCodeHex: 'test-chain-code-hex',
          ),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(password: testPassword)),
      expect: () => [
        isA<ViewSeedPhraseLoading>(),
        isA<ViewSeedPhraseError>().having(
          (state) => state.error,
          'error',
          'Wallet mnemonic not found',
        ),
      ],
    );

    blocTest<ViewSeedPhraseBloc, ViewSeedPhraseState>(
      'emits error when password is invalid',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
          (_) async => const Wallet(
            uuid: 'test-uuid',
            name: 'Test Wallet',
            publicKey: 'test-public-key',
            encryptedPrivKey: 'test-encrypted-key',
            encryptedMnemonic: testEncryptedMnemonic,
            chainCodeHex: 'test-chain-code-hex',
          ),
        );
        when(() => mockEncryptionService.decrypt(any(), any()))
            .thenThrow(Exception('Invalid password'));
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(password: testPassword)),
      expect: () => [
        isA<ViewSeedPhraseLoading>(),
        isA<ViewSeedPhraseError>().having(
          (state) => state.error,
          'error',
          'Invalid password',
        ),
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
      'successfully decrypts and shows seed phrase',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet()).thenAnswer(
          (_) async => const Wallet(
            uuid: 'test-uuid',
            name: 'Test Wallet',
            publicKey: 'test-public-key',
            encryptedPrivKey: 'test-encrypted-key',
            encryptedMnemonic: testEncryptedMnemonic,
            chainCodeHex: 'test-chain-code-hex',
          ),
        );
        when(() => mockEncryptionService.decrypt(
                testEncryptedMnemonic, testPassword))
            .thenAnswer((_) async => testDecryptedMnemonic);
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(password: testPassword)),
      expect: () => [
        isA<ViewSeedPhraseLoading>(),
        isA<ViewSeedPhraseSuccess>().having(
          (state) => state.seedPhrase,
          'seedPhrase',
          testDecryptedMnemonic,
        ),
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
      'emits error on unexpected exception',
      build: () {
        when(() => mockWalletRepository.getCurrentWallet())
            .thenThrow(Exception('Unexpected error'));
        return bloc;
      },
      act: (bloc) => bloc.add(Submit(password: testPassword)),
      expect: () => [
        isA<ViewSeedPhraseLoading>(),
        isA<ViewSeedPhraseError>().having(
          (state) => state.error,
          'error',
          'Error decrypting seed phrase',
        ),
      ],
      verify: (_) {
        verify(() => mockWalletRepository.getCurrentWallet()).called(1);
      },
    );
  });
}
