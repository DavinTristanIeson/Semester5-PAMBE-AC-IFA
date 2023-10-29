import 'dart:ui';

import 'package:flutter/material.dart';

extension SetUtilities<T> on Set<T> {
  bool containsAny(Iterable<T> candidates) {
    return candidates.any((element) => contains(element));
  }
}

extension MapUtilities<K, V> on Map<K, V> {
  void addEntry(MapEntry<K, V> entry) {
    this[entry.key] = entry.value;
  }
}

extension IterableUtilities<T> on Iterable<T> {
  T? find(bool Function(T element) fn) {
    return where((element) => fn(element)).firstOrNull;
  }

  bool exists(bool Function(T element) fn) {
    return find(fn) != null;
  }

  List<List<T>> categorize(int? Function(T element) fn, int categoryCount) {
    List<List<T>> categories = List.generate(categoryCount, (index) => []);
    forEach((element) {
      int? index = fn(element);
      if (index == null) return;
      categories[index].add(element);
    });
    return categories;
  }
}

extension DateTimeUtilities on DateTime {
  String _padZero(int timePiece) {
    return timePiece.toString().padLeft(2, '0');
  }

  String toLocaleString() {
    return "${_padZero(day)}/${_padZero(month)}/${_padZero(year)} ${_padZero(hour)}:${_padZero(minute)}";
  }
}

extension BuildContextInheritedValues on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);
  TextTheme get texts => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  NavigatorState get navigator => Navigator.of(this);
}

extension MediaQueryShortcuts on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  double relativeHeight(double ratio, double min, double max) =>
      clampDouble(MediaQuery.of(this).size.height * ratio, min, max);
  double relativeWidth(double ratio, double min, double max) =>
      clampDouble(MediaQuery.of(this).size.width * ratio, min, max);
}
