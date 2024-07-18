abstract class BitcoindService {
  Future<String> sendrawtransaction(String signedHex);
}
