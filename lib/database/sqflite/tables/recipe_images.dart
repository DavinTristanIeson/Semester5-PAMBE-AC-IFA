import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';

class LocalRecipeImageManager {
  IImageResourceManager imageManager;
  LocalRecipeImageManager({required this.imageManager});

  Future<void> deleteUnusedImagesTask(
      {required List<String> databaseImagePaths}) async {
    final availableImages = (await imageManager.getAll()).toSet();
    print(availableImages);
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

  Future<
      ({
        Map<String, XFile?> reserved,
        String? image,
        List<RecipeStepFormType> steps,
      })> markRecipeImagesForStorage({
    XFile? image,
    LocalRecipeModel? former,
    required List<RecipeStepFormType> steps,
  }) async {
    List<MapEntry<String, XFile?>> reserved = [];
    Map<String, String> modifiedStepFiles = {};
    String? recipeImage;
    if (image != null && image.path != former?.imagePath) {
      final entry = await imageManager.reserve(image);
      recipeImage = entry.key;
      reserved.add(entry);
      if (former?.imagePath != null) {
        reserved.add(MapEntry(former!.imagePath!, null));
      }
    }

    final formerSteps = former?.steps ?? [];
    final [newSteps, existingSteps] = steps.categorize((step) {
      if (step.image == null) return null;
      return step.id == null ? 0 : 1;
    }, 2);

    final changedSteps = existingSteps.where((existingStep) {
      return formerSteps.exists((formerStep) {
        if (formerStep.id != existingStep.id) return false;
        return formerStep.imagePath != existingStep.image?.path;
      });
    });

    if (newSteps.isNotEmpty) {
      final fileNames = await Future.wait(newSteps
          .where((e) => e.image != null)
          .map((e) => imageManager.reserve(e.image!)));
      modifiedStepFiles
          .addEntries(fileNames.map((e) => MapEntry(e.value.path, e.key)));
      reserved.addAll(fileNames);
    }
    if (changedSteps.isNotEmpty) {
      final fileNames = await Future.wait(changedSteps
          .where((e) => e.image != null)
          .map((e) => imageManager.reserve(e.image!)));
      modifiedStepFiles
          .addEntries(fileNames.map((e) => MapEntry(e.value.path, e.key)));
      reserved.addAll(fileNames);
    }
    return (
      reserved: Map.fromEntries(reserved),
      image: recipeImage,
      steps: steps.map((e) {
        if (e.image != null && modifiedStepFiles.containsKey(e.image!.path)) {
          e.image = XFile(modifiedStepFiles[e.image!.path]!);
        }
        return e;
      }).toList(),
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
