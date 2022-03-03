import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/pages_table.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 6;

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  final DatabasePagesTable pagesTable = DatabasePagesTable(instance: instance);
  final DatabaseContentsTable contentsTable =
      DatabaseContentsTable(instance: instance);

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  Future _onCreate(Database db, int version) async {
    await pagesTable.onCreate(db, version);
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }
}
