import 'package:horizon/common/constants.dart';
import 'package:horizon/domain/entities/address.dart';
import 'package:horizon/domain/entities/seed.dart';

enum AddressType { bech32, legacy }

abstract class AddressService {


  
  Future<String> deriveAddressWIP({
    required String path,
    required Seed seed,
  });
  

  Future<Address> deriveAddressSegwit(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index});
  Future<Address> deriveAddressFreewallet(
      {required AddressType type,
      required dynamic root,
      required String accountUuid,
      required String account,
      required String change,
      required int index});
  Future<List<Address>> deriveAddressSegwitRange(
      {required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int start,
      required int end});
  Future<List<Address>> deriveAddressFreewalletRange(
      {required AddressType type,
      required String privKey,
      required String chainCodeHex,
      required String accountUuid,
      required String account,
      required String change,
      required int start,
      required int end});
  Future<String> deriveAddressPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  });
  Future<String> getAddressWIFFromPrivateKey({
    required String rootPrivKey,
    required String chainCodeHex,
    required String purpose,
    required String coin,
    required String account,
    required String change,
    required int index,
    required ImportFormat importFormat,
  });
}
