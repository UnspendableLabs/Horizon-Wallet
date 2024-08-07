sealed class Failure {
  final String message;
  const Failure({required this.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({ String? message }) : super(message: message ?? 'Network Failure');
}

class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure({String? message, required this.statusCode})
      : super(message: message ?? 'Server Failure');
}
