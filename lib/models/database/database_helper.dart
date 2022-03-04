import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/pages_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 8;

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  Future _onCreate(Database db, int version) async {
    await DatabasePagesTable.onCreate(db, version);
    await DatabaseContentsTable.onCreate(db, version);
  }

  Future _dropAll(Database db) async {
    await DatabasePagesTable.removeALL();
    await DatabaseContentsTable.removeALL();
  }

  void _upgradeDb(db, int oldversion, int newversion) {
    _dropAll(db);
    _onCreate(db, newversion);
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _upgradeDb,
        onDowngrade: _upgradeDb);
  }
}
