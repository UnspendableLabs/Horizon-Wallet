import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_attach_utxo.dart';
import 'package:horizon/domain/entities/compose_detach_utxo.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_movetoutxo.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/entities/compose_cancel.dart';

import 'package:horizon/domain/entities/utxo.dart';

abstract class ComposeRepository {
  Future<ComposeSendResponse> composeSendVerbose(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeSendParams params);
  Future<ComposeIssuanceResponseVerbose> composeIssuanceVerbose(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeIssuanceParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserVerbose(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeDispenserParams params);

  Future<ComposeDispenseResponse> composeDispense(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeDispenseParams params);

  Future<ComposeFairmintResponse> composeFairmintVerbose(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeFairmintParams params);

  Future<ComposeFairminterResponse> composeFairminterVerbose(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeFairminterParams params);

  Future<ComposeDispenserResponseVerbose> composeDispenserChain(
      int feeRatePerKb,
      DecodedTx prevDecodedTransaction,
      ComposeDispenserParams params);

  Future<ComposeOrderResponse> composeOrder(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeOrderParams params);

  Future<ComposeCancelResponse> composeCancel(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeCancelParams params);

  Future<ComposeAttachUtxoResponse> composeAttachUtxo(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeAttachUtxoParams params);

  Future<int> estimateComposeAttachXcpFees();

  Future<ComposeDetachUtxoResponse> composeDetachUtxo(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeDetachUtxoParams params);

  Future<ComposeMoveToUtxoResponse> composeMoveToUtxo(
      int feeRatePerKb, List<Utxo> inputsSet, ComposeMoveToUtxoParams params);
}
