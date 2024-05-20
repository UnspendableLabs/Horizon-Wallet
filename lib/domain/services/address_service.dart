import "package:uniparty/domain/entities/seed_entity.dart";


// TODO: define mnemonic type
abstract class AddressService {
  Future<String> deriveAddressSegwit(String mnemonic, String path);
}

