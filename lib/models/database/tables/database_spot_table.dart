import 'package:iscte_spots/models/spot.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

class DatabaseSpotTable {
  static final Logger _logger = Logger();

  static const table = 'spotTable';

  static const columnId = '_id';
  static const columnPhotoLink = 'photo_link';
  static const columnVisited = 'visited';

  static Future onCreate(Database db) async {
    var sql = '''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnPhotoLink TEXT UNIQUE,
      $columnVisited BOOLEAN NOT NULL CHECK ( $columnVisited IN ( 0 , 1 ) ) DEFAULT 0
      )
    ''';

    db.execute(sql);
    _logger.d("Created $table with sql: \n $sql");
  }

  static Future<List<Spot>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnPhotoLink);
    List<Spot> contentList = contents.isNotEmpty
        ? contents.map((e) => Spot.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<List<Spot>> where(
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    List<Spot> contentList = contents.isNotEmpty
        ? contents.map((e) => Spot.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static void add(Spot spot) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.insert(
      table,
      spot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $spot into $table");
  }

  static Future<void> addBatch(List<Spot> spots) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in spots) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
    _logger.d("Inserted: $spots into $table as batch");
    batch.commit();
  }

  static Future<int> update(Spot spot) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Updating entry: $spot from $table");
    return await db.update(table, spot.toMap(),
        where: "$columnId = ?", whereArgs: [spot.id]);
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

  static Future<List<Spot>> getAllWithIds(List<int> idList) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      orderBy: columnId,
      where: '$columnId IN (${List.filled(idList.length, '?').join(',')})',
      whereArgs: idList,
    );
    List<Spot> rowsList =
        rawRows.isNotEmpty ? rawRows.map((e) => Spot.fromMap(e)).toList() : [];
    return rowsList;
  }
}
