import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../visited_url.dart';
import '../database_helper.dart';

class DatabasePagesTable {
  static final Logger _logger = Logger();

  static const table = 'pagesTable';
  static const columnId = '_id';
  static const columnContent = 'content';
  static const columnDate = 'date';
  static const columnUrl = 'url';

  static Future onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnContent TEXT UNIQUE,
      $columnUrl TEXT,
      $columnDate INTEGER
      )
    ''');
    batch.commit();
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

  static void add(VisitedURL page) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    bool notExists = true;
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
    visitedUrls.forEach((page) {
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
    });
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

  static Future<void> drop() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Dropping $table");
    return await db.execute('DROP TABLE IF EXISTS $table');
  }
}
