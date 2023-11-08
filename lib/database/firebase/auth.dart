import 'package:firebase_auth/firebase_auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';

class FirebaseAuthManager {
  Future<UserCredential> register(LoginPayload payload) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
    );

    return credential;
  }

  Future<UserCredential> login(LoginPayload payload) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
    );

    return credential;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<User> reauthenticate(LoginPayload credentials) async {
    if (FirebaseAuth.instance.currentUser == null) {
      await login(credentials);
    }
    final user = FirebaseAuth.instance.currentUser;
    await user!.reauthenticateWithCredential(EmailAuthProvider.credential(
        email: credentials.email, password: credentials.password));
    return user;
  }

  Future<void> updateAuth(String id,
      {required UpdateAuthPayload payload,
      required LoginPayload credentials}) async {
    final user = await reauthenticate(credentials);
    if (payload.email != null) {
      await user.updateEmail(payload.email!);
    }
    if (payload.password != null) {
      await user.updatePassword(payload.password!);
    }
  }

  Future<void> deleteAccount(String id,
      {required LoginPayload credentials}) async {
    final user = await reauthenticate(credentials);
    return user.delete();
  }
}
