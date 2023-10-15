import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/pages/home/guest.dart';
import 'package:pambe_ac_ifa/pages/home/user.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isGuest) {
      return const GuestHomeScreen();
    } else {
      return const UserHomeScreen();
    }
  }
}
