import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LocalImageController implements IImageResourceController {
  static Future<String> getImageStoragePath() async {
    return joinAll([
      (await getApplicationDocumentsDirectory()).path,
      "recipelib",
      "images"
    ]);
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

  @override
  Future<File?> put(XFile? resource, {String? former}) async {
    if (resource == null) {
      if (former != null) {
        remove(former);
      }
      return null;
    }

    if (resource.path == former) {
      return File(resource.path);
    }

    final location = await getImageStoragePath();
    final File result;
    try {
      result = await File(resource.path).copy(
          '$location/${DateTime.now().millisecondsSinceEpoch}_${resource.name}');
    } catch (e) {
      throw ApiError(ApiErrorType.storeFailure,
          message: "Failed to store image with path: ${resource.path}",
          inner: e);
    }

    if (former != null) {
      await remove(former);
    }
    return result;
  }

  @override
  Future<void> remove(String imagePath) async {
    final image = File(imagePath);
    if (await image.exists()) {
      await image.delete();
    }
  }
}
