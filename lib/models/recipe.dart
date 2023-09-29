import 'dart:io';

import 'package:pambe_ac_ifa/common/constants.dart';

enum RecipeStepVariant {
  regular,
  tip,
  warning;

  get primaryColor {
    return switch (this) {
      RecipeStepVariant.regular => AcColors.primary,
      RecipeStepVariant.tip => AcColors.info,
      RecipeStepVariant.warning => AcColors.danger,
    };
  }

  get backgroundColor {
    return switch (this) {
      RecipeStepVariant.regular => AcColors.card,
      RecipeStepVariant.tip => AcColors.infoLight,
      RecipeStepVariant.warning => AcColors.dangerLight,
    };
  }
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
