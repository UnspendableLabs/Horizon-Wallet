abstract class InMemoryKeyRepository {
  Future<String?> get();
  Future<void> set({required String key});
  Future<Map<String, String>> getMap();
  Future<void> setMap({required Map<String, String> map});
  Future<void> delete();
}
