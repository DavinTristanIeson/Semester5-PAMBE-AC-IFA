import 'dart:io';

import 'package:pambe_ac_ifa/database/sqflite/lib/migration.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteDatabaseLoader {
  MigrationManager migrationManager;
  SqfliteDatabaseLoader(this.migrationManager);
  static Future<void> _onConfigure(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  Future<void> _onCreate(Database db, int version) {
    return migrationManager.create(db, version);
  }

  Future<void> _onUpgrade(
      Database db, int previousVersion, int currentVersion) {
    return migrationManager.upgrade(db, previousVersion, currentVersion);
  }

  Future<Database> open({
    required String name,
    bool? override,
  }) async {
    String databasePath = join(await getDatabasesPath(), name);
    if (override != null && override) {
      deleteDatabase(databasePath);
    }
    return await openDatabase(databasePath,
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        singleInstance: true,
        onUpgrade: _onUpgrade);
  }

  static Future<void> drop(Database db) async {
    await db.close();
    await File(db.path).delete();
  }
}
