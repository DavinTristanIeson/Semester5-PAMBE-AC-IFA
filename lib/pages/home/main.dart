import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/pages/home/guest.dart';
import 'package:pambe_ac_ifa/pages/home/user.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isGuest) {
      return const GuestHomePage();
    } else {
      return const UserHomePage();
    }
  }
}
