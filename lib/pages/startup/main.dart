import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/pages/startup/body.dart';
import 'package:pambe_ac_ifa/providers/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartupSwitch extends StatelessWidget {
  final Widget Function(BuildContext context) builder;
  const StartupSwitch({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            throw snapshot.error!;
          }
          if (snapshot.hasData) {
            SharedPreferences instance = snapshot.data!;
            if (instance.getBool(AcSharedPrefKeys.isAppOpenedBefore.key) ==
                null) {
              instance.setBool(AcSharedPrefKeys.isAppOpenedBefore.key, true);
              return const StartupScreen();
            } else {
              instance.setBool(AcSharedPrefKeys.isAppOpenedBefore.key, true);
              return builder(context);
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}
