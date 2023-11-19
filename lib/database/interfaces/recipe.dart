import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

abstract class IRecipeResourceManager {
  Future<PaginatedQueryResult<RecipeLiteModel>> getAll({
    dynamic page,
    int? limit,
    SortBy<RecipeSortBy> sort,
    RecipeFilterBy? filter,
    String? search,
  });
  Future<RecipeModel?> get(String id);
  Future<RecipeModel> put(
    LocalRecipeModel recipe, {
    required String userId,
  });
  Future<void> remove(String id);

  void dispose();
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
  hasBeenViewedBy,
  hasBeenBookmarkedBy,
  local;

  @override
  toString() => name;
}

class RecipeFilterBy {
  String? userId;
  bool? viewed;
  RecipeFilterByType type;
  RecipeFilterBy._(this.type);
  RecipeFilterBy.createdByUser(String userId)
      : type = RecipeFilterByType.createdByUser,
        // ignore: prefer_initializing_formals
        userId = userId;
  RecipeFilterBy.viewedBy(String userId, {this.viewed = true})
      : type = RecipeFilterByType.hasBeenViewedBy,
        // ignore: prefer_initializing_formals
        userId = userId;
  RecipeFilterBy.bookmarkedBy(String userId)
      : type = RecipeFilterByType.hasBeenBookmarkedBy,
        // ignore: prefer_initializing_formals
        userId = userId;
  static RecipeFilterBy get local => RecipeFilterBy._(RecipeFilterByType.local);
  MapEntry<String, String?> get apiParams {
    return switch (type) {
      RecipeFilterByType.createdByUser => MapEntry(type.name, userId!),
      RecipeFilterByType.hasBeenViewedBy =>
        MapEntry(type.name, "${viewed! ? '' : '-'}$userId"),
      RecipeFilterByType.hasBeenBookmarkedBy => MapEntry(type.name, userId!),
      RecipeFilterByType.local => MapEntry(type.name, null),
    };
  }
}
