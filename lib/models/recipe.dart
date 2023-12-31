import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/recipe_steps.dart';
import 'user.dart';
export 'recipe_steps.dart';

part 'gen/recipe.g.dart';

enum RecipeSourceType {
  local,
  remote,
}

class RecipeSource {
  String? remoteId;
  int? localId;
  RecipeSourceType type;
  RecipeSource.remote(this.remoteId) : type = RecipeSourceType.remote;
  RecipeSource.local(this.localId) : type = RecipeSourceType.local;
}

List<String> _defaultTags() {
  return [];
}

abstract class AbstractRecipeLiteModel with SupportsLocalAndOnlineImagesMixin {
  String title;
  String description;
  @JsonKey(defaultValue: _defaultTags)
  List<String> tags;
  @JsonEpochConverter()
  DateTime createdAt;
  @override
  ExternalImageSource get imageSource;
  @override
  String? imagePath;
  AbstractRecipeLiteModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.tags,
    this.imagePath,
  });
}

@JsonSerializable(explicitToJson: true)
class LocalRecipeLiteModel extends AbstractRecipeLiteModel {
  int id;
  @JsonKey(includeToJson: false)
  String? remoteId;
  @override
  @JsonKey(includeToJson: false)
  ExternalImageSource get imageSource => ExternalImageSource.local;

  LocalRecipeLiteModel({
    required this.id,
    this.remoteId,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
    required super.tags,
  });

  factory LocalRecipeLiteModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$LocalRecipeLiteModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$LocalRecipeLiteModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeLiteModel extends AbstractRecipeLiteModel {
  @JsonKey(includeToJson: false)
  String id;

  @JsonKey(
    toJson: $userPropertyToJson,
    fromJson: $userPropertyFromJson,
  )
  UserModel? user;

  @JsonKey(includeToJson: false)
  String? imageStoragePath;

  @override
  @JsonKey(includeToJson: false)
  ExternalImageSource get imageSource => ExternalImageSource.network;

  double? totalRating;
  int? reviewCount;
  double get rating {
    if (totalRating == null || reviewCount == null || reviewCount == 0.0) {
      return 0.0;
    }
    return totalRating! / reviewCount!;
  }

  RecipeLiteModel({
    required this.id,
    required this.user,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
    this.imageStoragePath,
    this.totalRating,
    this.reviewCount,
    required super.tags,
  });

  factory RecipeLiteModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeLiteModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() {
    final map = _$RecipeLiteModelToJson(this);
    map["imagePath"] = imageStoragePath;
    return map;
  }
}

@JsonSerializable(explicitToJson: true)
class LocalRecipeModel extends LocalRecipeLiteModel {
  List<LocalRecipeStepModel> steps;
  LocalRecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
    super.remoteId,
    required this.steps,
    required super.tags,
  });

  LocalRecipeModel withRemoteId(String? remoteId) {
    return LocalRecipeModel(
        id: id,
        remoteId: remoteId,
        imagePath: imagePath,
        title: title,
        description: description,
        createdAt: createdAt,
        steps: steps,
        tags: []);
  }

  factory LocalRecipeModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$LocalRecipeModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  @override
  Map<String, dynamic> toJson() => _$LocalRecipeModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class RecipeModel extends RecipeLiteModel {
  List<RecipeStepModel> steps;
  RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
    super.imageStoragePath,
    required super.user,
    required this.steps,
    required super.tags,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  @override
  Map<String, dynamic> toJson() {
    final map = _$RecipeModelToJson(this);
    map["imagePath"] = imageStoragePath;
    return map;
  }
}

@JsonSerializable()
class RecipeRelationshipModel {
  @JsonEpochConverter()
  DateTime createdAt;

  String userId;
  String recipeId;

  RecipeRelationshipModel({
    required this.createdAt,
    required this.userId,
    required this.recipeId,
  });

  factory RecipeRelationshipModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeRelationshipModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() {
    return _$RecipeRelationshipModelToJson(this);
  }
}
