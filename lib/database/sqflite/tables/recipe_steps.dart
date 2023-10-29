import 'package:pambe_ac_ifa/common/extensions.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:sqflite/sqflite.dart';

enum RecipeStepColumns {
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
  RecipeStepsTable(this.db);

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
          CREATE TABLE $tableName (
            ${RecipeStepColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${RecipeStepColumns.recipeId} INTEGER,
            ${RecipeStepColumns.content} TEXT NOT NULL, 
            ${RecipeStepColumns.type} TEXT NOT NULL, 
            ${RecipeStepColumns.timer} INTEGER, 
            ${RecipeStepColumns.imagePath} TEXT, 
            ${RecipeStepColumns.createdAt} INTEGER NOT NULL,
            FOREIGN KEY (${RecipeStepColumns.recipeId}) REFERENCES ${RecipeTable.tableName}(id)
          );
      ''');
  }

  void put(Batch txn,
      {required int recipeId,
      required String content,
      required String type,
      String? imagePath,
      int? timer,
      int? id}) async {
    final dataToBeInserted = {
      RecipeStepColumns.recipeId.name: recipeId,
      RecipeStepColumns.content.name: content,
      RecipeStepColumns.type.name: type,
      RecipeStepColumns.timer.name: timer,
      RecipeStepColumns.imagePath.name: imagePath,
      RecipeStepColumns.createdAt.name: DateTime.now().millisecondsSinceEpoch,
    };
    if (id == null) {
      txn.insert(tableName, dataToBeInserted);
    } else {
      txn.update(tableName, dataToBeInserted,
          where: "${RecipeStepColumns.id.name} = ?", whereArgs: [id]);
    }
  }

  Future<void> remove(Batch batch, int id) async {
    batch.delete(tableName,
        where: "${RecipeStepColumns.id.name} = ?", whereArgs: [id]);
  }

  Future<void> removeAll(Transaction txn, int recipeId) async {
    await txn.delete(tableName,
        where: "${RecipeStepColumns.recipeId.name} = ?", whereArgs: [recipeId]);
  }

  Future<List<String>> getAllImages() async {
    final allRows = await db.query(tableName,
        where: "${RecipeStepColumns.imagePath.name} IS NOT NULL",
        columns: [RecipeStepColumns.imagePath.name]);
    return allRows
        .map((row) => row[RecipeStepColumns.imagePath.name] as String)
        .toList();
  }

  Future<List<Map<String, Object?>>> getAllFromRecipe({
    Transaction? txn,
    required int recipeId,
  }) async {
    return (txn ?? db).query(tableName,
        where: "${RecipeStepColumns.recipeId.name} = ?",
        whereArgs: [recipeId],
        orderBy: RecipeStepColumns.id.name);
  }

  Future<void> putMany(
    Transaction txn, {
    required int recipeId,
    required List<RecipeStepFormType> steps,
  }) async {
    final batch = txn.batch();
    final formerSteps = await getAllFromRecipe(recipeId: recipeId, txn: txn);

    final [newSteps, existingSteps] = steps.categorize((step) {
      return step.id == null ? 0 : 1;
    }, 2);

    // This is ugly but it's 23:18
    final List<RecipeStepFormType> overwritingSteps = [];
    final [discardedSteps] = formerSteps.categorize((element) {
      final associatedStep =
          existingSteps.find((step) => step.id == element["id"] as int);
      if (associatedStep != null) {
        overwritingSteps.add(associatedStep);
        return null;
      } else {
        return 0;
      }
    }, 1);

    for (final step in newSteps) {
      put(
        batch,
        recipeId: recipeId,
        content: step.content,
        type: step.type.name,
        timer: step.timer?.inMilliseconds,
        imagePath: step.image?.path,
      );
    }
    for (final step in overwritingSteps) {
      put(
        batch,
        recipeId: recipeId,
        content: step.content,
        type: step.type.name,
        timer: step.timer?.inMilliseconds,
        imagePath: step.image?.path,
        id: step.id,
      );
    }
    for (final step in discardedSteps) {
      remove(batch, step[RecipeStepColumns.id.name] as int);
    }
    await batch.commit(noResult: true);
  }
}
