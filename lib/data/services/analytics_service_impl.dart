@JS('posthog')
library;

import 'dart:js_interop';

import 'package:horizon/core/logging/logger.dart';

import 'package:horizon/js/crypto.dart';
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

@JS("posthog.init")
external void posthogInit(String apiKey, JSObject config);

@JS("posthog.capture")
external void posthogCapture(String eventName, JSObject properties);

@JS("posthog.reset")
external void posthogReset();

// PostHog Web Implementation
class PostHogWebAnalyticsService implements AnalyticsService {
  final Config config;
  final String? apiKey;
  final String? host;
  final Logger logger;

  bool _isInitialized = false;

  PostHogWebAnalyticsService(this.config, this.apiKey, this.host, this.logger) {
    _initialize();
  }

  void _initialize() {
    try {
      if (!config.isAnalyticsEnabled) {
        logger.info('Analytics is disabled. Skipping initialization.');
        return;
      }

      if (_isInitialized) {
        logger.info('Analytics already initialized. Skipping.');
        return;
      }
      if (apiKey == null || host == null) {
        logger.info(
            'Posthog configuration missing. Analytics initialization failed.');
        return;
      }
      posthogInit(
          apiKey!,
          ({
            "api_host": host,
            "autocapture": false,
            "capture_pageview": false,
            "capture_pageleave": false,
            "disable_session_recording": true,
            "persistence": 'memory',
            "bootstrap": {"distinctID": randomUUID()},
          }).jsify() as JSObject);

      _isInitialized = true;
      logger.info('Analytics initialized successfully.');
    } catch (e, callstack) {
      logger.error("Error initializing analytics: $e", null, callstack);
    }
  }

  @override
  void trackEvent(String eventName, {Map<String, Object>? properties}) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;

    try {
      posthogCapture(
          eventName,
          ({
            "distinct_id": properties?["distinct_id"],
          }).jsify() as JSObject);
    } catch (e, callstack) {
      logger.error("Error tracking event: $e", null, callstack);
    }
  }

  @override
  void reset() async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      posthogReset();
      logger.info('Analytics reset.');
    } catch (e, callstack) {
      logger.error("Error resetting analytics: $e", null, callstack);
    }
  }

  @override
  void trackAnonymousEvent(String eventName,
      {Map<String, Object>? properties}) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;

    try {
      posthogReset();
      posthogCapture(
          eventName,
          ({
            "distinct_id": properties?["distinct_id"],
          }).jsify() as JSObject);
      logger.info('Anonymous event capture: $eventName, $properties');
    } catch (e, callstack) {
      logger.error("Error tracking anonymous event: $e", null, callstack);
    }
  }
}
