abstract class AnalyticsService {
  void trackEvent(String eventName, {Map<String, Object>? properties});
  void reset();
  void trackAnonymousEvent(String eventName, {Map<String, Object>? properties});
}
