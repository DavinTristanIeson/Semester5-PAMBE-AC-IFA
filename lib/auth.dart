import 'package:firebase_auth/firebase_auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
  }

  Future<UserCredential> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw ApiError(ApiErrorType.fromServer, inner: e);
    }
  }
}
