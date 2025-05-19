import 'package:fpdart/fpdart.dart';
import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';

import 'package:horizon/domain/entities/http_config.dart';

abstract class BitcoindService {
  Future<String> sendrawtransaction(String signedHex, HttpConfig httpConfig);
  Future<int> estimateSmartFee(
      {required int confirmationTarget, required HttpConfig httpConfig});
  Future<DecodedTx> decoderawtransaction(String raw, HttpConfig httpConfig);
}

extension BitcoindServiceX on BitcoindService {
  TaskEither<String, String> sendrawtransactionT({
    required String signedHex,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => sendrawtransaction(signedHex, httpConfig),
      onError,
    );
  }

  TaskEither<String, int> estimateSmartFeeT({
    required int confirmationTarget,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => estimateSmartFee(
        confirmationTarget: confirmationTarget,
        httpConfig: httpConfig,
      ),
      onError,
    );
  }

  TaskEither<String, DecodedTx> decoderawtransactionT({
    required String raw,
    required HttpConfig httpConfig,
    required String Function(Object error, StackTrace stack) onError,
  }) {
    return TaskEither.tryCatch(
      () => decoderawtransaction(raw, httpConfig),
      onError,
    );
  }
}
