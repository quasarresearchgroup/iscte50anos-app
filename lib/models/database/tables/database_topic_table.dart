import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../topic.dart';
import '../database_helper.dart';

class DatabaseTopicTable {
  static final Logger _logger = Logger();

  static const table = 'topicTable';

  static const columnId = '_id';
  static const columnDescription = 'title';
  static const columnLink = 'link';

  static Future onCreate(Database db, int version) async {
    db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnDescription TEXT,
      $columnLink TEXT
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<Topic>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows =
        await db.query(table, orderBy: columnDescription);
    List<Topic> rowsList =
        rawRows.isNotEmpty ? rawRows.map((e) => Topic.fromMap(e)).toList() : [];
    return rowsList;
  }

  static void add(Topic entry) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.insert(
      table,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $entry into $table");
  }

  static void addBatch(List<Topic> entries) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in entries) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      //_logger.d("Inserted: $entry into $table as batch into $table");
    }
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

  static Future<void> drop(Database db) async {
    _logger.d("Dropping $table");
    return await db.execute('DROP TABLE IF EXISTS $table');
  }
}
