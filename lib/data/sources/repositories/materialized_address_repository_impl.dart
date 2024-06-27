import 'package:horizon/domain/repositories/materialized_address_repository.dart';
import 'package:horizon/domain/repositories/wallet_repository.dart';
import 'package:horizon/domain/services/address_service.dart';
import 'package:horizon/domain/services/encryption_service.dart';
import "package:horizon/domain/entities/account.dart";
import "package:horizon/domain/entities/address.dart";
import 'package:get_it/get_it.dart';

class MaterializedAddressRepositoryImpl
    implements MaterializedAddressRepository {
  AddressService _addressService = GetIt.I.get<AddressService>();
  WalletRepository _walletRepository = GetIt.I.get<WalletRepository>();
  final encryptionService = GetIt.I<EncryptionService>();

  @override
  Future<List<Address>> getAddresses(Account account, int gapLimit, [bool change  = false]) async {
    final wallet = await _walletRepository.getCurrentWallet();

    if (wallet == null) {
      throw Exception("invariant: wallet is null");
    }



    final decryptedPrivKey = await encryptionService.decrypt(
        wallet.encryptedPrivKey, "UXGmJfeqoLXKGKk9tdk26hQvwIRpI6vm");

    return _addressService.deriveAddressSegwitRange(
        privKey: decryptedPrivKey,
        chainCodeHex: wallet.chainCodeHex,
        accountUuid: account.uuid,
        purpose: account.purpose,
        coin: account.coinType,
        account: account.accountIndex,
        change: change ? "1" : "0",
        start: 0,
        end: gapLimit - 1);
  }
}
