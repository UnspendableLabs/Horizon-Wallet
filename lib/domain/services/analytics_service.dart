abstract class AnalyticsService {
  void trackEvent(String eventName, {Map<String, Object>? properties});
  void identify(String userId);
  void reset();
}
