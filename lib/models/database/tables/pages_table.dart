import 'package:sqflite/sqflite.dart';

import '../../visited_page.dart';
import '../database_helper.dart';

class PagesTable {
  PagesTable({required this.instance});

  final DatabaseHelper instance;
  static const table = 'pagesTable';

  static const columnId = '_id';
  static const columnContent = 'content';
  static const columnDate = 'date';
  static const columnUrl = 'url';

  Future onCreate(Database db, int version) async {
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
