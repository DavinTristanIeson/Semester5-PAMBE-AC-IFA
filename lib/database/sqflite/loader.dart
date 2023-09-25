import 'package:pambe_ac_ifa/database/sqflite/migration.dart';
import 'package:sqflite/sqflite.dart';

// Note: This is not tested yet. Use with caution.
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

  Future<Database> open(String databaseName) async {
    return await openDatabase(databaseName,
        version: 1,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        singleInstance: true,
        onUpgrade: _onUpgrade);
  }
}
