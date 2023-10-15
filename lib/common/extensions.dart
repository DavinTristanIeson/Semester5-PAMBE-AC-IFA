import 'dart:ui';

import 'package:flutter/material.dart';

extension SetUtilities<T> on Set<T> {
  bool containsAny(Iterable<T> candidates) {
    return candidates.any((element) => contains(element));
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
