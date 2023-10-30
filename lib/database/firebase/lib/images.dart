import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:path/path.dart';

const String globalFirebaseImageStoragePathRoot = "images";

class FirebaseImageManager implements INetworkImageResourceManager {
  FirebaseStorage db;
  final String storagePath;
  FirebaseImageManager(this.db, {required this.storagePath});

  String getImageStoragePath() {
    return join(globalFirebaseImageStoragePathRoot, storagePath);
  }

  String getFilename({required String name, required String userId}) {
    return '${userId}_$name';
  }

  @override
  Future<void> process(Map<String, XFile?> resources,
      {required String userId}) async {
    await Future.wait(resources.entries.map(
        (e) => e.value == null ? remove(e.key) : put(e.value, userId: userId)));
  }

  @override
  Future<String?> put(XFile? resource,
      {String? former, required String userId}) async {
    if (former != null) {
      await remove(former);
    }
    if (resource == null) {
      return null;
    }
    final resourceName = join(getImageStoragePath(),
        getFilename(name: resource.name, userId: userId));
    if (resourceName == former) {
      return resourceName;
    }
    await db.ref().child(resourceName).putFile(File(resource.path));
    return resourceName;
  }

  @override
  Future<void> remove(String imagePath) async {
    try {
      await db.ref().child(imagePath).delete();
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }

  @override
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource,
      {required String userId}) {
    return MapEntry(
        join(getImageStoragePath(),
            getFilename(name: resource.name, userId: userId)),
        resource);
  }
}
