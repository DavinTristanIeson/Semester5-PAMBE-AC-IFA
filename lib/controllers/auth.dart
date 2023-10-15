import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class AuthProvider extends ChangeNotifier {
  // Placeholder methods until we implement firebase
  UserModel? user = UserModel(
      id: "0",
      name: "User",
      email: "placeholder@email.com",
      imagePath: "https://www.google.com");
  bool get isGuest {
    return user == null;
  }

  bool get isLoggedIn {
    return user != null;
  }

  login() {}
}
