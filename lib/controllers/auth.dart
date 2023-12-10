import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/firebase/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthDependent {
  set userId(String? id);
}

class AuthProvider extends ChangeNotifier {
  FirebaseAuthManager authManager;
  User? user;
  StreamSubscription? _userStateSubscription;

  AuthProvider({
    required this.authManager,
  }) {
    _userStateSubscription =
        FirebaseAuth.instance.authStateChanges().listen(_onUserChanged);
  }

  void _onUserChanged(User? user) {
    this.user = user;
    notifyListeners();
  }

  @override
  void dispose() {
    _userStateSubscription?.cancel();
    super.dispose();
  }

  bool get isGuest => user == null;
  bool get isLoggedIn => user != null;

  Future<User> login(LoginPayload payload) async {
    await authManager.login(payload);

    return FirebaseAuth.instance.currentUser!;
  }

  Future<User> register(RegisterPayload payload) async {
    await authManager
        .register((email: payload.email, password: payload.password));

    return FirebaseAuth.instance.currentUser!;
  }

  Future<void> logout() {
    return authManager.logout();
  }

  Future<void> updateAuth({
    required UpdateAuthPayload payload,
    required LoginPayload credentials,
  }) {
    if (user == null) {
      throw InvalidStateError(
          "AuthProvider.user should not be null when updateAuth is called");
    }
    return authManager.updateAuth(user!.uid,
        payload: payload, credentials: credentials);
  }

  Future<void> deleteAccount({required LoginPayload credentials}) {
    if (user == null) {
      throw InvalidStateError(
          "AuthProvider.user should not be null when updateAuth is called");
    }
    return authManager.deleteAccount(user!.uid, credentials: credentials);
  }

  static T registerUidToProvider<T extends AuthDependent>(
      BuildContext context, AuthProvider provider, T? dependent) {
    final userId = provider.user?.uid;
    dependent!.userId = userId;
    return dependent;
  }
}
