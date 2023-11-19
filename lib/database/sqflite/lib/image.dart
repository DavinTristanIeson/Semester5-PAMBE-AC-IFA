import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalFileImageManager implements ILocalImageResourceManager {
  static String? _imageStoragePath;
  static FutureOr<String> getImageStoragePath() async {
    if (_imageStoragePath != null) return _imageStoragePath!;
    _imageStoragePath = joinAll([
      (await getApplicationDocumentsDirectory()).path,
      "recipelib",
      "images"
    ]);
    return _imageStoragePath!;
  }

  @override
  Future<List<String>> getAll() async {
    final directory = Directory(await getImageStoragePath());
    return await directory.list().map((event) => event.path).toList();
  }

  @override
  Future<File?> get(String imagePath) async {
    final image = File(imagePath);
    try {
      return (await image.exists() ? image : null);
    } catch (e) {
      throw ApiError(ApiErrorType.fetchFailure,
          message: "Failed to get image with path: $imagePath", inner: e);
    }
  }

  String getFilename(XFile file) {
    return '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
  }

  @override
  Future<File?> put(XFile? resource, {String? former}) async {
    if (former != null) {
      await remove(former);
    }
    if (resource == null) {
      return null;
    }

    if (resource.path == former) {
      return File(resource.path);
    }

    final location = await getImageStoragePath();
    final File result;
    try {
      result =
          await File(resource.path).copy(join(location, getFilename(resource)));
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure,
          message: "Failed to store image with path: ${resource.path}",
          inner: e);
    }
    return result;
  }

  @override
  Future<void> remove(String imagePath) async {
    final image = File(imagePath);
    try {
      if (await image.exists()) {
        await image.delete();
      }
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }
  }

  @override
  Future<void> process(Map<String, XFile?> resources) async {
    final location = await getImageStoragePath();
    try {
      await Future.wait(resources.entries.map((entry) {
        if (entry.value == null) {
          return remove(entry.key);
        }
        return File(entry.value!.path).copy(join(location, entry.key));
      }));
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure, inner: e);
    }
  }

  @override
  Future<MapEntry<String, XFile>> reserve(XFile resource) async {
    final location = await getImageStoragePath();
    return MapEntry(join(location, getFilename(resource)), resource);
  }
}
