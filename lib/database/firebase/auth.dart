import 'package:firebase_auth/firebase_auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';

class FirebaseAuthManager {
  ApiError _wrapFirebaseAuthError(Object? error) {
    if (error is FirebaseAuthException) {
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
    return ApiError(ApiErrorType.authenticationError, inner: error);
  }

  Future<UserCredential> register(LoginPayload payload) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: payload.email, password: payload.password);

      return credential;
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }

  Future<UserCredential> login(LoginPayload payload) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: payload.email,
        password: payload.password,
      );

      return credential;
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }

  Future<User> reauthenticate(LoginPayload credentials) async {
    try {
      if (FirebaseAuth.instance.currentUser == null) {
        await login(credentials);
      }
      final user = FirebaseAuth.instance.currentUser;
      await user!.reauthenticateWithCredential(EmailAuthProvider.credential(
          email: credentials.email, password: credentials.password));
      return user;
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }

  Future<void> updateAuth(String id,
      {required UpdateAuthPayload payload,
      required LoginPayload credentials}) async {
    final user = await reauthenticate(credentials);
    try {
      if (payload.email != null) {
        await user.updateEmail(payload.email!);
      }
      if (payload.password != null) {
        await user.updatePassword(payload.password!);
      }
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }

  Future<void> deleteAccount(String id,
      {required LoginPayload credentials}) async {
    try {
      final user = await reauthenticate(credentials);
      return user.delete();
    } catch (e) {
      throw _wrapFirebaseAuthError(e);
    }
  }
}
