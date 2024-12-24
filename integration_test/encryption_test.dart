import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/services/encryption_service_web_worker_impl.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService Integration Tests -- web worker', () {
    late EncryptionService encryptionService;
    late EncryptionServiceWebWorkerImpl fallbackEncryptionService;

    setUpAll(() async {
      await setup();
      encryptionService = GetIt.instance<EncryptionService>();
      fallbackEncryptionService = EncryptionServiceWebWorkerImpl();
    });

    testWidgets('Encrypt and decrypt with new Argon2 method',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.startsWith('A2::'), isTrue);

      final decrypted = await encryptionService.decrypt(encrypted, password);
      expect(decrypted, originalData);
      await tester.pumpAndSettle();
    });

    testWidgets('Encrypting same data twice produces different results',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted1 =
          await encryptionService.encrypt(originalData, password);
      final encrypted2 =
          await encryptionService.encrypt(originalData, password);

      expect(encrypted1, isNot(equals(encrypted2)));
      await tester.pumpAndSettle();
    });
    testWidgets('Decrypting invalid format throws exception',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));
      const invalidEncrypted = 'A2::InvalidFormat::NotEnoughParts';
      const password = 'somePassword123';

      expect(
          () async =>
              await encryptionService.decrypt(invalidEncrypted, password),
          throwsFormatException);
      await tester.pumpAndSettle();
    });
    testWidgets('Argon2 encryption uses correct memory and parallelism',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));
      const originalData = 'Test data';
      const password = 'testPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.contains('m=65536,t=6,p=4'), true);
      await tester.pumpAndSettle();
    });
  });

  group('EncryptionService Integration Tests -- mainThread worker', () {
    late EncryptionServiceWebWorkerImpl fallbackEncryptionService;

    setUpAll(() async {
      fallbackEncryptionService = EncryptionServiceWebWorkerImpl();
    });

    testWidgets('Encrypt and decrypt with new Argon2 method',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted =
          await fallbackEncryptionService.encrypt(originalData, password);
      expect(encrypted.startsWith('A2::'), isTrue);

      final decrypted =
          await fallbackEncryptionService.decrypt(encrypted, password);
      expect(decrypted, originalData);
      await tester.pumpAndSettle();
    });

    testWidgets('Decrypt legacy encrypted data', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      const originalData = 'Original legacy data';
      const password = 'oldPassword123';

      // Create a legacy encrypted string
      final legacyEncrypted =
          await fallbackEncryptionService.encrypt(originalData, password);

      // Ensure the legacy encrypted string doesn't start with the Argon2 prefix
      expect(legacyEncrypted.startsWith('A2::'), isFalse);

      final decrypted =
          await fallbackEncryptionService.decrypt(legacyEncrypted, password);
      expect(decrypted, originalData);
      await tester.pumpAndSettle();
    });

    testWidgets('Encrypting same data twice produces different results',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));

      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted1 =
          await fallbackEncryptionService.encrypt(originalData, password);
      final encrypted2 =
          await fallbackEncryptionService.encrypt(originalData, password);

      expect(encrypted1, isNot(equals(encrypted2)));
      await tester.pumpAndSettle();
    });
    testWidgets('Decrypting invalid format throws exception',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));
      const invalidEncrypted = 'A2::InvalidFormat::NotEnoughParts';
      const password = 'somePassword123';

      expect(
          () async => await fallbackEncryptionService.decrypt(
              invalidEncrypted, password),
          throwsFormatException);
      await tester.pumpAndSettle();
    });
    testWidgets('Argon2 encryption uses correct memory and parallelism',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp(
        currentVersion: Version(0, 0, 0),
        latestVersion: Version(0, 0, 0),
      ));
      const originalData = 'Test data';
      const password = 'testPassword123';

      final encrypted =
          await fallbackEncryptionService.encrypt(originalData, password);
      expect(encrypted.contains('m=65536,t=6,p=4'), true);
      await tester.pumpAndSettle();
    });
  });
}
