import 'package:horizon/domain/entities/raw_transaction.dart';

abstract class ComposeRepository {
  Future<RawTransaction> composeSend(String sourceAddress, String destination, String asset, double quantity,
      [bool? allowUnconfirmedTx, int? fee]);
}
