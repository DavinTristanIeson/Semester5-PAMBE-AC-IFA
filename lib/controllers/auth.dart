import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class AuthProvider extends ChangeNotifier {
  IUserController userManager;

  AuthProvider({
    required this.userManager,
  });

  // Placeholder methods until we implement firebase
  UserModel? user;
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

  Future<void> initialize() async {
    user = await userManager.getMe();
  }
}
