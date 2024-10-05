import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/compose_dispenser.dart';
import 'package:horizon/domain/entities/utxo.dart';

abstract class ComposeRepository {
  Future<ComposeSend> composeSendVerbose(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx,
      int? fee,
      int? feeRate,
      List<Utxo>? inputsSet]);
  Future<ComposeIssuanceVerbose> composeIssuanceVerbose(
      String sourceAddress, String name, int quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination,
      bool? unconfirmed,
      int? fee,
      List<Utxo>? inputsSet]);

  Future<ComposeDispenserVerbose> composeDispenserVerbose(
      String sourceAddress,
      String asset,
      int giveQuantity,
      int escrowQuantity,
      int mainchainrate,
      int status,
      [String? openAddress,
      String? oracleAddress,
      bool? allowUnconfirmedTx,
      int? fee,
      List<Utxo>? inputsSet]);
}
