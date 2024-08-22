import 'package:horizon/domain/entities/address.dart';

enum AddressType { bech32, legacy }

// TODO: define mnemonic type
abstract class AddressService {
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
  // Future<Address> deriveAddressFreewalletLegacy(String mnemonic, int index);
  // Future<List<Address>> deriveAddressSegwitRange(String mnemonic, int start, int end);
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
  // Future<List<Address>> deriveAddressFreewalletLegacyRange(String mnemonic, int start, int end);
  Future<String> deriveAddressPrivateKey(
      {required String rootPrivKey,
      required String chainCodeHex,
      required String purpose,
      required String coin,
      required String account,
      required String change,
      required int index});

  // Future<Address> deriveAddressSegwitPublicKey(
  //     {required String publicKey,
  //     required String purpose,
  //     required String coin,
  //     required String account,
  //     required String change,
  //     required int index});
  //
  // Future<List<Address>> deriveAddressSegwitPublicKeyRange({
  //   required String publicKey,
  //   required String purpose,
  //   required String coin,
  //   required String account,
  //   required String change,
  //   required int start,
  //   required int end,
  // });
}
