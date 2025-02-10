import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:horizon/core/logging/logger.dart';

import 'package:horizon/domain/services/secure_kv_service.dart';
import 'dart:async';
import 'package:horizon/common/constants.dart';

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

// TODO: move to shared constants

class InactivityMonitorBloc
    extends Bloc<InactivityMonitorEvent, InactivityMonitorState> {
  final Logger logger;
  final SecureKVService kvService;
  final Duration inactivityTimeout;
  Timer? _inactivityTimer;

  DateTime? _deadlineTime;

  InactivityMonitorBloc({
    required this.kvService,
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
  ) async {
    logger.debug('Received InactivityMonitorStarted event.');

    try {
      // we should never really hit this case becasuse we check this deadline when
      // initializing session

      final storedDeadlineString =
          await kvService.read(key: kInactivityDeadlineKey);
      logger.debug(
          "InactivityMonitorBloc: stored deadline: $storedDeadlineString");

      if (storedDeadlineString != null && storedDeadlineString.isNotEmpty) {
        final storedDeadline = DateTime.tryParse(storedDeadlineString);
        if (storedDeadline != null) {
          _deadlineTime = storedDeadline;

          // If the deadline is already in the past, trigger a timeout right away.
          if (DateTime.now().isAfter(_deadlineTime!)) {
            add(InactivityTimeoutTriggered());
            return;
          }
        }
      }
    } catch (e) {
      logger.error('Error reading inactivity deadline: $e');
    }

    emit(Running());
    logger.debug('InactivityMonitorBloc state changed to Running.');

    _setDeadline();
    _startInactivityTimer();
  }

  void _handleStop(
    InactivityMonitorStopped event,
    Emitter<InactivityMonitorState> emit,
  ) {
    logger.debug('Received InactivityMonitorStopped event.');
    _cancelInactivityTimer();
    _clearDeadline();
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
      _setDeadline();
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
    if (state is Running && _deadlineTime != null) {
      if (DateTime.now().isAfter(_deadlineTime!)) {
        logger.debug('App resumed after inactivity timeout.');
        add(InactivityTimeoutTriggered());
        return;
      } else {
        logger.debug('App resumed before inactivity timeout.');

        _startInactivityTimer();
      }
    } else {
      logger.debug(
        'App resumed, but state is not Running or _deadlineTime is null.',
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
    _clearDeadline();
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

  void _setDeadline() {
    _deadlineTime = DateTime.now().add(inactivityTimeout);
    kvService.write(
        key: kInactivityDeadlineKey, value: _deadlineTime!.toIso8601String());
  }

  /// Clears the persisted deadline from local storage.
  void _clearDeadline() {
    _deadlineTime = null;
    kvService.delete(key: kInactivityDeadlineKey);
  }
}
