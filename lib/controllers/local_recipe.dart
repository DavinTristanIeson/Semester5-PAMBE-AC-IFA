import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/controllers/auth.dart';
import 'package:pambe_ac_ifa/controllers/recipe.dart';
import 'package:pambe_ac_ifa/database/interfaces/errors.dart';
import 'package:pambe_ac_ifa/database/interfaces/recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';

class LocalRecipeController extends ChangeNotifier implements AuthDependent {
  RecipeTable recipeTable;
  String? _userId;
  LocalRecipeController({required this.recipeTable});

  @override
  set userId(String? userId) {
    _userId = userId;
    notifyListeners();
  }

  Future<LocalRecipeModel?> get(int id) async {
    return recipeTable.get(id);
  }

  Future<List<LocalRecipeLiteModel>> getAll(
      {required RecipeSearchState searchState, int page = 1}) async {
    if (_userId == null) {
      throw InvalidStateError(
          "LocalRecipeController.userId is expected to be non-null when getAll is called.");
    }
    return recipeTable.getAll(
        filter: RecipeFilterBy.createdByUser(_userId!),
        limit: searchState.limit,
        page: page,
        search: searchState.search,
        sort: searchState.sortBy);
  }

  Future<LocalRecipeModel> put(
      {required String title,
      String? description,
      required List<RecipeStepFormType> steps,
      required List<String> tags,
      XFile? image,
      int? id}) async {
    if (_userId == null) {
      throw InvalidStateError(
          "LocalRecipeController.userId is expected to be non-null when put is called.");
    }
    final result = await recipeTable.put(
        title: title,
        description: description,
        steps: steps,
        image: image,
        tags: tags,
        userId: _userId!,
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

  Future<void> syncAllLocal(Iterable<RecipeModel> recipes) async {
    if (_userId == null) {
      throw InvalidStateError(
          "LocalRecipeController.userId is expected to be non-null when syncAllLocal is called.");
    }
    await recipeTable.syncAll(recipes, userId: _userId!);
    notifyListeners();
  }

  Future<LocalRecipeModel> syncLocal(RecipeModel recipe, {int? id}) async {
    if (_userId == null) {
      throw InvalidStateError(
          "LocalRecipeController.userId is expected to be non-null when syncLocal is called.");
    }
    final result =
        await recipeTable.sync(recipe: recipe, userId: _userId!, localId: id);
    notifyListeners();
    return result;
  }
}
