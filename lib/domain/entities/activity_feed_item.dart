import 'package:horizon/domain/entities/event.dart';
import 'package:horizon/domain/entities/transaction_info.dart';
import "package:equatable/equatable.dart";

class ActivityFeedItem extends Equatable {
  final String hash;
  final Event? event;
  final TransactionInfo? info;

  const ActivityFeedItem({required this.hash, this.event, this.info});

  @override
  List<Object?> get props => [hash, event, info];
}
