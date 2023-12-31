import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/common.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

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
    Optional<String>? search,
    SortBy<RecipeSortBy>? sortBy,
    RecipeFilterBy? filterBy,
    int? limit,
  }) {
    return RecipeSearchState(
        search: Optional.valueOf<String?>(search, otherwise: () => this.search),
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
      MapEntry<String, dynamic> filters = filterBy!.apiParams;
      if (filters.value != null) {
        params["filter[${filters.key}]"] = filters.value.toString();
      }
    }
    return params;
  }
}

/// Ini untuk resep yang disimpan online
class RecipeController extends ChangeNotifier implements AuthDependent {
  IRecipeResourceManager recipeManager;
  IRecipeRelationshipResourceManager bookmarkManager;
  IRecipeRelationshipResourceManager viewManager;
  String? _userId;
  RecipeController(
      {required this.recipeManager,
      required this.bookmarkManager,
      required this.viewManager,
      required String? userId})
      : _userId = userId;

  @override
  set userId(String? userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<List<RecipeLiteModel>> getAll(
    RecipeSearchState searchState, {
    DocumentSnapshot<Map<String, Object?>>? page,
  }) async {
    final (:data, nextPage: _) =
        await getAllWithPagination(searchState, page: page);
    return data;
  }

  Future<List<RecipeLiteModel>> getRecentRecipes() async {
    return getAll(RecipeSearchState(
        limit: 10,
        sortBy: SortBy.descending(RecipeSortBy.lastViewed),
        filterBy: RecipeFilterBy.viewedBy(_userId!)));
  }

  Future<List<RecipeLiteModel>> getTrendingRecipes() async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.ratings),
        filterBy: null));
  }

  Future<List<RecipeLiteModel>> getBookmarkedRecipes() async {
    return getAll(RecipeSearchState(
        limit: 5,
        sortBy: SortBy.descending(RecipeSortBy.bookmarkedDate),
        filterBy: RecipeFilterBy.bookmarkedBy(_userId!)));
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
    final (:data, :nextPage) = await recipeManager.getAll(
        page: page,
        limit: searchState.limit,
        filter: searchState.filterBy,
        search: searchState.search,
        sort: searchState.sortBy);
    return (
      data: data,
      nextPage: data.length < searchState.limit ? null : nextPage
    );
  }

  Future<RecipeModel?> get(String id) async {
    return recipeManager.get(id);
  }

  Future<RecipeModel> put(LocalRecipeModel recipe) async {
    if (_userId == null) {
      throw InvalidStateError(
          "RecipeController._userId is expected to be non-null when put is called.");
    }
    final result = await recipeManager.put(recipe, userId: _userId!);
    notifyListeners();
    return result;
  }

  Future<void> remove(String id) async {
    await recipeManager.remove(id);
    notifyListeners();
  }

  Future<void> bookmark(String recipeId, bool isBookmarked) async {
    if (_userId == null) {
      throw InvalidStateError(
          "RecipeController._userId is expected to be non-null when bookmark is called.");
    }
    await bookmarkManager.set(
        recipeId: recipeId, userId: _userId!, hasRelation: isBookmarked);
    notifyListeners();
  }

  Future<void> view(String recipeId) async {
    if (_userId == null) {
      return;
    }
    await viewManager.set(
        recipeId: recipeId, userId: _userId!, hasRelation: true);
    notifyListeners();
  }

  Future<bool> isBookmarked(String recipeId) {
    if (_userId == null) {
      throw InvalidStateError(
          "RecipeController._userId is expected to be non-null when isBookmarked is called.");
    }
    return bookmarkManager
        .get(userId: _userId!, recipeId: recipeId)
        .into((value) => value != null);
  }

  @override
  void dispose() {
    recipeManager.dispose();
    super.dispose();
  }
}
