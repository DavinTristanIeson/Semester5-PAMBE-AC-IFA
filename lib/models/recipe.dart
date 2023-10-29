import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/models/container.dart';
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

abstract class AbstractRecipeLiteModel with SupportsLocalAndOnlineImagesMixin {
  String title;
  String description;
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
    this.imagePath,
  });
}

@JsonSerializable(explicitToJson: true)
class LocalRecipeLiteModel extends AbstractRecipeLiteModel {
  int id;
  @JsonKey(includeToJson: false)
  String? remoteId;
  @override
  ExternalImageSource get imageSource => ExternalImageSource.local;

  LocalRecipeLiteModel({
    required this.id,
    this.remoteId,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
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
  String id;
  UserModel user;
  @override
  ExternalImageSource get imageSource => ExternalImageSource.network;

  RecipeLiteModel({
    required this.id,
    required this.user,
    required super.title,
    required super.description,
    required super.createdAt,
    super.imagePath,
  });

  factory RecipeLiteModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeLiteModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  Map<String, dynamic> toJson() => _$RecipeLiteModelToJson(this);
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
  });

  LocalRecipeModel withRemoteId(String? remoteId) {
    return LocalRecipeModel(
        id: id,
        remoteId: remoteId,
        imagePath: imagePath,
        title: title,
        description: description,
        createdAt: createdAt,
        steps: steps);
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
    required super.user,
    required this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    try {
      return _$RecipeModelFromJson(json);
    } catch (e) {
      throw ApiError(ApiErrorType.shapeMismatch, inner: e);
    }
  }
  @override
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}

enum RecipeSortBy {
  lastViewed,
  createdDate,
  ratings,
  bookmarkedDate;

  @override
  toString() => name;
}

enum RecipeFilterByType {
  createdByUser,
  createdByUserName,
  hasBeenViewedBy,
  hasBeenBookmarkedBy,
  local;

  @override
  toString() => name;
}

class RecipeFilterBy {
  String? userId;
  String? userName;
  bool? viewed;
  RecipeFilterByType type;
  RecipeFilterBy._(this.type);
  RecipeFilterBy.createdByUser(this.userId)
      : type = RecipeFilterByType.createdByUser;
  RecipeFilterBy.createdByUserName(this.userName)
      : type = RecipeFilterByType.createdByUserName;
  RecipeFilterBy.viewedBy(this.userId, {this.viewed = true})
      : type = RecipeFilterByType.hasBeenViewedBy;
  RecipeFilterBy.bookmarkedBy(this.userId)
      : type = RecipeFilterByType.hasBeenBookmarkedBy;
  static RecipeFilterBy get local => RecipeFilterBy._(RecipeFilterByType.local);
  Pair<String, String?> get apiParams {
    return switch (type) {
      RecipeFilterByType.createdByUser => Pair(type.name, userId!),
      RecipeFilterByType.createdByUserName => Pair(type.name, userName!),
      RecipeFilterByType.hasBeenViewedBy =>
        Pair(type.name, "${viewed! ? '' : '-'}$userId"),
      RecipeFilterByType.hasBeenBookmarkedBy => Pair(type.name, userId!),
      RecipeFilterByType.local => Pair(type.name, null),
    };
  }
}

class RecipeSearchState {
  late SortBy<RecipeSortBy> sortBy;
  RecipeFilterBy? filterBy;
  String? search;
  int limit;

  RecipeSearchState({
    this.search,
    SortBy<RecipeSortBy>? sortBy,
    this.filterBy,
    this.limit = 15,
  }) {
    this.sortBy = sortBy ?? SortBy.descending(RecipeSortBy.createdDate);
  }

  RecipeSearchState copyWith({
    String? search,
    SortBy<RecipeSortBy>? sortBy,
    RecipeFilterBy? filterBy,
    int? limit,
  }) {
    return RecipeSearchState(
        search: search ?? this.search,
        sortBy: sortBy ?? this.sortBy,
        filterBy: filterBy ?? this.filterBy,
        limit: limit ?? this.limit);
  }

  Map<String, dynamic> getApiParams({int? page}) {
    final Map<String, String> params = {
      "sort": sortBy.apiParams,
      "limit": limit.toString(),
      "page": (page ?? 1).toString(),
    };
    if (search != null) {
      params["search"] = search!;
    }
    if (filterBy != null) {
      Pair<String, dynamic> filters = filterBy!.apiParams;
      if (filters.second != null) {
        params["filter[${filters.first}]"] = filters.second.toString();
      }
    }
    return params;
  }
}
