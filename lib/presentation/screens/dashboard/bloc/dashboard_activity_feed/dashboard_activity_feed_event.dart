import "package:equatable/equatable.dart";
import 'package:horizon/domain/entities/address.dart';

abstract class DashboardActivityFeedEvent extends Equatable {
  const DashboardActivityFeedEvent();
  @override
  List<Object> get props => [];
}

class StartPolling extends DashboardActivityFeedEvent {
  final Duration interval;
  const StartPolling({required this.interval});
}

class StopPolling extends DashboardActivityFeedEvent {
  const StopPolling();
}

/* 
*   Used when
*
*   1) initial load 
*   2) user submits a new transaction
*   3) user pulls to refresh
*
*/
class Load extends DashboardActivityFeedEvent {
  const Load();
}

/* 
*   Used when
*
*   1) user scrolls to the bottom of the list
*
*   note: is append only
*/
//
// class LoadMore extends DashboardActivityFeedEvent {
//   const LoadMore();
// }

/* 
*   Used when
*
*   1) bloc polls for new data 
*
*   note: displays "N more transactions" at top of feed
*
*/
class LoadQuiet extends DashboardActivityFeedEvent {
  const LoadQuiet();
}
