import 'package:horizon/domain/entities/account.dart' as entity;
import 'package:horizon/domain/entities/account_service_return.dart';

abstract class AccountService {
  Future<AccountServiceReturn> deriveAccountAndAddress(String mnemonic, entity.Account account);
  Future<AccountServiceReturn> deriveAccountAndAddressFreewalletBech32(String mnemonic, entity.Account account);
}
