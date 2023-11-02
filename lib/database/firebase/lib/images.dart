import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';

const String globalFirebaseImageStoragePathRoot = "images";

class FirebaseImageManager implements INetworkImageResourceManager {
  FirebaseStorage db;
  final String storagePath;
  CacheClient cache;
  FirebaseImageManager(this.db, {required this.storagePath})
      : cache = CacheClient(staleTime: const Duration(minutes: 5));

  Reference getImageStorageReference() {
    return db.ref().child(globalFirebaseImageStoragePathRoot);
  }

  Reference getFileReference({required String name, required String userId}) {
    return getImageStorageReference()
        .child(userId)
        .child(storagePath)
        .child(name);
  }

  @override
  Future<void> process(Map<String, XFile?> resources,
      {required String userId}) async {
    await Future.wait(resources.entries.map((e) async {
      try {
        if (e.value == null) {
          await remove(e.key);
        } else {
          await db.ref(e.key).putFile(File(e.value!.path));
        }
      } catch (e) {
        return Future.value();
      }
    }));
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
    final firebaseResource =
        getFileReference(name: resource.name, userId: userId);
    if (firebaseResource.fullPath == former) {
      return firebaseResource.fullPath;
    }
    await firebaseResource.putFile(File(resource.path));
    return firebaseResource.fullPath;
  }

  @override
  Future<void> remove(String imagePath) async {
    try {
      await db.ref(imagePath).delete();
      cache.markStale(key: imagePath);
    } catch (e) {
      throw ApiError(ApiErrorType.deleteFailure, inner: e);
    }
  }

  @override
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource,
      {required String userId}) {
    return MapEntry(
        getFileReference(name: resource.name, userId: userId).fullPath,
        resource);
  }

  @override
  String getPath({required String userId, required String name}) {
    return getFileReference(name: name, userId: userId).fullPath;
  }

  @override
  Future<String?> urlof(String path) async {
    if (cache.has(path)) {
      return cache.get(path)!;
    }
    try {
      final url = await db.ref(path).getDownloadURL();
      cache.put(path, url);
      return url;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
