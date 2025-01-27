abstract class InMemoryKeyRepository {
  Future<String?> get();
  Future<void> set({required String key});
  Future<void> delete();
}
