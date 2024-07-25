import "package:equatable/equatable.dart";

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

class Load extends DashboardActivityFeedEvent {
  const Load();
}

class Reload extends DashboardActivityFeedEvent {
  const Reload();
}

class ForceLoad extends DashboardActivityFeedEvent {
  const ForceLoad();
}
