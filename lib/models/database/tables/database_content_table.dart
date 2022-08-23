import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../timeline/content.dart';
import '../database_helper.dart';
import 'database_event_table.dart';

class DatabaseContentTable {
  static final Logger _logger = Logger();

  static const table = 'contentTable';

  static const columnId = '_id';
  static const columnDescription = 'description';
  static const columnLink = 'link';
  static const columnType = 'type';
  static const columnEventId = 'event_id';

  static Future onCreate(Database db) async {
    String eventTable = DatabaseEventTable.table;
    String eventTableID = DatabaseEventTable.columnId;
    db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnDescription TEXT,
      $columnLink TEXT,
      $columnType TEXT CHECK ( $columnType IN ('image', 'video', 'web_page', 'social_media', 'doc', 'music')) DEFAULT 'web_page',
      $columnEventId INTEGER,
      FOREIGN KEY (`$columnEventId`) REFERENCES `$eventTable` (`$eventTableID`)
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<Content>> getAllWithIds(List<int> idList) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      orderBy: columnType,
      where: '$columnId IN (${List.filled(idList.length, '?').join(',')})',
      whereArgs: idList,
    );
    List<Content> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => Content.fromMap(e)).toList()
        : [];
    return rowsList;
  }

  static Future<List<Content>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnType);

    List<Content> contentList = contents.isNotEmpty
        ? contents.map((e) => Content.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<int> add(Content content) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int insertedID = await db.insert(
      table,
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $content into $table");
    return insertedID;
  }

  static Future<void> addBatch(List<Content> contents) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in contents) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
    _logger.d("Inserted as batch into $table");
    await batch.commit();
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
