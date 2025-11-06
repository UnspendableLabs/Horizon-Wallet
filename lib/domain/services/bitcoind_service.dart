import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';

import 'package:horizon/domain/entities/http_config.dart';
import 'package:horizon/domain/entities/network_error.dart';

abstract class BitcoindService {
  TaskEither<NetworkError, String> sendrawtransaction(
    String signedHex,
    HttpConfig httpConfig,
  );
  TaskEither<NetworkError, int> estimateSmartFee({
    required int confirmationTarget,
    required HttpConfig httpConfig,
  });
  TaskEither<NetworkError, DecodedTx> decoderawtransaction({
    required String raw,
    required HttpConfig httpConfig,
  });
}
