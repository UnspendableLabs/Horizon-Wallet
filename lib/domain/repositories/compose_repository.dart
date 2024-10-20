import 'package:horizon/domain/entities/compose_fairmint.dart';
import 'package:horizon/domain/entities/compose_fairminter.dart';
import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/compose_dispense.dart';
import 'package:horizon/domain/entities/utxo.dart';

abstract class ComposeRepository {
  Future<ComposeSend> composeSendVerbose(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx,
      int? fee,
      int? feeRate,
      List<Utxo>? inputsSet]);
  Future<ComposeIssuanceResponseVerbose> composeIssuanceVerbose(
      String sourceAddress, String name, int quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination,
      bool? unconfirmed,
      int? fee,
      List<Utxo>? inputsSet]);

  Future<ComposeDispenserResponseVerbose> composeDispenserVerbose(
      int fee, List<Utxo> inputsSet, ComposeDispenserParams params);

  Future<ComposeDispenseResponse> composeDispense(
      int fee, List<Utxo> inputsSet, ComposeDispenseParams params);

  Future<ComposeFairmintResponse> composeFairmintVerbose(
      int fee, List<Utxo> inputsSet, ComposeFairmintParams params);

  Future<ComposeFairminterResponse> composeFairminterVerbose(
      int fee, List<Utxo> inputsSet, ComposeFairminterParams params);
}
