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
      int fee, List<Utxo> inputsSet, ComposeSendParams params);

  Future<ComposeMpmaSendResponse> composeMpmaSend(
      int fee, List<Utxo> inputsSet, ComposeMpmaSendParams params);

  Future<ComposeIssuanceResponseVerbose> composeIssuanceVerbose(
      int fee, List<Utxo> inputsSet, ComposeIssuanceParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserVerbose(
      int fee, List<Utxo> inputsSet, ComposeDispenserParams params);

  Future<ComposeDispenseResponse> composeDispense(
      int fee, List<Utxo> inputsSet, ComposeDispenseParams params);

  Future<ComposeFairmintResponse> composeFairmintVerbose(
      int fee, List<Utxo> inputsSet, ComposeFairmintParams params);

  Future<ComposeFairminterResponse> composeFairminterVerbose(
      int fee, List<Utxo> inputsSet, ComposeFairminterParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserChain(
      int fee, DecodedTx prevDecodedTransaction, ComposeDispenserParams params);

  Future<ComposeOrderResponse> composeOrder(
      int fee, List<Utxo> inputsSet, ComposeOrderParams params);

  Future<ComposeCancelResponse> composeCancel(
      int fee, List<Utxo> inputsSet, ComposeCancelParams params);

  Future<ComposeAttachUtxoResponse> composeAttachUtxo(
      int fee, List<Utxo> inputsSet, ComposeAttachUtxoParams params);

  Future<ComposeDetachUtxoResponse> composeDetachUtxo(
      int fee, List<Utxo> inputsSet, ComposeDetachUtxoParams params);

  Future<ComposeMoveToUtxoResponse> composeMoveToUtxo(
      int fee, List<Utxo> inputsSet, ComposeMoveToUtxoParams params);

  Future<ComposeDestroyResponse> composeDestroy(
      int fee, List<Utxo> inputsSet, ComposeDestroyParams params);

  Future<ComposeDividendResponse> composeDividend(
      int fee, List<Utxo> inputsSet, ComposeDividendParams params);

  Future<ComposeSweepResponse> composeSweep(
      int fee, List<Utxo> inputsSet, ComposeSweepParams params);

  Future<ComposeBurnResponse> composeBurn(
      int fee, List<Utxo> inputsSet, ComposeBurnParams params);
}
