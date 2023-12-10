import 'dart:ui';

import 'package:pambe_ac_ifa/common/extensions.dart';

enum PreferredLanguage {
  english("English"),
  indonesia("Bahasa Indonesia");

  final String label;
  const PreferredLanguage(this.label);
  ({String label, String value}) get selectOption {
    return (label: label, value: name);
  }

  Locale get locale {
    return switch (this) {
      PreferredLanguage.english => const Locale("en", "US"),
      PreferredLanguage.indonesia => const Locale("id", "ID"),
    };
  }

  factory PreferredLanguage.fromString(String? string) {
    return values.find((element) => element.name == string) ??
        PreferredLanguage.english;
  }
}

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen'),
  preferredLanguage('preferredLanguage');

  final String key;
  const AcSharedPrefKeys(this.key);
}
