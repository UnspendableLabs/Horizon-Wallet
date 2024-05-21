import 'package:uniparty/domain/entities/address.dart';

// TODO: define mnemonic type
abstract class AddressService {
  Future<Address> deriveAddressSegwit(String mnemonic, String path);
  Future<Address> deriveAddressFreewalletBech32(String mnemonic, int index);
  Future<Address> deriveAddressFreewalletLegacy(String mnemonic, int index);
}

