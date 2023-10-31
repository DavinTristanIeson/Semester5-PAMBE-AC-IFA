import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class AuthProvider extends ChangeNotifier {
  IUserResourceManager userManager;

  AuthProvider({
    required this.userManager,
  });

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

  Future<UserModel> login(LoginPayload payload) async {
    return userManager.login(payload);
  }

  Future<UserModel> register(RegisterPayload payload) async {
    return userManager.register(payload);
  }

  Future<void> initialize() async {}

  @override
  void dispose() {
    userManager.dispose();
    super.dispose();
  }
}
