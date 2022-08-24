import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'database_content_table.dart';
import 'database_event_table.dart';

class DatabaseEventContentTable {
  static final Logger _logger = Logger();

  static const table = 'event_contentTable';

  static const columnContentId = 'content_id';
  static const columnEventId = 'event_id';

/*  static String initScript = '''
      CREATE TABLE event_contentTable(
      content_id INTEGER,
      event_id INTEGER,
      PRIMARY KEY (`content_id`, `event_id`),
      FOREIGN KEY (`event_id`) REFERENCES `eventTable` (`_id`),
      FOREIGN KEY (`content_id`) REFERENCES `contentTable` (`_id`)
      )
    ''';*/

  static Future onCreate(Database db) async {
    db.execute('''
      CREATE TABLE $table(
      $columnContentId INTEGER,
      $columnEventId INTEGER,
      PRIMARY KEY (`$columnContentId`, `$columnEventId`),
      FOREIGN KEY (`$columnEventId`) REFERENCES `${DatabaseEventTable.table}` (`${DatabaseEventTable.columnId}`),
      FOREIGN KEY (`$columnContentId`) REFERENCES `${DatabaseContentTable.table}` (`${DatabaseContentTable.columnId}`)
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<int>> getContendIdsFromEventId(int eventId) async {
    List<EventContentDBConnection> list =
        await _filter(id: eventId, column: columnEventId);
    return list.map((e) => e.contentId).toList();
  }

  static Future<List<int>> getEventIdsFromContentId(int contentId) async {
    List<EventContentDBConnection> list =
        await _filter(id: contentId, column: columnContentId);
    return list.map((e) => e.eventId).toList();
  }

  static Future<List<EventContentDBConnection>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
    );
    List<EventContentDBConnection> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => EventContentDBConnection.fromMap(e)).toList()
        : [];
    return rowsList;
  }

  static Future<List<EventContentDBConnection>> _filter(
      {required int id, required String column}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    List<EventContentDBConnection> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => EventContentDBConnection.fromMap(e)).toList()
        : [];
    return rowsList;
  }

  static Future<int> add(
      EventContentDBConnection eventContentDBConnection) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int insertedID = await db.insert(
      table,
      eventContentDBConnection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $eventContentDBConnection into $table");
    return insertedID;
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

  static Future<void> addBatch(
      List<EventContentDBConnection> eventContentDBConnections) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in eventContentDBConnections) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      //_logger.d("Inserted: $entry into $table as batch into $table");
    }
    batch.commit();
  }
}

class EventContentDBConnection {
  EventContentDBConnection({required this.contentId, required this.eventId});

  final int contentId;
  final int eventId;

  @override
  String toString() {
    return 'EventContentDBConnection{content_id: $contentId, event_id: $eventId}';
  }

  factory EventContentDBConnection.fromMap(Map<String, dynamic> json) =>
      EventContentDBConnection(
        eventId: json[DatabaseEventContentTable.columnEventId],
        contentId: json[DatabaseEventContentTable.columnContentId],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseEventContentTable.columnEventId: eventId,
      DatabaseEventContentTable.columnContentId: contentId,
    };
  }
}
