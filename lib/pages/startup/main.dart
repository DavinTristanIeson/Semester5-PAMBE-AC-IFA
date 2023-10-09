import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/pages/startup/get_started.dart';
import 'package:pambe_ac_ifa/pages/startup/login.dart';

enum StartupScreenPhase {
  getStarted,
  login,
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  StartupScreenPhase phase = StartupScreenPhase.getStarted;
  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      StartupScreenPhase.getStarted => StartupGetStartedScreen(next: () {
          setState(() {
            phase = StartupScreenPhase.login;
          });
        }),
      StartupScreenPhase.login => const StartupLoginScreen(),
    };
  }
}
