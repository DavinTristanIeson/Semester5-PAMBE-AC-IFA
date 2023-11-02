import 'package:sqflite/sqflite.dart';

class SqfliteMigration {
  final int version;
  Future<void> Function(Transaction) create;
  Future<void> Function(Transaction) upgrade;
  SqfliteMigration(this.version, {required this.create, required this.upgrade});
}

class SqfliteMigrationVersionError implements Exception {
  final String msg;
  const SqfliteMigrationVersionError(this.msg);
}

class MigrationManager {
  final List<SqfliteMigration> migrations;

  /// Class takes ownership. Caller is expected not to modify the list any further.
  MigrationManager(this.migrations) {
    migrations.sort((a, b) => a.version.compareTo(b.version));
    int version = 1;
    if (migrations.isEmpty) {
      throw const SqfliteMigrationVersionError(
          "Expected at least migration for the first version!");
    }
    for (SqfliteMigration migrate in migrations) {
      if (migrate.version != version) {
        throw SqfliteMigrationVersionError(
            "Expected version number: $version, but found ${migrate.version} instead. All migrations should be included.");
      }
      version++;
    }
  }
  SqfliteMigration at(int version) {
    return migrations[version - 1];
  }

  Future<void> upgrade(
      Database database, int previousVersion, int currentVersion) async {
    // Safe to do because migrations cannot be empty in the constructor constraints
    if (migrations.last.version < previousVersion ||
        migrations.last.version < currentVersion) {
      throw SqfliteMigrationVersionError(
          "Migration from $previousVersion to $currentVersion cannot be performed because the last possible version is ${migrations.last.version}");
    }
    await database.transaction((txn) async {
      for (int version = previousVersion + 1;
          version <= currentVersion;
          version++) {
        await migrations[version - 1].upgrade(txn);
      }
    });
  }

  Future<void> create(Database database, int version) {
    return database.transaction((txn) async {
      return migrations[version - 1].create(txn);
    });
  }
}
