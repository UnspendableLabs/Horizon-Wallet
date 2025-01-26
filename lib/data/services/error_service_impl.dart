import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/error_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorServiceImpl implements ErrorService {
  final Config config;
  final Logger logger;
  bool _isInitialized = false;

  ErrorServiceImpl(this.config, this.logger);

  @override
  Future<void> initialize() async {
    if (!config.isSentryEnabled || _isInitialized) {
      logger.info('Sentry is not enabled, skipping initialization');
      return;
    }

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = config.sentryDsn;
          options.tracesSampleRate = config.sentrySampleRate;
        },
      );
      _isInitialized = true;
      logger.info('Sentry initialized successfully');
    } catch (e, stack) {
      logger.error('Failed to initialize Sentry', e as Error, stack);
    }
  }

  @override
  Future<void> captureException(dynamic exception,
      {String? message, Map<String, dynamic>? context}) async {
    if (!config.isSentryEnabled || !_isInitialized) return;

    try {
      // Capturing an error breadcrumb allows us to capture the full message, uri, and status code of the failed request before the exception is captured
      await Sentry.addBreadcrumb(
        Breadcrumb(
          type: 'error',
          category: 'error',
          message: message ?? exception.toString(),
          data: context,
        ),
      );
      logger.info('Breadcrumb error added to Sentry');
    } catch (e) {
      logger.error('Failed to add breadcrumb to Sentry', e as Error);
    }

    try {
      final result = await Sentry.captureException(exception);
      logger.info('Exception captured in Sentry: ${result.toString()}');
    } catch (e) {
      logger.error('Failed to capture exception in Sentry', e as Error);
    }
  }

  @override
  void addBreadcrumb({
    required String type,
    required String category,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    if (!config.isSentryEnabled || !_isInitialized) return;

    try {
      await Sentry.addBreadcrumb(
        Breadcrumb(
          type: type,
          category: category,
          message: message,
          data: data,
        ),
      );
      logger.info('Breadcrumb added to Sentry');
    } catch (e) {
      logger.error('Failed to add breadcrumb to Sentry', e as Error);
    }
  }
}
