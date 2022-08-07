import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../visited_url.dart';
import '../database_helper.dart';

class DatabasePageTable {
  static final Logger _logger = Logger();

  static const table = 'pageTable';
  static const columnId = '_id';
  static const columnContent = 'content';
  static const columnDate = 'date';
  static const columnUrl = 'url';
/*
  static String initScript = '''
      CREATE TABLE pageTable(
      _id INTEGER PRIMARY KEY,
      content TEXT UNIQUE,
      url TEXT,
      date INTEGER
      )
    ''';*/

  static Future onCreate(Database db) async {
    db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnContent TEXT UNIQUE,
      $columnUrl TEXT,
      $columnDate INTEGER
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<VisitedURL>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> pages =
        await db.query(table, orderBy: columnContent);
    List<VisitedURL> pageList = pages.isNotEmpty
        ? pages.map((e) => VisitedURL.fromMap(e)).toList()
        : [];
    _logger.d(pageList);
    return pageList;
  }

  static Future<void> add(VisitedURL page) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.query(table, where: '$columnContent = ?', whereArgs: [
      page.content
    ]).then((e) => {
          if (e.isEmpty)
            {
              db.insert(
                table,
                page.toMap(),
                conflictAlgorithm: ConflictAlgorithm.abort,
              ),
              _logger.d("Inserted: $page into $table")
            }
        });
  }

  static void addBatch(List<VisitedURL> visitedUrls) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var page in visitedUrls) {
      db.query(table, where: '$columnContent = ?', whereArgs: [
        page.content
      ]).then((e) => {
            batch.insert(
              table,
              page.toMap(),
              conflictAlgorithm: ConflictAlgorithm.abort,
            ),
            _logger.d("Inserted: $page into $table as batch into $table")
          });
    }
    batch.commit(noResult: true);
  }

  static Future<int> remove(int id) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Removed entry with id:$id from $table");
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> removeALL() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Removing all entries from $table");
    return await db.delete(table);
  }

  static Future<void> drop(Database db) async {
    _logger.d("Dropping $table");
    return await db.execute('DROP TABLE IF EXISTS $table');
  }
}
