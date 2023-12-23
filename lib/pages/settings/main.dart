import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/components/app/app_bar.dart';
import 'package:pambe_ac_ifa/components/display/future.dart';
import 'package:pambe_ac_ifa/database/shared_preferences/keys.dart';
import 'package:pambe_ac_ifa/locale.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/pages/settings/settings_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:localization/localization.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SharedPreferences? _pref;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          _pref = value;
        }));
  }

  Widget buildOptions(BuildContext context) {
    final localeService = LocaleService.of(context);
    return ListView(
      children: [
        SettingsItemSelect(
            title: Either.right("screen/settings/main/language".i18n()),
            onChanged: (String? preferredLanguage) async {
              localeService
                  .setLanguage(PreferredLanguage.fromString(preferredLanguage));
            },
            subtitle: Either.right("screen/settings/main/preferred_language".i18n()),
            value: localeService.language.name,
            options: [
              PreferredLanguage.english.selectOption,
              PreferredLanguage.indonesia.selectOption,
            ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeService = LocaleService.of(context);
    return Scaffold(
      appBar: OnlyReturnAppBar(actions: [
        if (_pref != null)
          Tooltip(
            message: "screen/settings/main/reset_settings".i18n(),
            child: FutureIconButton(
                onPressed: () async {
                  localeService.setLanguage(PreferredLanguage.english);
                },
                style: IconButton.styleFrom(
                    foregroundColor: context.colors.tertiary),
                icon: const Icon(Icons.settings_backup_restore)),
          )
      ]),
      body: _pref == null
          ? const Center(child: CircularProgressIndicator())
          : buildOptions(context),
    );
  }
}
