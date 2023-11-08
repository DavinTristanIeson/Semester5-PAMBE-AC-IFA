import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/firebase/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    user = user;
    notifyListeners();
  }

  @override
  void dispose() {
    _userStateSubscription?.cancel();
    super.dispose();
  }

  bool get isGuest => user == null;
  bool get isLoggedIn => user != null;

  ApiError _wrapFirebaseAuthError(FirebaseAuthException error) {
    if (error.code == 'user-not-found') {
      return ApiError(ApiErrorType.authenticationError,
          message: 'No user found for that email.', inner: error);
    } else if (error.code == 'wrong-password') {
      return ApiError(ApiErrorType.authenticationError,
          message: 'Wrong password provided for that user.', inner: error);
    } else {
      return ApiError(ApiErrorType.authenticationError, inner: error);
    }
  }

  Future<User> login(LoginPayload payload) async {
    try {
      await authManager.login(payload);
    } on FirebaseAuthException catch (e) {
      throw _wrapFirebaseAuthError(e);
    }

    return FirebaseAuth.instance.currentUser!;
  }

  Future<User> register(RegisterPayload payload) async {
    try {
      await authManager
          .register((email: payload.email, password: payload.password));
    } on FirebaseAuthException catch (e) {
      throw _wrapFirebaseAuthError(e);
    }

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

  Future<void> initialize() async {
    final auth = FirebaseAuth.instance;
    user = auth.currentUser;
  }
}
