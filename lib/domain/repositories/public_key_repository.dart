abstract class PublicKeyRepository {
  Future<String> fromPrivateKeyAsHex(String privateKey);
}
