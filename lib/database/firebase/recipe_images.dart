import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:path/path.dart';

class RemoteRecipeImageManager {
  INetworkImageResourceManager imageManager;
  RemoteRecipeImageManager({required this.imageManager});

  String? getFilePath({required String userId, required String? name}) {
    return name == null
        ? null
        : imageManager.getPath(userId: userId, name: basename(name));
  }

  ({
    Map<String, XFile?> reserved,
    LocalRecipeModel recipe,
  }) markRecipeImagesForStorage({
    required LocalRecipeModel current,
    RecipeModel? former,
    required String userId,
  }) {
    final copy = LocalRecipeModel.fromJson(current.toJson());
    copy.remoteId = current.remoteId;
    final Map<String, XFile?> reserved = {};
    final currentImagePath = getFilePath(userId: userId, name: copy.imagePath);
    if (currentImagePath != former?.imageStoragePath) {
      if (currentImagePath != null) {
        reserved[currentImagePath] = XFile(copy.imagePath!);
        copy.imagePath = currentImagePath;
      }
      if (former?.imageStoragePath != null) {
        reserved[former!.imageStoragePath!] = null;
      }
    } else {
      copy.imagePath = former?.imageStoragePath;
    }

    for (final step in copy.steps) {
      final stepImagePath = getFilePath(userId: userId, name: step.imagePath);
      if (stepImagePath != null) {
        reserved[stepImagePath] = XFile(step.imagePath!);
        step.imagePath = stepImagePath;
      }
    }
    if (former != null) {
      for (final step in former.steps) {
        if (step.imageStoragePath == null) {
          continue;
        }
        if (reserved.containsKey(step.imageStoragePath!)) {
          reserved.remove(step.imageStoragePath);
          continue;
        }
        reserved[step.imageStoragePath!] = null;
      }
    }
    return (reserved: reserved, recipe: copy);
  }

  Map<String, XFile?> markRecipeImagesForDeletion(
      {required String userId, required RecipeModel recipe}) {
    Map<String, XFile?> reserved = {};
    if (recipe.imageStoragePath != null) {
      reserved[recipe.imageStoragePath!] = null;
    }
    for (final step
        in recipe.steps.where((element) => element.imagePath != null)) {
      reserved[step.imagePath!] = null;
    }
    return reserved;
  }
}
