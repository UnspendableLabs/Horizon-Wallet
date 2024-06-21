import 'package:horizon/domain/entities/account.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/wallet.dart';

class HDWalletEntity {
  final Wallet wallet;
  final Account account;
  final Address address;

  HDWalletEntity({required this.wallet, required this.account, required this.address});
}

// TODO not final
class AccountAddressEntity {
  final Account account;
  final Address address;

  AccountAddressEntity({required this.account, required this.address});
}
