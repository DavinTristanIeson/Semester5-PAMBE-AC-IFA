import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/shared_preferences/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends InheritedWidget {
  final PreferredLanguage language;
  final void Function(PreferredLanguage language) setLanguage;
  const LocaleService(
      {super.key,
      required this.language,
      required this.setLanguage,
      required super.child});

  @override
  bool updateShouldNotify(covariant LocaleService oldWidget) {
    return oldWidget.language != language;
  }

  static LocaleService of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LocaleService>()!;
  }
}

class LocaleManager extends StatefulWidget {
  final Widget child;
  const LocaleManager({super.key, required this.child});

  @override
  State<LocaleManager> createState() => _LocaleManagerState();
}

class _LocaleManagerState extends State<LocaleManager> {
  PreferredLanguage language = PreferredLanguage.english;
  SharedPreferences? _pref;
  @override
  initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) {
      setState(() {
        _pref = value;
        language = PreferredLanguage.fromString(
            _pref!.getString(AcSharedPrefKeys.preferredLanguage.name));
      });
    });
  }

  void setLanguage(PreferredLanguage language) {
    setState(() {
      this.language = language;
      _pref!.setString(AcSharedPrefKeys.preferredLanguage.name, language.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocaleService(
        language: language, setLanguage: setLanguage, child: widget.child);
  }
}
