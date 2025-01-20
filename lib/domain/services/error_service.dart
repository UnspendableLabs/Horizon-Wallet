abstract class ErrorService {
  Future<void> initialize();
  void captureException(dynamic exception,
      {String? message, StackTrace? stackTrace, Map<String, dynamic>? context});
  void addBreadcrumb({
    required String type,
    required String category,
    required String message,
    Map<String, dynamic>? data,
  });
}
