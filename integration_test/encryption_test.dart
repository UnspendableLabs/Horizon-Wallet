import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/main.dart';
import 'package:horizon/setup.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EncryptionService Integration Tests', () {
    late EncryptionService encryptionService;

    setUpAll(() async {
      await setup();
      encryptionService = GetIt.instance<EncryptionService>();
    });

    testWidgets('Encrypt and decrypt with new Argon2 method',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.startsWith('A2::'), isTrue);

      final decrypted = await encryptionService.decrypt(encrypted, password);
      expect(decrypted, originalData);
      await tester.pumpAndSettle();
    });

    testWidgets('Decrypt legacy encrypted data', (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

      const originalData = 'Original legacy data';
      const password = 'oldPassword123';

      // Create a legacy encrypted string
      final legacyEncrypted = await (encryptionService as EncryptionServiceImpl)
          .encryptLegacy(originalData, password);

      // Ensure the legacy encrypted string doesn't start with the Argon2 prefix
      expect(legacyEncrypted.startsWith('A2::'), isFalse);

      final decrypted =
          await encryptionService.decrypt(legacyEncrypted, password);
      expect(decrypted, originalData);
      await tester.pumpAndSettle();
    });

    testWidgets('Encrypting same data twice produces different results',
        (WidgetTester tester) async {
      await tester.pumpWidget(MyApp());

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
      await tester.pumpWidget(MyApp());
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
      await tester.pumpWidget(MyApp());
      const originalData = 'Test data';
      const password = 'testPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.contains('m=65536,t=6,p=4'), true);
      await tester.pumpAndSettle();
    });
  });
}
