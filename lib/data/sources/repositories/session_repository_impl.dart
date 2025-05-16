import 'dart:async';
import 'package:horizon/domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final _controller = StreamController<Session>.broadcast();

  @override
  Stream<Session> get stream => _controller.stream.asBroadcastStream();

  @override
  void addToStream(Session session) {
    _controller.add(session);
  }

  void dispose() => _controller.close();
}
