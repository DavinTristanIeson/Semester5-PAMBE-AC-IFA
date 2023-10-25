import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/interfaces/resource.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_steps.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/models/user.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:sqflite/sqflite.dart';

enum _RecipeColumns {
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

class RecipeTable {
  static const tableName = "recipes";

  final Database db;
  late final RecipeStepsTable stepsController;
  late final IImageResourceManager resources;
  RecipeTable(this.db, {required this.resources}) {
    stepsController = RecipeStepsTable(db, resources: resources);
  }

  static Future<void> initialize(Transaction txn) {
    return txn.execute(
        '''
        CREATE TABLE $tableName (
            ${_RecipeColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${_RecipeColumns.userId} TEXT NOT NULL, 
            ${_RecipeColumns.remoteId} TEXT, 
            ${_RecipeColumns.title} VARCHAR(255) NOT NULL,
            ${_RecipeColumns.description} TEXT, 
            ${_RecipeColumns.createdAt} INTEGER NOT NULL,
            ${_RecipeColumns.imagePath} TEXT
        );
    ''');
  }

  Future<RecipeModel?> get(int id, {required UserModel user}) async {
    final data = (await db.query(
      tableName,
      where: "${_RecipeColumns.id} = ?",
      whereArgs: [id],
      limit: 1,
    ))
        .firstOrNull;

    if (data == null) return null;
    final steps = await stepsController.getAll(recipeId: id);
    return RecipeModel.fromLocal(data, user, steps);
  }

  Future<List<RecipeLiteModel>> getAll({
    required UserModel user,
    String? search,
    int? limit,
    int? page,
    SortBy<RecipeSortBy>? sort,
    RecipeFilterBy? filter,
  }) async {
    final results = await db.query(tableName,
        where: search == null
            ? null
            : "${_RecipeColumns.title.name} LIKE ? OR ${_RecipeColumns.description.name} LIKE ?",
        whereArgs: search == null ? null : [search, search],
        limit: limit,
        offset: page == null ? null : (limit ?? 15) * (page - 1),
        orderBy: "${_RecipeColumns.createdAt.name} DESC");
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
        _RecipeColumns.title.name: title,
        _RecipeColumns.description.name: description,
        _RecipeColumns.createdAt.name: DateTime.now().millisecondsSinceEpoch,
        _RecipeColumns.userId.name: user.id,
        _RecipeColumns.imagePath.name: image?.path,
      };
      if (former == null) {
        lastId = await txn.insert(tableName, data);
      } else {
        await txn.update(tableName, data,
            where: "${_RecipeColumns.id.name} = ?",
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
          where: "${_RecipeColumns.id.name} = ?", whereArgs: [recipe.id]);
    });
  }

  Future<void> setRemoteId(int localId, int? remoteId) async {
    await db.update(
        tableName,
        {
          _RecipeColumns.remoteId.name: remoteId,
        },
        where: "${_RecipeColumns.id.name} = ?",
        whereArgs: [localId]);
  }
}
