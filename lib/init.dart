import 'package:pambe_ac_ifa/controllers/local_recipe.dart';
import 'package:pambe_ac_ifa/database/sqflite/loader.dart';
import 'package:pambe_ac_ifa/database/sqflite/migration.dart';
import 'package:sqflite/sqflite.dart';

Future<Database> initializeSqfliteDatabase() {
  MigrationManager migrationManager = MigrationManager([
    SqfliteMigration(1, create: (Transaction transaction) async {
      await LocalRecipeController.initialize(transaction);
      await LocalRecipeStepsController.initialize(transaction);
    }, upgrade: (Transaction transaction) async {}),
  ]);
  return SqfliteDatabaseLoader(migrationManager).open(name: 'recipe-lib');
}
