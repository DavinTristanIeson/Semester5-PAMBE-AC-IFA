extension SetUtilities<T> on Set<T> {
  bool containsAny(Iterable<T> candidates) {
    return candidates.any((element) => contains(element));
  }
}
