import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen');

  final String key;
  const AcSharedPrefKeys(this.key);
}

class LocalRecipeController extends ChangeNotifier {
  RecipeTable recipeTable;
  LocalRecipeController({required this.recipeTable});

  Future<RecipeModel?> get(int id, {required UserModel user}) async {
    return recipeTable.get(id, user: user);
  }

  Future<List<RecipeLiteModel>> getAll(
      {required UserModel user,
      required RecipeSearchState searchState,
      int page = 1}) async {
    return recipeTable.getAll(
        user: user,
        filter: searchState.filterBy,
        limit: searchState.limit,
        page: page,
        search: searchState.search,
        sort: searchState.sortBy);
  }

  Future<RecipeModel> put(
      {required String title,
      String? description,
      required List<RecipeStepFormType> steps,
      XFile? image,
      required UserModel user,
      RecipeModel? former}) async {
    final result = await recipeTable.put(
        title: title,
        description: description,
        steps: steps,
        image: image,
        user: user,
        former: former);
    notifyListeners();
    return result;
  }

  Future<void> remove(RecipeModel recipe) async {
    await recipeTable.remove(recipe);
    notifyListeners();
  }

  Future<void> setRemoteId(int localId, int? remoteId) async {
    await recipeTable.setRemoteId(localId, remoteId);
  }
}
