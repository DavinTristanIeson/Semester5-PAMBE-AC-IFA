import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:sqflite/sqflite.dart';

enum TableNames {
  recipe("recipes"),
  recipeStep("recipe_steps");

  final String name;
  const TableNames(this.name);
}

class DatabaseProvider extends ChangeNotifier {
  final Database db;
  DatabaseProvider(this.db);

  Future<Recipe?> fetchRecipe(id) async {
    final data = (await db.query(
      TableNames.recipe.name,
    ))
        .firstOrNull;

    if (data == null) return null;

    return Recipe(
      id: data['id'].toString(),
      title: data['title'] as String,
      description: data['description'] as String,
      steps: [],
    );
  }

  Future<Recipe> storeRecipe(
      {required String title, String? description}) async {
    int id = await db.insert(TableNames.recipe.name, {
      'title': title,
      'description': description,
      'created_at': DateTime.now().millisecondsSinceEpoch
    });

    Recipe recipe = (await fetchRecipe(id))!;
    return recipe;
  }

  Future<void> storeRecipeStep(
      {required int recipe_id,
      required String content,
      required String type,
      int? timer}) async {
    await db.insert(TableNames.recipeStep.name, {
      'recipe_id': recipe_id,
      'content': content,
      'type': type,
      'timer': timer,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen');

  final String key;
  const AcSharedPrefKeys(this.key);
}
