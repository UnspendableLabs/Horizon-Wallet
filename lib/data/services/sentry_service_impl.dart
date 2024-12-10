import 'package:horizon/core/logging/logger.dart';
import 'package:horizon/domain/repositories/config_repository.dart';
import 'package:horizon/domain/services/sentry_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class SentryServiceImpl implements SentryService {
  final Config config;
  final Logger logger;
  bool _isInitialized = false;

  SentryServiceImpl(this.config, this.logger);

  @override
  Future<void> initialize() async {
    if (!config.isSentryEnabled || _isInitialized) return;

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
  void captureException(dynamic exception, {StackTrace? stackTrace}) {
    if (!config.isSentryEnabled || !_isInitialized) return;

    try {
      Sentry.captureException(exception, stackTrace: stackTrace);
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
  }) {
    if (!config.isSentryEnabled || !_isInitialized) return;

    try {
      Sentry.addBreadcrumb(
        Breadcrumb(
          type: type,
          category: category,
          message: message,
          data: data,
        ),
      );
    } catch (e) {
      logger.error('Failed to add breadcrumb to Sentry', e as Error);
    }
  }
}
