abstract class SentryService {
  Future<void> initialize();
  void captureException(dynamic exception, {StackTrace? stackTrace});
  void addBreadcrumb({
    required String type,
    required String category,
    required String message,
    Map<String, dynamic>? data,
  });
}
