import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';

class ActivityFeedItem {
  String hash;
  Event? event;
  TransactionInfo? info;

  ActivityFeedItem(
      {required this.hash, this.event,  this.info});
}
