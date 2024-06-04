abstract class BitcoindService {
  Future<void> sendrawtransaction(String signedHex);
}
