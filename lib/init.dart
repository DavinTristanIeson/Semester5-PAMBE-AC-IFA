import 'dart:io';

import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/loader.dart';
import 'package:pambe_ac_ifa/database/sqflite/migration.dart';
import 'package:pambe_ac_ifa/database/sqflite/resource.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initializeSqfliteDatabase({bool? override}) async {
  MigrationManager migrationManager = MigrationManager([
    SqfliteMigration(1, create: (Transaction transaction) async {
      await LocalRecipeController.initialize(transaction);
      await LocalRecipeStepsController.initialize(transaction);
    }, upgrade: (Transaction transaction) async {}),
  ]);

  final localImageDirectory =
      Directory(await LocalImageController.getImageStoragePath());
  if (await localImageDirectory.exists()) {
    if (override == true) {
      await localImageDirectory.delete(recursive: true);
    }
  } else {
    await localImageDirectory.create(recursive: true);
  }

  return SqfliteDatabaseLoader(migrationManager)
      .open(name: 'recipe-lib', override: override);
}
