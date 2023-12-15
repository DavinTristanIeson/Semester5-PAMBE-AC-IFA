import 'dart:async';

import 'package:pambe_ac_ifa/common/context_manager.dart';

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
  Timer? _timer;
  Duration defaultStaleTime;
  static Duration defaultCleanupInterval = const Duration(minutes: 3);
  CacheClient({Duration? staleTime, Duration? cleanupInterval})
      : defaultStaleTime = staleTime ?? CacheItem.defaultStaleTime {
    _timer = Timer.periodic(cleanupInterval ?? defaultCleanupInterval, (timer) {
      cleanupCache();
    });
  }

  void put(
    String key,
    T value, {
    Duration? staleTime,
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
  void markStale(
      {Iterable<String>? keys,
      String? prefix,
      String? key,
      bool Function(String key, CacheItem<T> element)? where}) {
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
    if (where != null) {
      _cache.removeWhere(where);
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
    _timer?.cancel();
  }

  ContextManager get noTimerContext {
    return ContextManager<Timer?>(
        id: "Cache-${_timer.hashCode}-${_cache.hashCode}-NoTimer",
        onOpen: () {
          final tempTimer = _timer;
          _timer = null;
          return Future.value(tempTimer);
        },
        onClose: (initial) async {
          _timer = initial;
        });
  }
}
