import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
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
    final cachedItem = cache.get(id);
    if (cachedItem != null) {
      return cachedItem;
    }
    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => db.collection(collectionPath).doc(id).get(),
        transform: (json, snapshot) => Future.value(UserModel.fromJson({
              ...json,
              "id": snapshot.id,
            })));
    cache.put(data.id, data);
    return data;
  }

  @override
  Future<UserModel> register(RegisterPayload payload) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<UserModel> login(LoginPayload payload) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  void dispose() {
    cache.dispose();
  }
}
