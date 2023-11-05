import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
part 'gen/recipe_steps.g.dart';

enum RecipeStepVariant {
  @JsonValue("regular")
  regular,
  @JsonValue("tip")
  tip,

  @JsonValue("warning")
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

abstract class AbstractRecipeStepModel with SupportsLocalAndOnlineImagesMixin {
  String content;
  RecipeStepVariant type;

  @JsonDurationConverter()
  Duration? timer;
  @override
  ExternalImageSource? get imageSource;
  @override
  String? imagePath;

  AbstractRecipeStepModel({
    required this.content,
    this.type = RecipeStepVariant.regular,
    this.timer,
    this.imagePath,
  });

  static int countSteps(Iterable<AbstractRecipeStepModel> steps) {
    if (steps.isEmpty) {
      return 0;
    }
    return steps
        .map((step) => (step.type == RecipeStepVariant.regular ? 1 : 0))
        .reduce((value, element) => value + element);
  }
}

@JsonSerializable(explicitToJson: true)
class LocalRecipeStepModel extends AbstractRecipeStepModel
    with SupportsLocalAndOnlineImagesMixin {
  int id;
  @override
  @JsonKey(includeToJson: false)
  ExternalImageSource? get imageSource => ExternalImageSource.local;

  LocalRecipeStepModel({
    required this.id,
    required super.content,
    super.type,
    super.timer,
    super.imagePath,
  });

  factory LocalRecipeStepModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$LocalRecipeStepModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$LocalRecipeStepModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeStepModel extends AbstractRecipeStepModel
    with SupportsLocalAndOnlineImagesMixin {
  @override
  @JsonKey(includeToJson: false)
  ExternalImageSource? get imageSource => ExternalImageSource.network;

  @JsonKey(includeToJson: false)
  String? imageStoragePath;

  RecipeStepModel({
    required super.content,
    super.type,
    super.timer,
    super.imagePath,
    this.imageStoragePath,
  });

  factory RecipeStepModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeStepModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() {
    final map = _$RecipeStepModelToJson(this);
    map["imageStoragePath"] = imagePath;
    return map;
  }
}
