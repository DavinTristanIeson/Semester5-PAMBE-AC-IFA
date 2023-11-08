import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/firebase.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

enum UserFirestoreKeys {
  name,
  email,
  imagePath;

  @override
  toString() => this.name;
}

class FirebaseUserManager
    with FirebaseResourceManagerMixin
    implements IUserResourceManager {
  static const String collectionPath = "users";
  FirebaseFirestore db;
  CacheClient<UserModel> cache;
  FirebaseUserManager(this.db) : cache = CacheClient();

  @override
  Future<UserModel?> get(String id) async {
    if (cache.has(id)) {
      return cache.get(id);
    }
    try {
      final (:data, snapshot: _) = await processDocumentSnapshot(
          () => db.collection(collectionPath).doc(id).get(),
          transform: (json, snapshot) => Future.value(UserModel.fromJson({
                ...json,
                "id": snapshot.id,
              })));
      cache.put(data.id, data);
      return data;
    } on ApiError catch (e) {
      if (e.type == ApiErrorType.resourceNotFound) {
        return null;
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<UserCredential> getMeAuth() async {
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

  @override
  void dispose() {
    cache.dispose();
  }

  @override
  Future<UserModel?> put(String id, UserEditPayload payload) {
    // TODO: implement put
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> updateAuth(String id,
      {required UpdateAuthPayload payload, required LoginPayload credentials}) {
    // TODO: implement updateAuth
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> remove(String id, {required LoginPayload credentials}) {
    // TODO: implement remove
    throw UnimplementedError();
  }
}
