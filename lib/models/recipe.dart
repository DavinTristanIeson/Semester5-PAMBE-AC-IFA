import 'dart:io';

enum RecipeStepVariant {
  regular,
  tip,
  warning,
}

class RecipeStep {
  String content;
  RecipeStepVariant type;
  String? imagePath;
  Duration? timer;
  RecipeStep(
    this.content, {
    this.type = RecipeStepVariant.regular,
    this.imagePath,
    this.timer,
  });
  File? get image {
    if (imagePath == null) {
      return null;
    }
    return File(imagePath!);
  }
}

class Recipe {
  String title;
  String description;
  String? imagePath;
  List<RecipeStep> steps;

  Recipe({
    required this.title,
    required this.description,
    this.imagePath,
    required this.steps,
  });
  File? get image {
    if (imagePath == null) {
      return null;
    }
    return File(imagePath!);
  }
}
