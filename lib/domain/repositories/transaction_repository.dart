import 'package:horizon/domain/entities/counterparty_reveal.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import 'package:horizon/domain/entities/transaction_unpacked.dart';
import 'package:horizon/domain/entities/http_config.dart';

abstract class TransactionRepository {
  Future<TransactionUnpacked> unpack(
      {required String raw, required HttpConfig httpConfig});

  /// Decodes Counterparty message bytes (hex) with the node, keeping the
  /// fields of any message type. The node strips a leading `CNTRPRTY` prefix
  /// before it unpacks the message.
  Future<CounterpartyMessage> unpackMessage(
      {required String datahex, required HttpConfig httpConfig});
  Future<TransactionInfo> getInfo(
      {required String raw, required HttpConfig httpConfig});
}
