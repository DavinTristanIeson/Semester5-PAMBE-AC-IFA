import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:test/test.dart';

void main() {
  const testKey = "TestKey";
  test('Cache Client should store and get values according to its key.', () {
    final cache = CacheClient();
    expect(cache.get(testKey), null);
    expect(cache.has(testKey), false);

    cache.put(testKey, 1);
    expect(cache.get(testKey), 1);
    expect(cache.has(testKey), true);
  });

  test(
      "Null values should be treated as proper values. .has() should return true.",
      () {
    final cache = CacheClient();
    cache.put(testKey, null);
    expect(cache.get(testKey), null);
    expect(cache.has(testKey), true);
  });

  group("Mark stale should remove the specified keys from the cache", () {
    test("Key option should only remove one entry from the cache", () {
      final cache = CacheClient();
      cache.put("Test Key 1", true);
      cache.put("Test Key 2", false);
      cache.markStale(key: "Test Key 1");
      expect(cache.has("Test Key 1"), false);
      expect(cache.has("Test Key 2"), true);
    });

    test(
        "Keys option should only remove multiple specific entries from the cache",
        () {
      final cache = CacheClient();
      cache.put("Test Key 1", true);
      cache.put("Test Key 2", true);
      cache.markStale(keys: ["Test Key 1", "Test Key 2"]);
      expect(cache.has("Test Key 1"), false);
      expect(cache.has("Test Key 2"), false);
    });

    test(
        "Prefix option should remove all entries whose keys start with the prefix from the cache",
        () {
      final cache = CacheClient();
      cache.put("Test Key 1", true);
      cache.put("Test Key 2", true);
      cache.put("Different Key", true);
      cache.markStale(prefix: "Test Key");
      expect(cache.has("Test Key 1"), false);
      expect(cache.has("Test Key 2"), false);
      expect(cache.has("Different Key"), true);
    });
  });

  test("When values are stale, they should no longer be available.", () async {
    const staleTime = Duration(milliseconds: 500);
    final cache = CacheClient(staleTime: staleTime);
    cache.put(testKey, true);
    expect(cache.has(testKey), true);
    await Future.delayed(staleTime);
    expect(cache.has(testKey), false);
  });

  test("When values are stale, they should no longer be available.", () async {
    const staleTime = Duration(milliseconds: 500);
    final cache = CacheClient(staleTime: staleTime);
    cache.put(testKey, true);
    expect(cache.has(testKey), true);
    await Future.delayed(staleTime);
    expect(cache.has(testKey), false);
  });
}
