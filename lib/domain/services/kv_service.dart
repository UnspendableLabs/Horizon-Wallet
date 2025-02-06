abstract class KVService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> remove(String key);

  Future<void> clear();
}

