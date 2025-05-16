import 'package:horizon/domain/entities/network.dart';

abstract class PublicKeyService {
  Future<String> fromPrivateKeyAsHex(String privateKey, Network network);
}
