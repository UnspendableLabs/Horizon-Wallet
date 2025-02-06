import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:horizon/core/logging/logger.dart';
import 'dart:async';

abstract class InactivityMonitorEvent {}

class InactivityMonitorStarted extends InactivityMonitorEvent {}

class InactivityMonitorStopped extends InactivityMonitorEvent {}

class UserActivityDetected extends InactivityMonitorEvent {}

class AppLostFocus extends InactivityMonitorEvent {}

class AppResumed extends InactivityMonitorEvent {}

class InactivityTimeoutTriggered extends InactivityMonitorEvent {}

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

class InactivityMonitorBloc extends Bloc<InactivityMonitorEvent, InactivityMonitorState> {
  final Logger logger;
  final Duration inactivityTimeout;
  Timer? _inactivityTimer;
  DateTime? _lostFocusTime;

  InactivityMonitorBloc({
    required this.logger,
    required this.inactivityTimeout,
  }) : super(Stopped()) {
    on<InactivityMonitorStarted>(_handleStart);
    on<InactivityMonitorStopped>(_handleStop);
    on<UserActivityDetected>(_handleUserActivityDetected);
    on<AppLostFocus>(_handleAppLostFocus);
    on<AppResumed>(_handleAppResumed);
    on<InactivityTimeoutTriggered>(_handleInactivityTimeoutTriggered);
  }

  void _handleStart(
    InactivityMonitorStarted event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received InactivityMonitorStarted event.');
    emit(Running());
    logger.debug('InactivityMonitorBloc state changed to Running.');
    _startInactivityTimer();
  }

  void _handleStop(
    InactivityMonitorStopped event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received InactivityMonitorStopped event.');
    _cancelInactivityTimer();
    _lostFocusTime = null;
    emit(Stopped());
    logger.debug('InactivityMonitorBloc state changed to Stopped.');
  }

  void _handleUserActivityDetected(
    UserActivityDetected event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received UserActivityDetected event.');
    if (state is Running) {
      logger.debug('Resetting inactivity timer due to user activity.');
      _startInactivityTimer();
    } else {
      logger.debug(
        'User activity detected, but monitor is not in Running state.',
      );
    }
  }

  void _handleAppLostFocus(
    AppLostFocus event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received AppLostFocus event.');
    if (state is Running) {
      logger.debug('Cancelling inactivity timer and recording lostFocusTime.');
      _lostFocusTime = DateTime.now();
      _cancelInactivityTimer();
    } else {
      logger.debug('App lost focus, but monitor is not in Running state.');
    }
  }

  void _handleAppResumed(
    AppResumed event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received AppResumed event.');
    if (state is Running && _lostFocusTime != null) {
      final diff = DateTime.now().difference(_lostFocusTime!);
      logger.debug(
        'Time since app lost focus: ${diff.inSeconds}s (limit: ${inactivityTimeout.inSeconds}s).',
      );
      _lostFocusTime = null;

      // Use the same inactivity timeout check:
      if (diff > inactivityTimeout) {
        logger.debug('Lost focus duration exceeded inactivityTimeout.');
        add(InactivityTimeoutTriggered());
      } else {
        logger.debug(
          'Lost focus duration did not exceed timeout; restarting inactivity timer.',
        );
        _startInactivityTimer();
      }
    } else {
      logger.debug(
        'App resumed, but state is not Running or _lostFocusTime is null.',
      );
    }
  }

  void _handleInactivityTimeoutTriggered(
    InactivityTimeoutTriggered event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug(
      'InactivityTimeoutTriggered: No user activity or app focus for $inactivityTimeout.',
    );
    emit(TimeoutOut());
    logger.debug('InactivityMonitorBloc state changed to TimeoutOut.');
    _cancelInactivityTimer();
  }

  void _startInactivityTimer() {
    _cancelInactivityTimer();
    _inactivityTimer = Timer(inactivityTimeout, () {
      add(InactivityTimeoutTriggered());
    });
  }

  void _cancelInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
  }

  @override
  Future<void> close() {
    _cancelInactivityTimer();
    return super.close();
  }
}

