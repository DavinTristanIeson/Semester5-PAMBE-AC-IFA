import 'package:image_picker/image_picker.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_images.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_steps.dart';
import 'package:pambe_ac_ifa/models/container.dart';
import 'package:pambe_ac_ifa/models/recipe.dart';
import 'package:pambe_ac_ifa/pages/editor/components/models.dart';
import 'package:sqflite/sqflite.dart';

enum _RecipeColumns {
  id,
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
  late final LocalRecipeImageManager imageManager;
  RecipeTable(this.db, {required this.imageManager}) {
    stepsController = RecipeStepsTable(db);
  }

  static Future<void> initialize(Transaction txn) {
    return txn.execute('''
        CREATE TABLE $tableName (
            ${_RecipeColumns.id} INTEGER PRIMARY KEY AUTOINCREMENT, 
            ${_RecipeColumns.remoteId} TEXT, 
            ${_RecipeColumns.title} VARCHAR(255) NOT NULL,
            ${_RecipeColumns.description} TEXT, 
            ${_RecipeColumns.createdAt} INTEGER NOT NULL,
            ${_RecipeColumns.imagePath} TEXT
        );
    ''');
  }

  Future<void> cleanupUnusedImages() async {
    final allRecipes = await db.query(tableName,
        where: "${_RecipeColumns.imagePath} IS NOT NULL",
        columns: [_RecipeColumns.imagePath.name]);
    final allRecipeImages = allRecipes
        .map((e) => e[_RecipeColumns.imagePath.name] as String)
        .toList();
    final allStepRecipeImages = await stepsController.getAllImages();
    allRecipeImages.addAll(allStepRecipeImages);
    await imageManager.deleteUnusedImagesTask(
        databaseImagePaths: allRecipeImages);
  }

  Future<LocalRecipeModel?> get(int id) async {
    final data = (await db.query(
      tableName,
      where: "${_RecipeColumns.id} = ?",
      whereArgs: [id],
      limit: 1,
    ))
        .firstOrNull;

    if (data == null) return null;
    final steps = await stepsController.getAllFromRecipe(recipeId: id);
    Map<String, dynamic> json = Map.from(data);
    json["steps"] = steps;
    return LocalRecipeModel.fromJson(json);
  }

  Future<List<LocalRecipeLiteModel>> getAll({
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
        .map<LocalRecipeLiteModel>(
            (result) => LocalRecipeLiteModel.fromJson(result))
        .toList();
  }

  Future<LocalRecipeModel> put(
      {required String title,
      String? description,
      required List<RecipeStepFormType> steps,
      XFile? image,
      int? id}) async {
    LocalRecipeModel? former;
    if (id != null) {
      former = await get(id);
    }
    final (image: recipeImage, :reserved) = await imageManager
        .markRecipeImagesForStorage(steps: steps, former: former, image: image);
    int lastId = await db.transaction((txn) async {
      int lastId;
      Map<String, dynamic> data = {
        _RecipeColumns.title.name: title,
        _RecipeColumns.description.name: description,
        _RecipeColumns.createdAt.name: DateTime.now().millisecondsSinceEpoch,
        _RecipeColumns.imagePath.name: recipeImage,
      };
      if (id == null) {
        lastId = await txn.insert(tableName, data);
      } else {
        await txn.update(tableName, data,
            where: "${_RecipeColumns.id.name} = ?", whereArgs: [id]);
        lastId = id;
      }
      await stepsController.putMany(txn, recipeId: lastId, steps: steps);
      return lastId;
    });
    await imageManager.imageManager.process(reserved);
    return (await get(lastId))!;
  }

  Future<void> remove(int id) async {
    final former = await get(id);
    if (former == null) return;
    final reserved = imageManager.markRecipeImagesForRemoval(former);

    await db.transaction((txn) async {
      await stepsController.removeAll(txn, id);
      await txn.delete(tableName,
          where: "${_RecipeColumns.id.name} = ?", whereArgs: [id]);
    });
    await imageManager.imageManager.process(reserved);
  }

  Future<void> setRemoteId(int localId, String? remoteId) async {
    await db.update(
        tableName,
        {
          _RecipeColumns.remoteId.name: remoteId,
        },
        where: "${_RecipeColumns.id.name} = ?",
        whereArgs: [localId]);
  }
}