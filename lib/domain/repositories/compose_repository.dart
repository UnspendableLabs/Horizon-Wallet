import 'package:horizon/domain/entities/compose_issuance.dart';
import 'package:horizon/domain/entities/raw_transaction.dart';

abstract class ComposeRepository {
  Future<RawTransaction> composeSend(
      String sourceAddress, String destination, String asset, double quantity,
      [bool? allowUnconfirmedTx, int? fee]);
  Future<ComposeIssuance> composeIssuance(
      String sourceAddress, String name, double quantity,
      [bool? divisible,
      bool? lock,
      bool? reset,
      String? description,
      String? transferDestination]);
}
