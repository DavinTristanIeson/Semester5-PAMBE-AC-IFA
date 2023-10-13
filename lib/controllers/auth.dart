import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Placeholder methods until we implement firebase
  User? user;
  get isSignedIn {
    return user == null;
  }

  login() {}
}
