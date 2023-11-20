import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class ILocalImageResourceManager {
  Future<File?> get(String imagePath);
  Future<List<String>> getAll();
  Future<File?> put(XFile? resource, {String? former});
  Future<void> process(Map<String, XFile?> resources);
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource);
  Future<void> remove(String imagePath);
}

abstract class INetworkImageResourceManager {
  String getPath({required String userId, required String name});
  Future<String?> urlof(String path);
  Future<void> process(Map<String, XFile?> resources, {required String userId});
  FutureOr<MapEntry<String, XFile>> reserve(XFile resource,
      {required String userId});
  Future<void> remove(String imagePath);
}

typedef PaginatedQueryResult<T> = ({List<T> data, dynamic nextPage});
