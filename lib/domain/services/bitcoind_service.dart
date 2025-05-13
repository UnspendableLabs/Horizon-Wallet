import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';

import 'package:horizon/domain/entities/http_config.dart';

abstract class BitcoindService {
  Future<String> sendrawtransaction(String signedHex, HttpConfig httpConfig);
  Future<int> estimateSmartFee(
      {required int confirmationTarget, required HttpConfig httpConfig});
  Future<DecodedTx> decoderawtransaction(String raw, HttpConfig httpConfig);
}
