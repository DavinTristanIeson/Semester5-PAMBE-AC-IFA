import 'package:flutter/material.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
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

  Future<RecipeModel?> get(int id) async {
    final data = (await db.query(
      tableName,
      where: "${LocalRecipeColumns.id} = ?",
      whereArgs: [id],
    ))
        .firstOrNull;

    if (data == null) return null;
    print(data);

    return RecipeModel.fromJson(data);
  }

  Future<RecipeModel> put({
    String? id,
    required String title,
    String? description,
    required List<RecipeStepFormType> steps,
  }) async {
    int lastId = await db.transaction((txn) async {
      int lastId;
      if (id == null) {
        lastId = await txn.insert(tableName, {
          LocalRecipeColumns.title.name: title,
          LocalRecipeColumns.description.name: description,
          LocalRecipeColumns.createdAt.name:
              DateTime.now().millisecondsSinceEpoch
        });
      } else {
        lastId = await txn.update(
            tableName,
            {
              LocalRecipeColumns.title.name: title,
              LocalRecipeColumns.description.name: description,
              LocalRecipeColumns.createdAt.name:
                  DateTime.now().millisecondsSinceEpoch
            },
            where: "id = ?",
            whereArgs: [id]);
      }

      for (RecipeStepFormType step in steps) {
        await stepsController.create(
          txn,
          recipeId: lastId,
          content: step.content,
          type: step.variant.name,
          timer: step.timer?.inMilliseconds,
        );
      }
      return lastId;
    });

    RecipeModel recipe = (await get(lastId))!;
    notifyListeners();
    return recipe;
  }
}

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen');

  final String key;
  const AcSharedPrefKeys(this.key);
}
