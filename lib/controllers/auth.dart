import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/auth.dart';
import 'package:pambe_ac_ifa/database/firebase/user.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  IUserResourceManager userManager;

  AuthProvider({
    required this.userManager,
  });

  // Placeholder methods until we implement firebase
  User? user;
  bool get isGuest {
    return user == null;
  }

  bool get isLoggedIn {
    return user != null;
  }

  Future<bool> login(LoginPayload payload) async {
    try {
      await FirebaseUserManager().login(payload);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else {
        throw e.message.toString();
      }
    }

    return true;
  }

  Future<bool> register(RegisterPayload payload) async {
    try {
      await FirebaseUserManager().register(payload);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        throw 'Wrong password provided for that user.';
      } else {
        throw e.message.toString();
      }
    }

    return true;
  }

  Future<void> initialize() async {
    final auth = FirebaseAuth.instance;
    user = auth.currentUser;
  }
}
