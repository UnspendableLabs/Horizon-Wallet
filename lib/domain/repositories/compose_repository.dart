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
import 'package:horizon/domain/entities/utxo.dart';

abstract class ComposeRepository {
  Future<ComposeSendResponse> composeSendVerbose(
      num satPerVbyte, List<Utxo> inputsSet, ComposeSendParams params);

  Future<ComposeMpmaSendResponse> composeMpmaSend(
      num satPerVbyte, List<Utxo> inputsSet, ComposeMpmaSendParams params);

  Future<ComposeIssuanceResponseVerbose> composeIssuanceVerbose(
      num satPerVbyte, List<Utxo> inputsSet, ComposeIssuanceParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserVerbose(
      num satPerVbyte, List<Utxo> inputsSet, ComposeDispenserParams params);

  Future<ComposeDispenseResponse> composeDispense(
      num satPerVbyte, List<Utxo> inputsSet, ComposeDispenseParams params);

  Future<ComposeFairmintResponse> composeFairmintVerbose(
      num satPerVbyte, List<Utxo> inputsSet, ComposeFairmintParams params);

  Future<ComposeFairminterResponse> composeFairminterVerbose(
      num satPerVbyte, List<Utxo> inputsSet, ComposeFairminterParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserChain(int exactFee,
      DecodedTx prevDecodedTransaction, ComposeDispenserParams params);

  Future<ComposeOrderResponse> composeOrder(
      num satPerVbyte, List<Utxo> inputsSet, ComposeOrderParams params);

  Future<ComposeCancelResponse> composeCancel(
      num satPerVbyte, List<Utxo> inputsSet, ComposeCancelParams params);

  Future<ComposeAttachUtxoResponse> composeAttachUtxo(
      num satPerVbyte, List<Utxo> inputsSet, ComposeAttachUtxoParams params);

  Future<ComposeDetachUtxoResponse> composeDetachUtxo(
      num satPerVbyte, List<Utxo> inputsSet, ComposeDetachUtxoParams params);

  Future<ComposeMoveToUtxoResponse> composeMoveToUtxo(
      num satPerVbyte, List<Utxo> inputsSet, ComposeMoveToUtxoParams params);

  Future<ComposeDestroyResponse> composeDestroy(
      num satPerVbyte, List<Utxo> inputsSet, ComposeDestroyParams params);

  Future<ComposeDividendResponse> composeDividend(
      num satPerVbyte, List<Utxo> inputsSet, ComposeDividendParams params);

  Future<ComposeSweepResponse> composeSweep(
      num satPerVbyte, List<Utxo> inputsSet, ComposeSweepParams params);

  Future<ComposeBurnResponse> composeBurn(
      num satPerVbyte, List<Utxo> inputsSet, ComposeBurnParams params);
}
