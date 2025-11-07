import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/compose_burn.dart';
import 'package:horizon/domain/entities/compose_destroy.dart';
import 'package:horizon/domain/entities/compose_detach_utxo.dart';
import 'package:horizon/domain/entities/compose_dividend.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/entities/compose_cancel.dart';
import 'package:horizon/domain/entities/compose_mpma_send.dart';
import 'package:horizon/domain/entities/compose_sweep.dart';
import 'package:horizon/domain/entities/network_error.dart';
import 'package:horizon/domain/entities/utxo.dart';
import 'package:horizon/domain/entities/http_config.dart';
import 'package:fpdart/fpdart.dart';

abstract class ComposeRepository {
  TaskEither<NetworkError, ComposeSendResponse> composeSendVerbose(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeSendParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeMpmaSendResponse> composeMpmaSend(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeMpmaSendParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeIssuanceResponseVerbose>
      composeIssuanceVerbose(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeIssuanceParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDispenserResponseVerbose>
      composeDispenserVerbose(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeDispenserParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDispenseResponse> composeDispense(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeDispenseParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeFairmintResponse> composeFairmintVerbose(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeFairmintParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeFairminterResponse> composeFairminterVerbose(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeFairminterParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDispenserResponseVerbose>
      composeDispenserChain(
    int exactFee,
    DecodedTx prevDecodedTransaction,
    ComposeDispenserParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeOrderResponse> composeOrder(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeOrderParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeCancelResponse> composeCancel(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeCancelParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeAttachUtxoResponse> composeAttachUtxo(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeAttachUtxoParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDetachUtxoResponse> composeDetachUtxo(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeDetachUtxoParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, String> getDetachData({
    required String destination,
    required HttpConfig httpConfig,
  });

  TaskEither<NetworkError, ComposeMoveToUtxoResponse> composeMoveToUtxo(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeMoveToUtxoParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDestroyResponse> composeDestroy(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeDestroyParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeDividendResponse> composeDividend(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeDividendParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeSweepResponse> composeSweep(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeSweepParams params,
    HttpConfig httpConfig,
  );

  TaskEither<NetworkError, ComposeBurnResponse> composeBurn(
    num satPerVbyte,
    List<Utxo> inputsSet,
    ComposeBurnParams params,
    HttpConfig httpConfig,
  );
}
