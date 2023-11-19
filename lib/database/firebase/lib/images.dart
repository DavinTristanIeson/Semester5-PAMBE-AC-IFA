import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/cache/cache_client.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';

const String globalFirebaseImageStoragePathRoot = "images";

class FirebaseImageManager implements INetworkImageResourceManager {
  FirebaseStorage db;
  final String storagePath;
  CacheClient cache;
  FirebaseImageManager({required this.storagePath})
      : cache = CacheClient(staleTime: const Duration(minutes: 5)),
        db = FirebaseStorage.instance;

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
    await Future.wait(resources.entries.chunks(4).map((resources) async {
      for (final resource in resources) {
        try {
          if (resource.value == null) {
            await remove(resource.key);
          } else {
            await db.ref(resource.key).putFile(File(resource.value!.path));
          }
          cache.markStale(key: resource.key);
        } catch (e) {
          debugPrint("ERROR WITH ${resource.key} - ${resource.value?.path}");
        }
      }
    }));
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
