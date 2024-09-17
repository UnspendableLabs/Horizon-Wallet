abstract class BitcoindService {
  Future<String> sendrawtransaction(String signedHex);
  Future<int> estimateSmartFee({required int confirmationTarget});
}
