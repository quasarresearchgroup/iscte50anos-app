import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../../timeline/event.dart';
import '../database_helper.dart';

class DatabaseEventTable {
  static final Logger _logger = Logger();

  static const table = 'eventTable';

  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnDate = 'date';
  static const columnScope = 'scope';
  static const columnVisited = 'visited';

/*  static String initScript = '''
      CREATE TABLE eventTable(
      _id INTEGER PRIMARY KEY,
      title TEXT,
      date INTEGER,
      scope TEXT CHECK ( scope IN ('iscte', 'portugal', 'world') ) DEFAULT 'world'
      )
    ''';*/

  static Future onCreate(Database db) async {
    var sql = '''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT,
      $columnDate INTEGER,
      $columnVisited BOOLEAN NOT NULL CHECK ( $columnVisited IN ( 0 , 1 ) ) DEFAULT 0 ,
      $columnScope TEXT CHECK ( $columnScope IN  (${EventScope.values.map((e) => "'${e.name}'").join(", ")} ) )
      )
    ''';

    db.execute(sql);
    //$columnScope TEXT CHECK ( $columnScope IN  ('iscte', 'nacional', 'internacional') )
    //$columnScope TEXT CHECK ( $columnScope IN ( '${EventScope.values.join(", ")}' ) )
    _logger.d("Created $table with sql: \n $sql");
  }

  static Future<List<Event>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnTitle);
    List<Event> contentList = contents.isNotEmpty
        ? contents.map((e) => Event.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<List<Event>> where(
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    List<Event> contentList = contents.isNotEmpty
        ? contents.map((e) => Event.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static void add(Event content) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.insert(
      table,
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $content into $table");
  }

  static Future<void> addBatch(List<Event> contents) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in contents) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      //_logger.d("Inserted: $entry into $table as batch into $table");
    }
    batch.commit();
  }

  static Future<int> update(Event event) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Updating entry:$event from $table");
    return await db.update(table, event.toMap(),
        where: "$columnId = ?", whereArgs: [event.id]);
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

  static Future<List<Event>> getAllWithIds(List<int> idList) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      orderBy: columnDate,
      where: '$columnId IN (${List.filled(idList.length, '?').join(',')})',
      whereArgs: idList,
    );
    List<Event> rowsList =
        rawRows.isNotEmpty ? rawRows.map((e) => Event.fromMap(e)).toList() : [];
    return rowsList;
  }
}
