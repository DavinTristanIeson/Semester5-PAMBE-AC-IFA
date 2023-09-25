import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // Placeholder methods until we implement firebase
  dynamic user;
  get isSignedIn {
    return user == null;
  }

  login() {
    user = true;
  }
}
