import 'package:horizon/data/services/encryption_service_impl.dart';
import 'package:test/test.dart';

void main() {
  test("sanity", () async {
    final EncryptionServiceImpl encryptionService = EncryptionServiceImpl();
    const password = "neutralonamovingtrain?";
    const data = "top secret";
    final encrypted = await encryptionService.encrypt(data, password);
    final decrypted = await encryptionService.decrypt(encrypted, password);
    expect(decrypted, data);
  });
}
