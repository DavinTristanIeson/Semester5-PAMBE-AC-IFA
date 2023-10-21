import 'package:json_annotation/json_annotation.dart';
import 'package:pambe_ac_ifa/common/constants.dart';
import 'package:pambe_ac_ifa/common/json.dart';
import 'package:pambe_ac_ifa/components/display/image.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'user.dart';

part 'gen/recipe.g.dart';

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

  UserModel creator;

  RecipeLiteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.imagePath,
    this.imageSource,
    required this.creator,
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
    required super.creator,
    required this.steps,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) =>
      _$RecipeModelFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$RecipeModelToJson(this);
}

enum RecipeSortByType {
  lastViewed,
  createdDate,
  ratings,
  bookmarkedDate;

  @override
  toString() => name;
}

class RecipeSortBy {
  String? userId;
  RecipeSortByType type;
  RecipeSortBy._(this.type);
  RecipeSortBy.lastViewed({required String by})
      : userId = by,
        type = RecipeSortByType.createdDate;
  static RecipeSortBy get ratings => RecipeSortBy._(RecipeSortByType.ratings);
  static RecipeSortBy get createdDate =>
      RecipeSortBy._(RecipeSortByType.createdDate);
  static RecipeSortBy get bookmarkedDate =>
      RecipeSortBy._(RecipeSortByType.bookmarkedDate);
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
  Pair<String, dynamic> get apiParams {
    return switch (type) {
      RecipeFilterByType.createdByUser => Pair(type.name, userId),
      RecipeFilterByType.createdByUserName => Pair(type.name, userName),
      RecipeFilterByType.hasBeenViewedBy =>
        Pair(type.name, "${viewed! ? '' : '-'}$userId"),
      RecipeFilterByType.hasBeenBookmarkedBy => Pair(type.name, userId),
      RecipeFilterByType.local => Pair(type.name, userId),
    };
  }
}

class RecipeSearchState {
  SortBy<RecipeSortBy> sortBy;
  RecipeFilterBy? filterBy;
  String? search;
  int limit;

  RecipeSearchState({
    required this.search,
    required this.sortBy,
    required this.filterBy,
    this.limit = 15,
  });

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

  Map<String, Object?> getApiParams({int page = 0}) {
    final Map<String, Object?> params = {
      "sort": sortBy.apiParams,
      "limit": limit,
      "page": page,
    };
    if (search != null) {
      params["search"] = search;
    }
    Map<String, String> filterParams = {};
    if (filterBy != null) {
      Pair<String, dynamic> filters = filterBy!.apiParams;
      filterParams[filters.first] = filters.second;
    }
    params["filter"] = filterParams;
    return params;
  }
}
