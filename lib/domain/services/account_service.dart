import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/services/encryption_service.dart';

// TODO: define mnemonic type
abstract class AccountService {
  EncryptionService encryptionService;

  AccountService(this.encryptionService);

  Future<Account> deriveRoot(String mnemonic, String password);
  Future<Account> deriveRootFreewallet(String mnemonic, String password);
}
