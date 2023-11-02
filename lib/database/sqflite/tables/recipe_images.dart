import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';

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
        }
        final updatedStep = stepsThatMightveChangedImages[step.id];
        if (updatedStep!.image!.path != step.imagePath) {
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
}
