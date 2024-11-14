import 'package:horizon/domain/entities/bitcoin_decoded_tx.dart';
import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/compose_order.dart';
import 'package:horizon/domain/entities/compose_cancel.dart';

import 'package:horizon/domain/entities/utxo.dart';

abstract class ComposeRepository {
  Future<ComposeSendResponse> composeSendVerbose(
      int fee, List<Utxo> inputsSet, ComposeSendParams params);
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
}
