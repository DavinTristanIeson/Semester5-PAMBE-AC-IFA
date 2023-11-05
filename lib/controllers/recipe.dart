import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

/// Ini untuk resep yang disimpan online
class RecipeController extends ChangeNotifier {
  IRecipeResourceManager recipeManager;
  String? userId;
  RecipeController({required this.recipeManager, required this.userId});

  Future<List<RecipeLiteModel>> getAll(
    RecipeSearchState searchState, {
    DocumentSnapshot<Map<String, Object?>>? page,
  }) async {
    return (await getAllWithPagination(searchState, page: page)).data;
  }

  Future<List<RecipeLiteModel>> getRecentRecipes() async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.lastViewed),
        filterBy: RecipeFilterBy.viewedBy(userId, viewed: true)));
  }

  Future<List<RecipeLiteModel>> getTrendingRecipes() async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.ratings),
        filterBy: RecipeFilterBy.viewedBy(userId, viewed: false)));
  }

  Future<List<RecipeLiteModel>> getBookmarkedRecipes() async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.bookmarkedDate),
        filterBy: RecipeFilterBy.bookmarkedBy(userId)));
  }

  Future<List<RecipeLiteModel>> getRecipesByUser(String userId) async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.createdDate),
        filterBy: RecipeFilterBy.createdByUser(userId)));
  }

  Future<PaginatedQueryResult<RecipeLiteModel>> getAllWithPagination(
    RecipeSearchState searchState, {
    dynamic page,
  }) async {
    final (:data, :nextPage) =
        await recipeManager.getAll(page: page, searchState: searchState);
    return (
      data: data,
      nextPage: data.length < searchState.limit ? null : nextPage
    );
  }

  Future<RecipeModel?> get(String id) async {
    return recipeManager.get(id);
  }

  Future<RecipeModel> put(LocalRecipeModel recipe) async {
    if (userId == null) {
      throw InvalidStateError(
          "RecipeController.userId is expected to be non-null when put is called.");
    }
    final result = await recipeManager.put(recipe, userId: userId!);
    notifyListeners();
    return result;
  }

  Future<void> remove(String id) async {
    await recipeManager.remove(id);
    notifyListeners();
  }

  @override
  void dispose() {
    recipeManager.dispose();
    super.dispose();
  }
}
