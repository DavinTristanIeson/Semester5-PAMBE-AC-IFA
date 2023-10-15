import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'user.dart';

part 'recipe.g.dart';

enum RecipeSource {
  local,
  online,
}

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

@JsonSerializable()
class RecipeStep with SupportsLocalAndOnlineImagesMixin {
  String? id;
  String content;
  RecipeStepVariant type;
  @override
  String? imagePath;

  @override
  @JsonKey(defaultValue: ExternalImageSource.local, includeToJson: false)
  ExternalImageSource? imageSource;

  @JsonDurationConverter()
  Duration? timer;

  RecipeStep(
    this.content, {
    this.type = RecipeStepVariant.regular,
    this.imagePath,
    this.imageSource,
    this.timer,
  });
  factory RecipeStep.fromJson(Map<String, dynamic> json) =>
      _$RecipeStepFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeStepToJson(this);
}

String _parseRecipeId(Object value) {
  return value.toString();
}

@JsonSerializable()
class RecipeLiteModel with SupportsLocalAndOnlineImagesMixin {
  @JsonKey(fromJson: _parseRecipeId)
  String id;
  String title;
  String description;
  @JsonEpochConverter()
  DateTime createdAt;

  @override
  String? imagePath;

  @override
  @JsonKey(defaultValue: ExternalImageSource.local)
  ExternalImageSource? imageSource;

  User? creator;

  RecipeLiteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.imagePath,
    this.imageSource,
    this.creator,
  });

  factory RecipeLiteModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeLiteModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeLiteModelToJson(this);
}

@JsonSerializable()
class RecipeModel extends RecipeLiteModel
    with SupportsLocalAndOnlineImagesMixin {
  List<RecipeStep> steps;

  RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
    super.imageSource,
    super.creator,
    required this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}
