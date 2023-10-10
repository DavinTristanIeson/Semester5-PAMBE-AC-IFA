import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';

import 'user.dart';

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

class RecipeStep with SupportsLocalAndOnlineImagesMixin {
  String? id;
  String content;
  RecipeStepVariant type;
  // Location of file stored on local device
  @override
  String? localImage;
  // URL of file stored online
  @override
  String? onlineImage;
  Duration? timer;

  RecipeStep(
    this.content, {
    this.type = RecipeStepVariant.regular,
    this.localImage,
    this.timer,
  });
}

class Recipe with SupportsLocalAndOnlineImagesMixin {
  String? id;
  String title;
  String description;

  @override
  String? localImage;
  @override
  String? onlineImage;
  List<RecipeStep> steps;
  User? creator;

  Recipe({
    this.id,
    required this.title,
    required this.description,
    this.localImage,
    this.creator,
    required this.steps,
  });
}
