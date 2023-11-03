import 'dart:async';

class CacheItem<T> {
  final T value;
  final DateTime cachedAt;
  Duration? _staleTime;

  static Duration defaultStaleTime = const Duration(minutes: 2);

  CacheItem({
    required this.value,
    Duration? cacheTime,
    Duration? staleTime,
  })  : cachedAt = DateTime.now(),
        _staleTime = staleTime ?? defaultStaleTime;

  get staleTime => _staleTime;
  get isStale {
    return _staleTime == null ||
        DateTime.now().difference(cachedAt).compareTo(staleTime) >= 0;
  }

  void markStale() {
    _staleTime = null;
  }
}

class CacheClient<T> {
  final Map<String, CacheItem<T>> _cache = {};
  late final Timer timer;
  Duration defaultStaleTime;
  static Duration defaultCleanupInterval = const Duration(minutes: 3);
  CacheClient({Duration? staleTime, Duration? cleanupInterval})
      : defaultStaleTime = staleTime ?? CacheItem.defaultStaleTime {
    timer = Timer.periodic(cleanupInterval ?? defaultCleanupInterval, (timer) {
      cleanupCache();
    });
  }

  void put(
    String key,
    T value, {
    Duration? staleTime,
    Duration? cacheTime,
  }) {
    _cache[key] = CacheItem(
      value: value,
      staleTime: staleTime ?? defaultStaleTime,
    );
  }

  /// Gets non-stale data from the cache. Stale data will be ignored.
  /// Set includeStale to true to include stale data.
  T? get(String key, {bool includeStale = false}) {
    CacheItem<T>? cachedItem = _cache[key];
    return cachedItem == null || (!includeStale && cachedItem.isStale)
        ? null
        : cachedItem.value;
  }

  /// Returns if data is in the cache and not stale
  /// Set includeStale to true to include stale data
  bool has(String key, {bool includeStale = false}) {
    CacheItem? cachedItem = _cache[key];
    return _cache.containsKey(key) && (!cachedItem!.isStale || includeStale);
  }

  /// If ``key`` exists, mark a specific item with that key as stale.
  ///
  /// If ``keys`` exists, mark all items with that key as stale.
  ///
  /// If ``prefix`` exists, Mark all items whose keys start with the specified prefix as stale
  void markStale({Iterable<String>? keys, String? prefix, String? key}) {
    if (key != null) {
      _cache.remove(key);
    }
    if (keys != null) {
      for (final key in keys) {
        _cache.remove(key);
      }
    }
    if (prefix != null) {
      _cache.removeWhere((key, value) => key.startsWith(prefix));
    }
  }

  void clear() {
    _cache.clear();
  }

  void cleanupCache() {
    _cache.removeWhere((key, value) => value.isStale);
  }

  void dispose() {
    _cache.clear();
    timer.cancel();
  }
}
