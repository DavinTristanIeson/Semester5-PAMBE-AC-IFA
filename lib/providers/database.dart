import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider extends ChangeNotifier {
  final Database db;
  DatabaseProvider(this.db);
}
