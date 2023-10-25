import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:sqflite/sqflite.dart';

enum _RecipeStepColumns {
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

class RecipeStepsTable {
  static const tableName = "recipe_steps";
  final Database db;
  late final IImageResourceManager resources;
  RecipeStepsTable(this.db, {required this.resources});

  static Future<void> initialize(Transaction txn) {
    return txn.execute(
        '''
          CREATE TABLE $tableName (
            ${_RecipeStepColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${_RecipeStepColumns.recipeId} INTEGER,
            ${_RecipeStepColumns.content} TEXT NOT NULL, 
            ${_RecipeStepColumns.type} TEXT NOT NULL, 
            ${_RecipeStepColumns.timer} INTEGER, 
            ${_RecipeStepColumns.imagePath} TEXT, 
            ${_RecipeStepColumns.createdAt} INTEGER NOT NULL,
            FOREIGN KEY (${_RecipeStepColumns.recipeId}) REFERENCES ${RecipeTable.tableName}(id)
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
      _RecipeStepColumns.recipeId.name: recipeId,
      _RecipeStepColumns.content.name: content,
      _RecipeStepColumns.type.name: type,
      _RecipeStepColumns.timer.name: timer,
      _RecipeStepColumns.imagePath.name: image?.path,
      _RecipeStepColumns.createdAt.name: DateTime.now().millisecondsSinceEpoch,
    };
    if (image != null) {
      resources.put(image, former: former?.imagePath);
    }
    if (former?.id == null) {
      txn.insert(tableName, dataToBeInserted);
    } else {
      txn.update(tableName, dataToBeInserted,
          where: "${_RecipeStepColumns.id} = ?", whereArgs: [former!.id]);
    }
  }

  Future<void> remove(Batch batch, int id, {RecipeStepModel? former}) async {
    if (former?.imagePath != null) {
      await resources.remove(former!.imagePath!);
    }
    batch.delete(tableName,
        where: "${_RecipeStepColumns.id.name} = ?", whereArgs: [id]);
  }

  Future<void> removeAll(Transaction txn, int recipeId) async {
    await txn.delete(tableName,
        where: "${_RecipeStepColumns.recipeId.name} = ?",
        whereArgs: [recipeId]);
  }

  Future<List<Map<String, Object?>>> getAll({
    Transaction? txn,
    required int recipeId,
  }) async {
    return (txn ?? db).query(tableName,
        where: "${_RecipeStepColumns.recipeId.name} = ?",
        whereArgs: [recipeId],
        orderBy: _RecipeStepColumns.id.name);
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
