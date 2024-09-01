import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/compose_send.dart';
import 'package:horizon/domain/entities/raw_transaction.dart';

abstract class ComposeRepository {
  Future<RawTransaction> composeSend(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx, int? fee]);
  Future<ComposeSend> composeSendVerbose(
      String sourceAddress, String destination, String asset, int quantity,
      [bool? allowUnconfirmedTx, int? fee]);
  Future<ComposeIssuance> composeIssuance(
      String sourceAddress, String name, double quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination]);
  Future<ComposeIssuanceVerbose> composeIssuanceVerbose(
      String sourceAddress, String name, double quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination,
      bool? unconfirmed,
      int? fee]);
}
