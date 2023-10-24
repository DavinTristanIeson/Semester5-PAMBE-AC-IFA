import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:sqflite/sqflite.dart';

enum LocalRecipeColumns {
  id,
  userId,
  remoteId,
  title,
  description,
  createdAt,
  imagePath;

  @override
  toString() => name;
}

enum LocalRecipeStepColumns {
  id,
  recipeId,
  content,
  type,
  timer,
  imagePath,
  createdAt;

  @override
  toString() => name;
}

class LocalRecipeStepsController {
  static const tableName = "recipe_steps";
  final Database db;
  late final IImageResourceManager resources;
  LocalRecipeStepsController(this.db, {required this.resources});

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
          CREATE TABLE $tableName (
            ${LocalRecipeStepColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${LocalRecipeStepColumns.recipeId} INTEGER,
            ${LocalRecipeStepColumns.content} TEXT NOT NULL, 
            ${LocalRecipeStepColumns.type} TEXT NOT NULL, 
            ${LocalRecipeStepColumns.timer} INTEGER, 
            ${LocalRecipeStepColumns.imagePath} TEXT, 
            ${LocalRecipeStepColumns.createdAt} INTEGER NOT NULL,
            FOREIGN KEY (${LocalRecipeStepColumns.recipeId}) REFERENCES ${LocalRecipeController.tableName}(id)
          );
      ''');
  }

  void put(Batch txn,
      {required int recipeId,
      required String content,
      required String type,
      XFile? image,
      int? timer,
      RecipeStepModel? former}) async {
    final dataToBeInserted = {
      LocalRecipeStepColumns.recipeId.name: recipeId,
      LocalRecipeStepColumns.content.name: content,
      LocalRecipeStepColumns.type.name: type,
      LocalRecipeStepColumns.timer.name: timer,
      LocalRecipeStepColumns.imagePath.name: image?.path,
      LocalRecipeStepColumns.createdAt.name:
          DateTime.now().millisecondsSinceEpoch,
    };
    if (image != null) {
      resources.put(image, former: former?.imagePath);
    }
    if (former?.id == null) {
      txn.insert(tableName, dataToBeInserted);
    } else {
      txn.update(tableName, dataToBeInserted,
          where: "${LocalRecipeStepColumns.id} = ?", whereArgs: [former!.id]);
    }
  }

  Future<void> remove(Batch batch, int id, {RecipeStepModel? former}) async {
    if (former?.imagePath != null) {
      await resources.remove(former!.imagePath!);
    }
    batch.delete(tableName,
        where: "${LocalRecipeStepColumns.id.name} = ?", whereArgs: [id]);
  }

  Future<void> removeAll(Transaction txn, int recipeId) async {
    await txn.delete(tableName,
        where: "${LocalRecipeStepColumns.recipeId.name} = ?",
        whereArgs: [recipeId]);
  }

  Future<List<Map<String, Object?>>> getAll({
    Transaction? txn,
    required int recipeId,
  }) async {
    return (txn ?? db).query(tableName,
        where: "${LocalRecipeStepColumns.recipeId.name} = ?",
        whereArgs: [recipeId],
        orderBy: LocalRecipeStepColumns.id.name);
  }

  Future<void> putMany(
    Transaction txn, {
    required int recipeId,
    required List<RecipeStepFormType> steps,
    List<RecipeStepModel>? former,
  }) async {
    final batch = txn.batch();
    final stepIterator = former?.map((step) => MapEntry(step.id, step));
    final stepMap = stepIterator == null
        ? <String, RecipeStepModel>{}
        : Map<String, RecipeStepModel>.fromEntries(stepIterator);
    for (final step in steps) {
      final formerStep = step.id == null ? null : stepMap[step.id];
      put(
        batch,
        recipeId: recipeId,
        content: step.content,
        type: step.type.name,
        timer: step.timer?.inMilliseconds,
        image: step.image,
        former: step.id == null ? null : formerStep,
      );
      if (formerStep != null) {
        stepMap.remove(formerStep.id);
      }
    }

    await Future.wait(stepMap.entries
        .map((unusedStep) => remove(batch, int.parse(unusedStep.value.id))));
    await batch.commit(noResult: true);
  }
}

class LocalRecipeController extends ChangeNotifier {
  static const tableName = "recipes";

  final Database db;
  late final LocalRecipeStepsController stepsController;
  late final IImageResourceManager resources;
  LocalRecipeController(this.db, {required this.resources}) {
    stepsController = LocalRecipeStepsController(db, resources: resources);
  }

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
        CREATE TABLE $tableName (
            ${LocalRecipeColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${LocalRecipeColumns.userId} TEXT NOT NULL, 
            ${LocalRecipeColumns.remoteId} TEXT, 
            ${LocalRecipeColumns.title} VARCHAR(255) NOT NULL,
            ${LocalRecipeColumns.description} TEXT, 
            ${LocalRecipeColumns.createdAt} INTEGER NOT NULL,
            ${LocalRecipeColumns.imagePath} TEXT
        );
    ''');
  }

  Future<RecipeModel?> get(int id, {required UserModel user}) async {
    final data = (await db.query(
      tableName,
      where: "${LocalRecipeColumns.id} = ?",
      whereArgs: [id],
      limit: 1,
    ))
        .firstOrNull;

    if (data == null) return null;
    final steps = await stepsController.getAll(recipeId: id);
    return RecipeModel.fromLocal(data, user, steps);
  }

  Future<List<RecipeLiteModel>> getAll(
      {required UserModel user,
      required RecipeSearchState searchState,
      int page = 1}) async {
    final results = await db.query(tableName,
        where: searchState.search == null
            ? null
            : "${LocalRecipeColumns.title.name} LIKE ? OR ${LocalRecipeColumns.description.name} LIKE ?",
        whereArgs: searchState.search == null
            ? null
            : [searchState.search, searchState.search],
        limit: searchState.limit,
        offset: searchState.limit * (page - 1),
        orderBy: "${LocalRecipeColumns.createdAt.name} DESC");
    return results
        .map<RecipeLiteModel>(
            (result) => RecipeLiteModel.fromLocal(result, user))
        .toList();
  }

  Future<RecipeModel> put(
      {required String title,
      String? description,
      required List<RecipeStepFormType> steps,
      XFile? image,
      required UserModel user,
      RecipeModel? former}) async {
    int lastId = await db.transaction((txn) async {
      int lastId;
      Map<String, dynamic> data = {
        LocalRecipeColumns.title.name: title,
        LocalRecipeColumns.description.name: description,
        LocalRecipeColumns.createdAt.name:
            DateTime.now().millisecondsSinceEpoch,
        LocalRecipeColumns.userId.name: user.id,
        LocalRecipeColumns.imagePath.name: image?.path,
      };
      if (former == null) {
        lastId = await txn.insert(tableName, data);
      } else {
        await txn.update(tableName, data,
            where: "${LocalRecipeColumns.id.name} = ?",
            whereArgs: [int.parse(former.id)]);
        lastId = int.parse(former.id);
      }
      await stepsController.putMany(txn,
          recipeId: lastId, steps: steps, former: former?.steps);
      if (image != null) {
        resources.put(image, former: former?.imagePath);
      }
      return lastId;
    });

    RecipeModel recipe = (await get(lastId, user: user))!;
    notifyListeners();
    return recipe;
  }

  Future<void> remove(RecipeModel recipe) async {
    await db.transaction((txn) async {
      await Future.wait(recipe.steps.map((step) async {
        if (step.imagePath != null) {
          await resources.remove(step.imagePath!);
        }
      }));
      stepsController.removeAll(txn, int.parse(recipe.id));
      if (recipe.imagePath != null) {
        await resources.remove(recipe.imagePath!);
      }
      await txn.delete(tableName,
          where: "${LocalRecipeColumns.id.name} = ?", whereArgs: [recipe.id]);
    });
    notifyListeners();
  }

  Future<void> setRemoteId(int localId, int? remoteId) async {
    print("$localId, $remoteId");
    await db.update(
        tableName,
        {
          LocalRecipeColumns.remoteId.name: remoteId,
        },
        where: "${LocalRecipeColumns.id.name} = ?",
        whereArgs: [localId]);
  }
}

enum AcSharedPrefKeys {
  isAppOpenedBefore('initScreen');

  final String key;
  const AcSharedPrefKeys(this.key);
}
