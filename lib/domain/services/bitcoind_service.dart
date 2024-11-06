import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';

abstract class BitcoindService {
  Future<String> sendrawtransaction(String signedHex);
  Future<int> estimateSmartFee({required int confirmationTarget});
  Future<DecodedTx> decoderawtransaction(String raw);
}
