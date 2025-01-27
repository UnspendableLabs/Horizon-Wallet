import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';

abstract class InactivityMonitorEvent {}

class InactivityMonitorStarted extends InactivityMonitorEvent {}

class InactivityMonitorStopped extends InactivityMonitorEvent {}

class UserActivityDetected extends InactivityMonitorEvent {}

class AppLostFocus extends InactivityMonitorEvent {}

class AppResumed extends InactivityMonitorEvent {}

class InactivityTimeoutTriggered extends InactivityMonitorEvent {}

class AppFocusTimeoutTriggered extends InactivityMonitorEvent {}

class ConfigurationChanged extends InactivityMonitorEvent {
  final Duration? newInactivityTimeout;
  final Duration? newAppLostFocusTimeout;

  ConfigurationChanged(
      {this.newInactivityTimeout, this.newAppLostFocusTimeout});
}

abstract class InactivityMonitorState extends Equatable {}

class Stopped extends InactivityMonitorState {
  @override
  List<Object?> get props => [];
}

class Running extends InactivityMonitorState {
  @override
  List<Object?> get props => [];
}

class TimeoutOut extends InactivityMonitorState {
  @override
  List<Object?> get props => [];
}

class InactivityMonitorBloc
    extends Bloc<InactivityMonitorEvent, InactivityMonitorState> {
  Duration inactivityTimeout;
  Duration appLostFocusTimeout;
  Timer? _inactivityTimer;
  DateTime? _lostFocusTime;

  InactivityMonitorBloc(
      {required this.inactivityTimeout, required this.appLostFocusTimeout})
      : super(Stopped()) {
    on<InactivityMonitorStarted>(_handleStart);
    on<InactivityMonitorStopped>(_handleStop); on<UserActivityDetected>(_handleUserActivityDetected); on<AppLostFocus>(_handleAppLostFocus); on<AppResumed>(_handleAppResumed); on<InactivityTimeoutTriggered>(_handleInactivityTimeoutTriggered); on<AppFocusTimeoutTriggered>(_handleAppFocusTimeout); on<ConfigurationChanged>(_handleConfigurationChanged); }
  _handleStart(
      InactivityMonitorStarted event, Emitter<InactivityMonitorState> emit) {
    emit(Running());
    _startInactivityTimer();
  }

  _handleStop(
      InactivityMonitorStopped event, Emitter<InactivityMonitorState> emit) {
    _cancelInactivityTimer();
    _lostFocusTime = null;
    emit(Stopped());
  }

  _handleUserActivityDetected(
      UserActivityDetected event, Emitter<InactivityMonitorState> emit) {
    if (state is Running) {
      _startInactivityTimer();
    }
  }

  _handleAppLostFocus(
      AppLostFocus event, Emitter<InactivityMonitorState> emit) {
    if (state is Running) {
      _lostFocusTime = DateTime.now();
      _cancelInactivityTimer();
    }
  }

  _handleInactivityTimeoutTriggered(
      InactivityTimeoutTriggered event, Emitter<InactivityMonitorState> emit) {
    emit(TimeoutOut());
    _cancelInactivityTimer();
  }

  void _handleAppFocusTimeout(
    AppFocusTimeoutTriggered event,
    Emitter<InactivityMonitorState> emit,
  ) {
    emit(TimeoutOut());
    _cancelInactivityTimer();
  }

  _handleAppResumed(AppResumed event, Emitter<InactivityMonitorState> emit) {
    if (state is Running && _lostFocusTime != null) {
      final diff = DateTime.now().difference(_lostFocusTime!);
      _lostFocusTime = null;
      if (diff > appLostFocusTimeout) {
        add(AppFocusTimeoutTriggered());
      } else {
        _startInactivityTimer();
      }
    }
  }

  _handleConfigurationChanged(
      ConfigurationChanged event, Emitter<InactivityMonitorState> emit) {
    if (event.newInactivityTimeout != null) {
      inactivityTimeout = event.newInactivityTimeout!;
    }
    if (event.newAppLostFocusTimeout != null) {
      appLostFocusTimeout = event.newAppLostFocusTimeout!;
    }
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  void _startInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(inactivityTimeout, () {
      add(InactivityTimeoutTriggered());
    });
  }

  @override
  Future<void> close() {
    _cancelInactivityTimer();
    return super.close();
  }
}
