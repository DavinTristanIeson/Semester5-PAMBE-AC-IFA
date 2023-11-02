import 'dart:io';

import 'package:pambe_ac_ifa/database/sqflite/lib/main.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/tables/recipe_steps.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initializeSqfliteDatabase({bool? override}) async {
  MigrationManager migrationManager = MigrationManager([
    SqfliteMigration(1, create: (Transaction transaction) async {
      await RecipeTable.initialize(transaction);
      await RecipeStepsTable.initialize(transaction);
    }, upgrade: (Transaction transaction) async {}),
  ]);

  final localImageDirectory =
      Directory(await LocalFileImageManager.getImageStoragePath());
  if (await localImageDirectory.exists()) {
    if (override == true) {
      await localImageDirectory.delete(recursive: true);
    }
  }
  await localImageDirectory.create(recursive: true);

  return SqfliteDatabaseLoader(migrationManager)
      .open(name: 'recipe-lib', override: override);
}
