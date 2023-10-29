import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';

/// Ini untuk resep yang disimpan online
class RecipeController extends ChangeNotifier {
  IRecipeResourceManager recipeManager;
  RecipeController({required this.recipeManager});

  Future<List<RecipeLiteModel>> getAll(
    RecipeSearchState searchState, {
    int page = 0,
  }) async {
    return recipeManager.getAll(
      page: page,
      searchState: searchState,
    );
  }

  Future<RecipeModel> get(String id) async {
    return recipeManager.get(id);
  }

  Future<RecipeModel> put(LocalRecipeModel recipe) async {
    final result = await recipeManager.put(recipe);
    notifyListeners();
    return result;
  }

  Future<void> remove(String id) async {
    await recipeManager.remove(id);
    notifyListeners();
  }
}
