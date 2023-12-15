// Untuk type checking saja
class MergedContextsMap {
  Map<String, dynamic> map;
  MergedContextsMap(this.map);
}

class ContextManager<T> {
  String id;
  Future<T> Function() onOpen;
  Future<void> Function(T initial) onClose;
  ContextManager(
      {required this.id, required this.onOpen, required this.onClose});
  Future<TResult> run<TResult>(Future<TResult> Function(T initial) fn) async {
    final initial = await onOpen();
    TResult result;
    try {
      result = await fn(initial);
    } catch (e) {
      await onClose(initial);
      rethrow;
    }
    await onClose(initial);
    return result;
  }

  ContextManager<MergedContextsMap> merge(Iterable<ContextManager> units) {
    final newUnits = units.followedBy([this]);
    return ContextManager<MergedContextsMap>(
        id: id,
        onOpen: () async {
          final initials = <String, dynamic>{};
          for (final unit in newUnits) {
            final entry = await unit.onOpen();
            if (entry is MergedContextsMap) {
              initials.addAll(entry.map);
            } else {
              initials[unit.id] = entry;
            }
          }
          return MergedContextsMap(initials);
        },
        onClose: (merged) async {
          for (final unit in newUnits) {
            await onClose(merged.map[unit.id]);
          }
        });
  }
}
