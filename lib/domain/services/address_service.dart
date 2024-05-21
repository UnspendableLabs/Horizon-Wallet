import 'package:uniparty/domain/entities/address.dart';

// TODO: define mnemonic type
abstract class AddressService {
  Future<Address> deriveAddressSegwit(String mnemonic, int index);
  Future<Address> deriveAddressFreewalletBech32(String mnemonic, int index);
  Future<Address> deriveAddressFreewalletLegacy(String mnemonic, int index);
  Future<List<Address>> deriveAddressSegwitRange(String mnemonic, int start, int end);
  Future<List<Address>> deriveAddressFreewalletBech32Range(String mnemonic, int start, int end);
  Future<List<Address>> deriveAddressFreewalletLegacyRange(String mnemonic, int start, int end);
}

