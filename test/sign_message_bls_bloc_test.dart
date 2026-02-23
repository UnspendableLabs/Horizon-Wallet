import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:formz/formz.dart';

import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/entities/seed.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/repositories/wallet_config_repository.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/services/bls_service.dart';

import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_bloc.dart';
import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_event.dart';
import 'package:horizon/presentation/forms/sign_message_bls/bloc/sign_message_bls_state.dart';
import 'package:horizon/presentation/common/password_input.dart';

class MockWalletConfigRepository extends Mock
    implements WalletConfigRepository {}

class MockSeedService extends Mock implements SeedService {}

class MockBlsService extends Mock implements BlsService {}

void main() {
  late MockWalletConfigRepository mockWalletConfigRepository;
  late MockSeedService mockSeedService;
  late MockBlsService mockBlsService;

  final testWalletConfig = WalletConfig(
    uuid: 'test-uuid',
    network: Network.mainnet,
    basePath: BasePath.horizon,
    accountIndexEnd: 0,
    seedDerivation: SeedDerivation.bip39MnemonicToSeed,
  );

  final testSeed = Seed(Uint8List.fromList(List.filled(64, 0xAB)));
  const testHttpConfig = Custom(
    network: Network.mainnet,
    counterparty: '',
    esplora: '',
    btcExplorer: '',
    horizonMarket: '',
    horizonMarketApi: '',
    mempoolSpaceApi: '',
  );

  setUpAll(() {
    registerFallbackValue(testWalletConfig);
    registerFallbackValue(InMemoryKey());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockWalletConfigRepository = MockWalletConfigRepository();
    mockSeedService = MockSeedService();
    mockBlsService = MockBlsService();
  });

  SignMessageBLSBloc buildBloc({
    String message = 'Hello BLS',
    String? dst,
    String? messageHex,
    bool passwordRequired = false,
  }) {
    return SignMessageBLSBloc(
      httpConfig: testHttpConfig,
      passwordRequired: passwordRequired,
      message: message,
      dst: dst,
      messageHex: messageHex,
      walletConfigRepository: mockWalletConfigRepository,
      seedService: mockSeedService,
      blsService: mockBlsService,
    );
  }

  group('SignMessageBLSBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc(message: 'Hello BLS', dst: 'custom-dst');
      expect(bloc.state.message, 'Hello BLS');
      expect(bloc.state.dst, 'custom-dst');
      expect(bloc.state.messageHex, isNull);
      expect(bloc.state.password, const PasswordInput.pure());
      expect(bloc.state.submissionStatus, FormzSubmissionStatus.initial);
      expect(bloc.state.signature, isNull);
      expect(bloc.state.publicKey, isNull);
      expect(bloc.state.error, isNull);
    });

    test('initial state is correct with messageHex', () {
      final bloc = buildBloc(message: '', messageHex: 'abcdef');
      expect(bloc.state.message, '');
      expect(bloc.state.messageHex, 'abcdef');
    });

    group('PasswordChanged', () {
      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'emits updated password state',
        build: () => buildBloc(),
        act: (bloc) => bloc.add(PasswordChanged('my-password')),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.password, 'password',
                  const PasswordInput.dirty('my-password'))
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.initial)
              .having((s) => s.error, 'error', isNull),
        ],
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'clears previous error when password changes',
        build: () => buildBloc(),
        seed: () => SignMessageBLSState(
          message: 'Hello BLS',
          submissionStatus: FormzSubmissionStatus.failure,
          error: 'Invalid password',
        ),
        act: (bloc) => bloc.add(PasswordChanged('new-password')),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.error, 'error', isNull)
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.initial),
        ],
      );
    });

    group('SignMessageBLSSubmitted', () {
      void stubSuccessfulSign() {
        when(() => mockWalletConfigRepository.getCurrent())
            .thenAnswer((_) async => testWalletConfig);
        when(() => mockSeedService.getForWalletConfig(
              walletConfig: any(named: 'walletConfig'),
              decryptionStrategy: any(named: 'decryptionStrategy'),
            )).thenAnswer((_) async => testSeed);
        when(() => mockBlsService.signMessage(
              seed: any(named: 'seed'),
              message: any(named: 'message'),
              dst: any(named: 'dst'),
              messageHex: any(named: 'messageHex'),
            )).thenReturn(
          (signature: 'bls-signature-hex', publicKey: 'bls-pubkey-hex'),
        );
      }

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'emits success with signature and publicKey on successful sign (no password)',
        build: () {
          stubSuccessfulSign();
          return buildBloc(message: 'Hello BLS');
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.success)
              .having((s) => s.signature, 'signature', 'bls-signature-hex')
              .having((s) => s.publicKey, 'publicKey', 'bls-pubkey-hex'),
        ],
        verify: (_) {
          final captured = verify(() => mockBlsService.signMessage(
                seed: captureAny(named: 'seed'),
                message: captureAny(named: 'message'),
                dst: captureAny(named: 'dst'),
                messageHex: captureAny(named: 'messageHex'),
              )).captured;
          expect(captured[0], testSeed.bytes);
          expect(captured[1], 'Hello BLS');
          expect(captured[2], isNull);
          expect(captured[3], isNull);
        },
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'passes DST to BlsService when provided',
        build: () {
          stubSuccessfulSign();
          return buildBloc(
            message: 'Hello BLS',
            dst: 'BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_',
          );
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.success),
        ],
        verify: (_) {
          verify(() => mockBlsService.signMessage(
                seed: any(named: 'seed'),
                message: any(named: 'message'),
                dst: 'BLS_SIG_BLS12381G1_XMD:SHA-256_SSWU_RO_NUL_',
                messageHex: any(named: 'messageHex'),
              )).called(1);
        },
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'uses Password decryption strategy when passwordRequired',
        build: () {
          stubSuccessfulSign();
          return buildBloc(
            message: 'Hello BLS',
            passwordRequired: true,
          );
        },
        seed: () => SignMessageBLSState(
          message: 'Hello BLS',
          password: const PasswordInput.dirty('correct-password'),
        ),
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.success),
        ],
        verify: (_) {
          final captured = verify(() => mockSeedService.getForWalletConfig(
                walletConfig: any(named: 'walletConfig'),
                decryptionStrategy:
                    captureAny(named: 'decryptionStrategy'),
              )).captured;
          expect(captured[0], isA<Password>());
          expect((captured[0] as Password).password, 'correct-password');
        },
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'emits failure when wallet config cannot be read',
        build: () {
          when(() => mockWalletConfigRepository.getCurrent())
              .thenThrow(Exception('db error'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.failure)
              .having((s) => s.error, 'error',
                  'invariant: could not read wallet config'),
        ],
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'emits failure with "Invalid password" when seed decryption fails with password',
        build: () {
          when(() => mockWalletConfigRepository.getCurrent())
              .thenAnswer((_) async => testWalletConfig);
          when(() => mockSeedService.getForWalletConfig(
                walletConfig: any(named: 'walletConfig'),
                decryptionStrategy: any(named: 'decryptionStrategy'),
              )).thenThrow(Exception('bad password'));
          return buildBloc(passwordRequired: true);
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.failure)
              .having((s) => s.error, 'error', 'Invalid password'),
        ],
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'passes messageHex to BlsService when provided',
        build: () {
          stubSuccessfulSign();
          return buildBloc(
            message: '',
            messageHex: 'deadbeef0123',
          );
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.success),
        ],
        verify: (_) {
          verify(() => mockBlsService.signMessage(
                seed: any(named: 'seed'),
                message: '',
                dst: any(named: 'dst'),
                messageHex: 'deadbeef0123',
              )).called(1);
        },
      );

      blocTest<SignMessageBLSBloc, SignMessageBLSState>(
        'emits failure when BLS signing throws',
        build: () {
          when(() => mockWalletConfigRepository.getCurrent())
              .thenAnswer((_) async => testWalletConfig);
          when(() => mockSeedService.getForWalletConfig(
                walletConfig: any(named: 'walletConfig'),
                decryptionStrategy: any(named: 'decryptionStrategy'),
              )).thenAnswer((_) async => testSeed);
          when(() => mockBlsService.signMessage(
                seed: any(named: 'seed'),
                message: any(named: 'message'),
                dst: any(named: 'dst'),
                messageHex: any(named: 'messageHex'),
              )).thenThrow(Exception('BLS sign failed'));
          return buildBloc();
        },
        act: (bloc) => bloc.add(SignMessageBLSSubmitted()),
        expect: () => [
          isA<SignMessageBLSState>()
              .having((s) => s.submissionStatus, 'submissionStatus',
                  FormzSubmissionStatus.failure)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );
    });
  });

  group('SignMessageBLSState', () {
    test('copyWith preserves all fields when no arguments given', () {
      final state = SignMessageBLSState(
        message: 'msg',
        dst: 'dst-val',
        password: const PasswordInput.dirty('pw'),
        submissionStatus: FormzSubmissionStatus.success,
        signature: 'sig',
        publicKey: 'pk',
        error: 'err',
      );
      final copy = state.copyWith();
      expect(copy.message, 'msg');
      expect(copy.dst, 'dst-val');
      expect(copy.password, const PasswordInput.dirty('pw'));
      expect(copy.submissionStatus, FormzSubmissionStatus.success);
      expect(copy.signature, 'sig');
      expect(copy.publicKey, 'pk');
      expect(copy.error, 'err');
    });

    test('copyWith can reset error to null', () {
      final state = SignMessageBLSState(
        message: 'msg',
        error: 'previous error',
      );
      final copy = state.copyWith(error: null);
      expect(copy.error, isNull);
    });

    test('copyWith can update individual fields', () {
      final state = SignMessageBLSState(message: 'msg');
      final copy = state.copyWith(
        signature: 'new-sig',
        publicKey: 'new-pk',
        submissionStatus: FormzSubmissionStatus.success,
      );
      expect(copy.signature, 'new-sig');
      expect(copy.publicKey, 'new-pk');
      expect(copy.submissionStatus, FormzSubmissionStatus.success);
      expect(copy.message, 'msg');
    });
  });
}
