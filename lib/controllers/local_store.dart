import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/step_editor.dart';
import 'package:sqflite/sqflite.dart';

enum LocalRecipeColumns {
  id,
  userId,
  title,
  description,
  createdAt;

  @override
  toString() => name;
}

enum LocalRecipeStepColumns {
  id,
  recipeId,
  content,
  type,
  timer,
  createdAt;

  @override
  toString() => name;
}

class LocalRecipeStepsController {
  static const tableName = "recipe_steps";
  final Database db;
  LocalRecipeStepsController(this.db);

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
          CREATE TABLE $tableName (
            ${LocalRecipeStepColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${LocalRecipeStepColumns.recipeId} INTEGER, 
            ${LocalRecipeStepColumns.content} VARCHAR(255) NOT NULL, 
            ${LocalRecipeStepColumns.type} VARCHAR(255) NOT NULL, 
            ${LocalRecipeStepColumns.timer} INTEGER, 
            ${LocalRecipeStepColumns.createdAt} INTEGER, 
            FOREIGN KEY (${LocalRecipeStepColumns.recipeId}) REFERENCES ${LocalRecipeController.tableName}(id)
          );
      ''');
  }

  Future<void> create(Transaction txn,
      {required int recipeId,
      required String content,
      required String type,
      int? timer}) async {
    await txn.insert(tableName, {
      LocalRecipeStepColumns.recipeId.name: recipeId,
      LocalRecipeStepColumns.content.name: content,
      LocalRecipeStepColumns.type.name: type,
      LocalRecipeStepColumns.timer.name: timer,
      LocalRecipeStepColumns.createdAt.name:
          DateTime.now().millisecondsSinceEpoch,
    });
  }
}

class LocalRecipeController extends ChangeNotifier {
  static const tableName = "recipes";

  final Database db;
  late final LocalRecipeStepsController stepsController;
  LocalRecipeController(this.db) {
    stepsController = LocalRecipeStepsController(db);
  }

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
        CREATE TABLE $tableName (
            ${LocalRecipeColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${LocalRecipeColumns.userId} INTEGER, 
            ${LocalRecipeColumns.title} VARCHAR(255) NOT NULL,
            ${LocalRecipeColumns.description} TEXT, 
            ${LocalRecipeColumns.createdAt} INTEGER NOT NULL
        );
    ''');
  }

  Future<Recipe?> get(id) async {
    final data = (await db.query(
      tableName,
    ))
        .firstOrNull;

    if (data == null) return null;

    return Recipe.fromJson(data);
  }

  Future<Recipe> create({
    required String title,
    String? description,
    required List<RecipeStepFormType> steps,
  }) async {
    int id = await db.transaction((txn) async {
      int id = await txn.insert(tableName, {
        LocalRecipeColumns.title.name: title,
        LocalRecipeColumns.description.name: description,
        LocalRecipeColumns.createdAt.name: DateTime.now().millisecondsSinceEpoch
      });

      for (RecipeStepFormType step in steps) {
        await stepsController.create(
          txn,
          recipeId: id,
          content: step.content,
          type: step.variant.name,
          timer: step.timer?.inMilliseconds,
        );
      }
      return id;
    });

    Recipe recipe = (await get(id))!;
    notifyListeners();
    return recipe;
  }
}

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen');

  final String key;
  const AcSharedPrefKeys(this.key);
}
