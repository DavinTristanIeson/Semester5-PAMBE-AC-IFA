import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pambe_ac_ifa/database/interfaces/firebase.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/user.dart';

enum UserFirestoreKeys {
  id,
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
  FirebaseUserManager(this.db);

  @override
  Future<UserModel?> get(String id) async {
    return processDocumentSnapshot(
        () => db.collection(collectionPath).doc(id).get(),
        transform: UserModel.fromJson);
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
}
