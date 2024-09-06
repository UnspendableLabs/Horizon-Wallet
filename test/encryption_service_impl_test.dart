import 'package:flutter_test/flutter_test.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import 'package:horizon/data/services/encryption_service_impl.dart';

/**
 * Tests for the [EncryptionServiceImpl] class.
 *
 * THESE ARE ALL SKIPPED AND RECAPITULATED IN INTEGRATION TEST
 * DUE TO ARGON2 SYSTEM DEPENDENCY BUG IN THE FLUTTER LIB
 */

void main() {
  late EncryptionService encryptionService;

  setUp(() {
    encryptionService = EncryptionServiceImpl();
  });

  group('EncryptionServiceImpl Tests', () {
    test('Encrypt and decrypt with new Argon2 method', () async {
      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.startsWith('A2::'), true);
      expect(encrypted.split('::').length, 4);

      final decrypted = await encryptionService.decrypt(encrypted, password);
      expect(decrypted, originalData);
    });

    test('Decrypt legacy encrypted data', () async {
      // Generate a legacy encrypted string for testing
      const originalData = 'Original legacy data';
      const password = 'oldPassword123';

      final legacyEncrypted = await (encryptionService as EncryptionServiceImpl)
          .encryptLegacy(originalData, password);

      expect(legacyEncrypted.startsWith('A2::'), false);

      final decrypted =
          await encryptionService.decrypt(legacyEncrypted, password);
      expect(decrypted, originalData);
    });

    test('Encrypting same data twice produces different results', () async {
      const originalData = 'Sensitive data to encrypt';
      const password = 'strongPassword123';

      final encrypted1 =
          await encryptionService.encrypt(originalData, password);
      final encrypted2 =
          await encryptionService.encrypt(originalData, password);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('Decrypting with wrong password throws exception', () async {
      const originalData = 'Sensitive data to encrypt';
      const correctPassword = 'correctPassword123';
      const wrongPassword = 'wrongPassword123';

      final encrypted =
          await encryptionService.encrypt(originalData, correctPassword);

      expect(
          () async => await encryptionService.decrypt(encrypted, wrongPassword),
          throwsException);
    });

    test('Legacy encryption does not start with Argon2 prefix', () async {
      const originalData = 'Legacy data';
      const password = 'legacyPassword123';

      final encrypted = await (encryptionService as EncryptionServiceImpl)
          .encryptLegacy(originalData, password);

      expect(encrypted.startsWith('A2::'), false);
    });

    test('Argon2 encryption uses correct memory and parallelism', () async {
      const originalData = 'Test data';
      const password = 'testPassword123';

      final encrypted = await encryptionService.encrypt(originalData, password);
      expect(encrypted.contains('m=524288,t=3,p=4'), true);
    });
  }, skip: true);
}
