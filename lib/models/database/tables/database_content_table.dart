import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../content.dart';
import '../database_helper.dart';

class DatabaseContentsTable {
  static final Logger _logger = Logger();

  static const table = 'contentsTable';

  static const columnId = '_id';
  static const columnTitle = 'content';
  static const columnLink = 'link';
  static const columnDate = 'date';
  static const columnScope = 'scope';
  static const columnType = 'type';

  static Future onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT,
      $columnLink TEXT,
      $columnDate INTEGER,
      $columnScope TEXT CHECK ( $columnScope IN ('iscte', 'portugal', 'world') ) DEFAULT 'world',
      $columnType TEXT CHECK ( $columnType IN ('image', 'video', 'web_page', 'social_media', 'doc', 'music')) DEFAULT 'web_page'
      )
    ''');
    batch.commit();
    _logger.d("Created $table");
  }

  static Future<List<Content>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnTitle);
    List<Content> contentList = contents.isNotEmpty
        ? contents.map((e) => Content.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static void add(Content content) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.insert(
      table,
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $content into $table");
  }

  static void addBatch(List<Content> contents) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    contents.forEach((entry) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      //_logger.d("Inserted: $entry into $table as batch into $table");
    });
    batch.commit();
  }

  static Future<int> remove(int id) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Removing entry with id:$id from $table");
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
