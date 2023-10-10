import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/pages/recipe/main.dart';
import 'package:pambe_ac_ifa/pages/startup/main.dart';
import 'package:pambe_ac_ifa/providers/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeLibSwitch extends StatefulWidget {
  const RecipeLibSwitch({super.key});

  @override
  State<RecipeLibSwitch> createState() => _RecipeLibSwitchState();
}

class _RecipeLibSwitchState extends State<RecipeLibSwitch> {
  SharedPreferences? _pref;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          _pref = value;
        }));
  }

  static MaterialPageRoute get defaultRoute {
    return MaterialPageRoute(builder: (context) => const RecipePage());
  }

  MaterialPageRoute? routeStartup() {
    if (_pref == null) return null;
    if (_pref!.getBool(AcSharedPrefKeys.isAppOpenedBefore.key) == null) {
      _pref!.setBool(AcSharedPrefKeys.isAppOpenedBefore.key, true);
      return MaterialPageRoute(
        builder: (context) => const StartupScreen(),
      );
    } else {
      _pref!.setBool(AcSharedPrefKeys.isAppOpenedBefore.key, true);
      return defaultRoute;
    }
  }

  @override
  Widget build(BuildContext context) {
    MaterialPageRoute? route = routeStartup();
    if (route != null) {
      Future.microtask(() {
        Navigator.of(context).push(route);
      });
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
