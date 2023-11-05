import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

class AuthProvider extends ChangeNotifier {
  IUserResourceManager userManager;

  AuthProvider({
    required this.userManager,
  });

  // Placeholder methods until we implement firebase
  UserModel? user = UserModel(
      id: "1mBIe7ICAGtXKiMdZtfb",
      name: "Test",
      email: "test@recipelib.com",
      imagePath: null);
  bool get isGuest {
    return user == null;
  }

  bool get isLoggedIn {
    return user != null;
  }

  Future<UserModel> login(LoginPayload payload) async {
    final result = await userManager.login(payload);
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    notifyListeners();
  }

  Future<UserModel> register(RegisterPayload payload) async {
    return userManager.register(payload);
  }

  Future<void> initialize() async {}

  Future<UserModel?> get(String userId) {
    return userManager.get(userId);
  }

  Future<void> updateProfile(UserEditPayload payload) async {
    if (user == null) {
      throw InvalidStateError(
          "AuthProvider.user is expected to be initialized when the updateProfile method is called!");
    }
    user = await userManager.put(user!.id, payload);
    notifyListeners();
  }

  Future<void> deleteAccount(LoginPayload credentials) async {
    if (user == null) {
      throw InvalidStateError(
          "AuthProvider.user is expected to be initialized when the deleteAccount method is called!");
    }
    await userManager.remove(user!.id, credentials: credentials);
    notifyListeners();
  }

  Future<void> updateAuth(
    UpdateAuthPayload payload, {
    required LoginPayload credentials,
  }) async {
    if (user == null) {
      throw InvalidStateError(
          "User is expected to be initialized when the .updateAuth method is called!");
    }
    user = await userManager.updateAuth(user!.id,
        payload: payload, credentials: credentials);
    notifyListeners();
  }

  @override
  void dispose() {
    userManager.dispose();
    super.dispose();
  }
}
