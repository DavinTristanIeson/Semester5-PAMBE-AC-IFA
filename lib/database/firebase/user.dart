import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/database/interfaces/user.dart';
import 'package:pambe_ac_ifa/database/mixins/firebase.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/user.dart';

enum UserFirestoreKeys {
  name,
  email,
  bio,
  birthdate,
  country,
  imagePath;

  @override
  toString() => this.name;
}

class FirebaseUserManager
    with FirebaseResourceManagerMixin
    implements IUserResourceManager {
  static const String collectionPath = "users";
  FirebaseFirestore db;
  INetworkImageResourceManager imageManager;
  CacheClient<UserModel?> cache;
  FirebaseUserManager({required this.imageManager})
      : cache = CacheClient(
            staleTime: const Duration(minutes: 7),
            cleanupInterval: const Duration(minutes: 4)),
        db = FirebaseFirestore.instance;

  @override
  Future<UserModel?> get(String id) async {
    if (cache.has(id)) {
      return cache.get(id);
    }
    final (:data, snapshot: _) = await processDocumentSnapshot(
        () => db.collection(collectionPath).doc(id).get(),
        transform: (json, snapshot) async {
      return Future.value(UserModel.fromJson({
        ...json,
        "id": snapshot.id,
        "imagePath": json[UserFirestoreKeys.imagePath.name] is String
            ? await imageManager.urlof(json[UserFirestoreKeys.imagePath.name])
            : null,
        "imageStoragePath": json[UserFirestoreKeys.imagePath.name],
      }));
    });
    cache.put(id, data);
    return data;
  }

  @override
  void dispose() {
    cache.dispose();
  }

  @override
  Future<UserModel> put(
    String id, {
    Optional<String>? email,
    Optional<String>? name,
    Optional<String?>? bio,
    Optional<XFile?>? image,
    Optional<DateTime?>? birthdate,
    Optional<String?>? country,
  }) async {
    final prev = await get(id);
    final Map<String, XFile?> reserved = {};
    final Map<String, dynamic> payload = Map.fromEntries(Optional.allWithValue([
      name?.encase((value) => MapEntry(UserFirestoreKeys.name.name, value)),
      email?.encase((value) => MapEntry(UserFirestoreKeys.email.name, value)),
      bio?.encase((value) => MapEntry(UserFirestoreKeys.bio.name, value)),
      birthdate?.encase((value) => MapEntry(
          UserFirestoreKeys.birthdate.name, value?.millisecondsSinceEpoch)),
      country
          ?.encase((value) => MapEntry(UserFirestoreKeys.country.name, value)),
    ], then: (value) {
      return value;
    }));
    if (image != null && image.hasValue) {
      final newImagePath = image.value == null
          ? null
          : imageManager.getPath(userId: id, name: image.value!.name);

      if (prev?.imageStoragePath != newImagePath) {
        if (prev?.imageStoragePath != null) {
          reserved[prev!.imageStoragePath!] = null;
        }
        if (newImagePath != null) {
          reserved[newImagePath] = image.value;
        }
      }
      payload[UserFirestoreKeys.imagePath.name] = newImagePath;
    }

    try {
      if (prev == null) {
        await db.collection(collectionPath).doc(id).set(payload);
      } else {
        await db.collection(collectionPath).doc(id).update(payload);
      }
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }

    try {
      await imageManager.process(reserved, userId: id);
    } catch (e) {
      throw ApiError(ApiErrorType.imageManagementFailure, inner: e);
    }

    cache.markStale(key: id);
    return (await get(id))!;
  }

  @override
  Future<void> remove(String id) async {
    UserModel prev;
    try {
      prev = (await get(id))!;
    } catch (e) {
      throw ApiError(ApiErrorType.resourceNotFound, inner: e);
    }
    try {
      await db.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
    if (prev.imagePath != null) {
      await imageManager.remove(prev.imagePath!);
    }
  }
}
