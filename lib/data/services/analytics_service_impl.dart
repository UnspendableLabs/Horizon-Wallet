import 'package:horizon/core/logging/logger.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'dart:js' as js;
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

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

      js.context.callMethod('eval', [
        '''
        !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.async=!0,p.src=s.api_host+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="capture identify alias people.set people.set_once set_config register register_once unregister opt_out_capturing has_opted_out_capturing opt_in_capturing reset isFeatureEnabled onFeatureFlags getFeatureFlag getFeatureFlagPayload reloadFeatureFlags group updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures getActiveMatchingSurveys getSurveys".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);

        // Custom web vitals handler
        let webVitalsHandler = {
          handleWebVitals: function(metric) {
            posthog.capture('web_vital_' + metric.name, {
              value: metric.value,
              rating: metric.rating,
              distinct_id: crypto.randomUUID(),
              timestamp: Date.now()
            });
          }
        };

        posthog.init('$apiKey', {
          api_host: '$host',
          autocapture: false,
          capture_pageview: false,
          capture_pageleave: false,
          disable_session_recording: true,
          persistence: 'memory',
          bootstrap: {
            distinctID: crypto.randomUUID()
          },
          loaded: function(posthog) {
            posthog._webVitalsHandler = webVitalsHandler;
          }
        });
        '''
      ]);

      _isInitialized = true;
      logger.info('Analytics initialized successfully.');
    } catch (e) {
      logger.error("Error initializing analytics: $e");
    }
  }

  @override
  void trackEvent(String eventName, {Map<String, Object>? properties}) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      await Posthog().capture(eventName: eventName, properties: properties);
      logger.info('Event capture: $eventName, $properties');
    } catch (e) {
      logger.error("Error tracking event: $e");
    }
  }

  @override
  void reset() async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      await Posthog().reset();
      logger.info('Analytics reset.');
    } catch (e) {
      logger.error("Error resetting analytics: $e");
    }
  }

  @override
  void trackAnonymousEvent(String eventName,
      {Map<String, Object>? properties}) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      await Posthog().reset();
      await Posthog().capture(eventName: eventName, properties: properties);
      logger.info('Anonymous event capture: $eventName, $properties');
    } catch (e) {
      logger.error("Error tracking anonymous event: $e");
    }
  }
}
