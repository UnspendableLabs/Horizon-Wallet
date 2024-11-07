import 'package:logger/logger.dart';
import 'dart:js' as js;
import 'package:horizon/domain/services/analytics_service.dart';
import 'package:horizon/domain/repositories/config_repository.dart';

var logger = Logger();

// PostHog Web Implementation
class PostHogWebAnalyticsService implements AnalyticsService {
  final Config config;
  final String? apiKey;
  final String? host;
  bool _isInitialized = false;

  PostHogWebAnalyticsService(this.config, this.apiKey, this.host) {
    _initialize();
  }

  void _initialize() {
    try {
      if (!config.isAnalyticsEnabled) {
        logger.i('Analytics is disabled. Skipping initialization.');
        return;
      }

      if (_isInitialized) {
        logger.i('Analytics already initialized. Skipping.');
        return;
      }

      if (apiKey == null) {
        logger
            .e('Posthog API Key is missing. Analytics initialization failed.');
        return;
      }

      if (host == null) {
        logger.e('Posthog host is missing. Analytics initialization failed.');
        return;
      }

      js.context.callMethod('eval', [
        '''
      !function(t,e){var o,n,p,r;e.__SV||(window.posthog=e,e._i=[],e.init=function(i,s,a){function g(t,e){var o=e.split(".");2==o.length&&(t=t[o[0]],e=o[1]),t[e]=function(){t.push([e].concat(Array.prototype.slice.call(arguments,0)))}}(p=t.createElement("script")).type="text/javascript",p.async=!0,p.src=s.api_host+"/static/array.js",(r=t.getElementsByTagName("script")[0]).parentNode.insertBefore(p,r);var u=e;for(void 0!==a?u=e[a]=[]:a="posthog",u.people=u.people||[],u.toString=function(t){var e="posthog";return"posthog"!==a&&(e+="."+a),t||(e+=" (stub)"),e},u.people.toString=function(){return u.toString(1)+".people (stub)"},o="capture identify alias people.set people.set_once set_config register register_once unregister opt_out_capturing has_opted_out_capturing opt_in_capturing reset isFeatureEnabled onFeatureFlags getFeatureFlag getFeatureFlagPayload reloadFeatureFlags group updateEarlyAccessFeatureEnrollment getEarlyAccessFeatures getActiveMatchingSurveys getSurveys".split(" "),n=0;n<o.length;n++)g(u,o[n]);e._i.push([i,s,a])},e.__SV=1)}(document,window.posthog||[]);
      posthog.init('$apiKey', {api_host: '$host'});
      '''
      ]);

      _isInitialized = true;
      logger.i('Analytics initialized successfully.');
    } catch (e) {
      logger.e("Error initializing analytics: $e");
    }
  }

  @override
  void trackEvent(String eventName, {Map<String, Object>? properties}) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      js.context.callMethod('posthog.capture', [eventName, properties]);
      logger.i('Event capture: $eventName, $properties');
    } catch (e) {
      logger.e("Error tracking event: $e");
    }
  }

  @override
  void identify(String userId) async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      js.context.callMethod('posthog.identify', [userId]);
      logger.i('User identified: $userId');
    } catch (e) {
      logger.e("Error identifying user: $e");
    }
  }

  @override
  void reset() async {
    if (!config.isAnalyticsEnabled || !_isInitialized) return;
    try {
      js.context.callMethod('posthog.reset');
      logger.d('Analytics reset.');
    } catch (e) {
      logger.e("Error resetting analytics: $e");
    }
  }
}
