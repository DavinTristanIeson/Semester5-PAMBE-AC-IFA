import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

class RemoteRecipeImageManager {
  INetworkImageResourceManager imageManager;
  RemoteRecipeImageManager({required this.imageManager});

  String? getFilePath({required String userId, required String? name}) {
    return name == null
        ? null
        : imageManager.getFilePath(userId: userId, name: name);
  }

  Map<String, XFile?> markRecipeImagesForStorage({
    required LocalRecipeModel current,
    RecipeModel? former,
    required String userId,
  }) {
    final Map<String, XFile?> reserved = {};
    final currentImagePath =
        getFilePath(userId: userId, name: current.imagePath);
    if (currentImagePath != former?.imagePath) {
      if (currentImagePath != null) {
        reserved[currentImagePath] = XFile(current.imagePath!);
        current.imagePath = currentImagePath;
      }
      if (former?.imagePath != null) {
        reserved[former!.imagePath!] = null;
      }
    }

    for (final step in current.steps) {
      final stepImagePath = getFilePath(userId: userId, name: step.imagePath);
      if (stepImagePath != null) {
        reserved[stepImagePath] = XFile(step.imagePath!);
        step.imagePath = stepImagePath;
      }
    }
    if (former != null) {
      for (final step in former.steps) {
        if (step.imagePath == null || reserved.containsKey(step.imagePath!)) {
          continue;
        }
        reserved[step.imagePath!] = null;
      }
    }

    return reserved;
  }
}
