import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:horizon/domain/entities/base_path.dart';
import 'package:horizon/domain/entities/decryption_strategy.dart';
import 'package:horizon/domain/entities/network.dart';
import 'package:horizon/domain/entities/seed_derivation.dart';
import 'package:horizon/domain/entities/wallet_config.dart';
import 'package:horizon/domain/services/bls_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/domain/services/seed_service.dart';
import 'package:horizon/domain/usecases/export_encrypted_bls_private_key.dart';

// VM tests: kIsWeb is false, so only the unsupported path is covered here.
// A full encrypt/export round-trip should be covered in web integration tests.

class MockSeedService extends Mock implements SeedService {}

class MockBlsService extends Mock implements BlsService {}

class MockEncryptionService extends Mock implements EncryptionService {}

void main() {
  const expectedUnsupportedMessage =
      'Exporting an encrypted BLS private key is only supported on web.';

  late MockSeedService mockSeedService;
  late MockBlsService mockBlsService;
  late MockEncryptionService mockEncryptionService;

  final testWalletConfig = WalletConfig(
    uuid: 'test-uuid',
    network: Network.mainnet,
    basePath: BasePath.horizon,
    accountIndexEnd: 0,
    seedDerivation: SeedDerivation.bip39MnemonicToSeed,
  );

  final testParams = ExportEncryptedBlsPrivateKeyParams(
    walletConfig: testWalletConfig,
    decryptionStrategy: Password('export-password'),
    exportPassword: 'export-password',
    network: Network.mainnet,
    accountIndex: 0,
  );

  setUpAll(() {
    registerFallbackValue(testWalletConfig);
    registerFallbackValue(Password(''));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockSeedService = MockSeedService();
    mockBlsService = MockBlsService();
    mockEncryptionService = MockEncryptionService();
  });

  group('ExportEncryptedBlsPrivateKeyUseCase', () {
    test(
      'throws UnsupportedError on VM (kIsWeb is false); message matches web-only contract',
      () async {
        final useCase = ExportEncryptedBlsPrivateKeyUseCase(
          seedService: mockSeedService,
          blsService: mockBlsService,
          encryptionService: mockEncryptionService,
        );

        await expectLater(
          useCase(testParams),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              expectedUnsupportedMessage,
            ),
          ),
        );
      },
    );

    test(
      'does not call seed, BLS, or encryption services when unsupported',
      () async {
        final useCase = ExportEncryptedBlsPrivateKeyUseCase(
          seedService: mockSeedService,
          blsService: mockBlsService,
          encryptionService: mockEncryptionService,
        );

        await expectLater(useCase(testParams), throwsUnsupportedError);

        verifyNever(() => mockSeedService.getForWalletConfig(
              walletConfig: any(named: 'walletConfig'),
              decryptionStrategy: any(named: 'decryptionStrategy'),
            ));
        verifyNever(() => mockBlsService.derivePrivateKey(any(),
              network: any(named: 'network'),
              accountIndex: any(named: 'accountIndex')));
        verifyNever(() => mockEncryptionService.encrypt(any(), any()));
      },
    );
  });
}
