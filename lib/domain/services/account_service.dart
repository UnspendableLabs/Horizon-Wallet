import 'package:horizon/domain/entities/account_service_return.dart';

abstract class AccountService {
  Future<AccountServiceReturn> deriveAccountAndAddress(String mnemonic, String purpose, int coinType, int accountIndex);
}
