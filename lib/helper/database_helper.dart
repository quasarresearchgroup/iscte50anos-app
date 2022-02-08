import 'dart:io';

import 'package:IscteSpots/models/visited_page.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 6;

  static const table = 'pagesTable';

  static const columnId = '_id';
  static const columnContent = 'content';
  static const columnDate = 'date';
  static const columnUrl = 'url';

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnContent TEXT UNIQUE,
      $columnUrl TEXT,
      $columnDate INTEGER
      )
    ''');
  }

  Future<List<VisitedPage>> getPages() async {
    Database db = await instance.database;
    var pages = await db.query(table, orderBy: columnContent);
    List<VisitedPage> pageList = pages.isNotEmpty
        ? pages.map((e) => VisitedPage.fromMap(e)).toList()
        : [];
    return pageList;
  }

  void add(VisitedPage page) async {
    Database db = await instance.database;
    bool notExists = true;
    db.query(table, where: '$columnContent = ?', whereArgs: [
      page.content
    ]).then((e) => {
          notExists = e.isEmpty,
          if (notExists)
            {
              db.insert(
                table,
                page.toMap(),
                conflictAlgorithm: ConflictAlgorithm.abort,
              )
            }
        });
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> removeALL() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
