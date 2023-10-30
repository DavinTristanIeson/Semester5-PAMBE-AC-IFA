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

  Future<LocalRecipeModel?> get(int id) async {
    return recipeTable.get(id);
  }

  Future<List<LocalRecipeLiteModel>> getAll(
      {required RecipeSearchState searchState, int page = 1}) async {
    return recipeTable.getAll(
        filter: searchState.filterBy,
        limit: searchState.limit,
        page: page,
        search: searchState.search,
        sort: searchState.sortBy);
  }

  Future<LocalRecipeModel> put(
      {required String title,
      String? description,
      required List<RecipeStepFormType> steps,
      XFile? image,
      required UserModel user,
      int? id}) async {
    final result = await recipeTable.put(
        title: title,
        description: description,
        steps: steps,
        image: image,
        id: id);
    notifyListeners();
    return result;
  }

  Future<void> remove(int id) async {
    await recipeTable.remove(id);
    notifyListeners();
  }

  Future<void> setRemoteId(int localId, String? remoteId) async {
    await recipeTable.setRemoteId(localId, remoteId);
  }
}
