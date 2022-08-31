import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

class DatabasePuzzlePieceTable {
  static final Logger _logger = Logger();

  static const table = 'puzzlePieceTable';

  static const columnSpotId = "spot_id";
  static const columnRow = "row";
  static const columnColumn = "column";
  static const columnMaxRow = "max_row";
  static const columnMaxColumn = "max_column";
  static const columnLeft = "left";
  static const columnTop = "top";

  /* static String initScript = '''
      CREATE TABLE puzzlePieceTable(
      row INTEGER NOT NULL,
      column INTEGER NOT NULL,
      max_row INTEGER NOT NULL,
      max_column INTEGER NOT NULL,
      left REAL NOT NULL,
      top REAL NOT NULL,
      PRIMARY KEY( row,  column )
      )
    ''';*/

  static Future onCreate(Database db) async {
    db.execute('''
      CREATE TABLE $table(
      $columnSpotId INTEGER NOT NULL,
      $columnRow INTEGER NOT NULL,
      $columnColumn INTEGER NOT NULL,
      $columnMaxRow INTEGER NOT NULL,
      $columnMaxColumn INTEGER NOT NULL,
      $columnLeft REAL NOT NULL,
      $columnTop REAL NOT NULL,
      PRIMARY KEY( $columnRow,  $columnColumn ),
      FOREIGN KEY (`$columnSpotId`) REFERENCES `${DatabaseSpotTable.table}` (`${DatabaseSpotTable.columnId}`)
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<PuzzlePiece>> getAll({int? row, int? col}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = row != null && col != null
        ? await db.query(table,
            where: '$columnRow = ? AND $columnColumn = ?',
            whereArgs: [row, col])
        : await db.query(table);

    List<PuzzlePiece> contentList = contents.isNotEmpty
        ? contents.map((e) => PuzzlePiece.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<List<PuzzlePiece>> getAllFromSpot(int spotId,
      {int? row, int? col}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = row != null && col != null
        ? await db.query(
            table,
            where: '$columnSpotId = ? AND $columnRow = ? AND $columnColumn = ?',
            whereArgs: [spotId, row, col],
          )
        : await db.query(
            table,
            where: '$columnSpotId = ?',
            whereArgs: [spotId],
          );

    List<PuzzlePiece> contentList = contents.isNotEmpty
        ? contents.map((e) => PuzzlePiece.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<void> add(PuzzlePiece puzzlePiece) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    await db.insert(
      table,
      puzzlePiece.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _logger.d("Inserted: $puzzlePiece into $table");
  }

  static Future<void> addBatch(List<PuzzlePiece> contents) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in contents) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit();
    _logger.d("Inserted as batch into $table");
  }

  static Future<int> update(PuzzlePiece piece) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int i = await db.update(table, piece.toMap(),
        where: '$columnRow = ? AND $columnColumn = ?',
        whereArgs: [piece.row, piece.column],
        conflictAlgorithm: ConflictAlgorithm.replace);
    _logger.d("Updating entry: $piece from $table");
    return i;
  }

  static Future<int> remove(int row, int column) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    _logger.d("Removing entry with row:$row and column:$column from $table");
    return await db.delete(table,
        where: '$columnRow = ? AND $columnColumn = ?',
        whereArgs: [row, column]);
  }

  static Future<int> removeALL() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int result = await db.delete(table);
    _logger.d("Removing all entries from $table");
    return result;
  }

  static Future<void> drop(Database db) async {
    var result = await db.execute('DROP TABLE IF EXISTS $table');
    _logger.d("Dropping $table");
    return result;
  }
}
