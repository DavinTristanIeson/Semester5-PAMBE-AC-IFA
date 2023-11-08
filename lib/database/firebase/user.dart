import 'package:firebase_auth/firebase_auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';

class FirebaseUserManager implements IUserResourceManager {
  @override
  Future<UserCredential> getMe() async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: 'a',
      password: 'b',
    );

    return credential;
  }

  @override
  Future<UserCredential> register(RegisterPayload payload) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
    );

    return credential;
  }

  @override
  Future<UserCredential> login(LoginPayload payload) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: payload.email,
      password: payload.password,
    );

    return credential;
  }
}
