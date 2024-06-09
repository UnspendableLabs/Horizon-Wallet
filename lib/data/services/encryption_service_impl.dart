import 'package:encrypt/encrypt.dart';
import 'package:horizon/domain/services/encryption_service.dart';

// Used for password based encryption of WIFs
// TODO: validate againt whatever metamask is doing

class EncryptionServiceImpl implements EncryptionService {
  EncryptionServiceImpl();

  final iv = IV.fromUtf8("pinkhimalyansalt"); // TODO: don't hardcode in source;

  @override
  Future<String> encrypt(String data, String password) async {
    final key = Key.fromUtf8(password);

    final encrypter = Encrypter(AES(key));

    return encrypter.encrypt(data, iv: iv).base64;
  }

  @override
  Future<String> decrypt(String data, String password) async {
    final key = Key.fromUtf8(password);

    final encrypter = Encrypter(AES(key));

    return encrypter.decrypt64(data, iv: iv);
  }
}



