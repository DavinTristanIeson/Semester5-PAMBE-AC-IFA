import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/modules/future.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LocalRecipeImageManager {
  ILocalImageResourceManager imageManager;
  LocalRecipeImageManager({required this.imageManager});

  Future<void> deleteUnusedImagesTask(
      {required List<String> databaseImagePaths}) async {
    final availableImages = (await imageManager.getAll()).toSet();
    for (final imagePath in databaseImagePaths) {
      if (availableImages.contains(imagePath)) {
        availableImages.remove(imagePath);
      }
    }
    try {
      await Future.wait(availableImages
          .map((remainingImage) => File(remainingImage).delete()));
    } catch (e) {
      throw ApiError(ApiErrorType.cleanupFailure, inner: e);
    }
  }

  /// Mutates ``steps``.
  Future<
      ({
        Map<String, XFile?> reserved,
        String? image,
      })> markRecipeImagesForStorage({
    XFile? image,
    LocalRecipeModel? former,
    required List<RecipeStepFormType> steps,
  }) async {
    Map<String, XFile?> reserved = {};

    String? recipeImage;
    if (image?.path != former?.imagePath) {
      if (image != null) {
        final entry = await imageManager.reserve(image);
        recipeImage = entry.key;
        reserved.addEntry(entry);
      }
      if (former?.imagePath != null) {
        reserved[former!.imagePath!] = null;
      }
    } else {
      recipeImage = image?.path;
    }

    Map<int, RecipeStepFormType> stepsThatMightveChangedImages = {};
    for (final step in steps) {
      if (step.image == null) continue;
      if (step.id == null) {
        final entry = await imageManager.reserve(step.image!);
        reserved.addEntry(entry);
        step.image = XFile(entry.key);
      } else {
        stepsThatMightveChangedImages[step.id!] = step;
      }
    }
    if (former != null) {
      for (final step in former.steps) {
        if (step.imagePath == null) {
          continue;
        }
        if (!stepsThatMightveChangedImages.containsKey(step.id)) {
          reserved[step.imagePath!] = null;
          continue;
        }
        final updatedStep = stepsThatMightveChangedImages[step.id]!;
        if (updatedStep.image!.path != step.imagePath) {
          reserved[step.imagePath!] = null;
          final entry = await imageManager
              .reserve(stepsThatMightveChangedImages[step.id]!.image!);
          reserved.addEntry(entry);
          updatedStep.image = XFile(entry.key);
        }
      }
    }
    return (
      reserved: reserved,
      image: recipeImage,
    );
  }

  Map<String, XFile?> markRecipeImagesForRemoval(LocalRecipeModel former) {
    Map<String, XFile?> reserved = {};
    if (former.imagePath != null) {
      reserved[former.imagePath!] = null;
    }
    reserved.addEntries(former.steps
        .where((element) => element.imagePath != null)
        .map((e) => MapEntry(e.imagePath!, null)));
    return reserved;
  }

  Future<XFile> _downloadImage(String url, String path) async {
    final image = await http.get(Uri.parse(url));
    final tempFile = File(path);
    await tempFile.writeAsBytes(image.bodyBytes);
    return XFile(tempFile.path);
  }

  Future<String> _getTempFilePath(String name) async {
    final tempDir = await getTemporaryDirectory();
    return join(tempDir.path, name);
  }

  Future<Map<String, String>> prepareImagesForLocalCopy(
      RecipeModel recipe) async {
    Map<String, String> reserved = {};
    if (recipe.imagePath != null) {
      String tempPath =
          await _getTempFilePath(basename(recipe.imageStoragePath!));
      reserved[tempPath] = recipe.imagePath!;
      recipe.imageStoragePath = tempPath;
    }
    final stepResults = await Future.wait(
        recipe.steps.where((step) => step.imagePath != null).map((step) async {
      String tempPath =
          await _getTempFilePath(basename(recipe.imageStoragePath!));
      step.imageStoragePath = tempPath;
      return MapEntry(tempPath, step.imagePath!);
    }));
    reserved.addEntries(stepResults);

    return reserved;
  }

  Future<Map<String, XFile>> saveImagesForLocalCopy(
      Map<String, String> urls) async {
    final distributor = FutureChunkDistributor(urls.entries.map((entry) async {
      final MapEntry(key: path, value: url) = entry;
      final file = await _downloadImage(url, path);
      return MapEntry(basename(path), file);
    }), chunkSize: 4);
    final reserved = Map.fromEntries(await distributor.wait());
    return reserved;
  }
}
