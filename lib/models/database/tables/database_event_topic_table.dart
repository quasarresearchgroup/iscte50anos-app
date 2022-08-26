import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';
import 'database_event_table.dart';

class DatabaseEventTopicTable {
  static final Logger _logger = Logger();

  static const table = 'topic_eventTable';

  static const columnTopicId = 'topic_id';
  static const columnEventId = 'event_id';

/*  static String initScript = '''
      CREATE TABLE topic_eventTable(
      topic_id INTEGER,
      event_id INTEGER,
      PRIMARY KEY (`topic_id`, `event_id`),
      FOREIGN KEY (`event_id`) REFERENCES `eventTable` (`_id`),
      FOREIGN KEY (`topic_id`) REFERENCES `contentTable` (`_id`) 
      )
    ''';*/

  static Future onCreate(Database db) async {
    db.execute('''
      CREATE TABLE $table(
      $columnTopicId INTEGER,
      $columnEventId INTEGER,
      PRIMARY KEY (`$columnTopicId`, `$columnEventId`),
      FOREIGN KEY (`$columnEventId`) REFERENCES `${DatabaseEventTable.table}` (`${DatabaseEventTable.columnId}`) ON DELETE CASCADE ON UPDATE CASCADE,
      FOREIGN KEY (`$columnTopicId`) REFERENCES `${DatabaseTopicTable.table}` (`${DatabaseTopicTable.columnId}`) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
    _logger.d("Created $table");
  }

  static Future<List<int>> getTopicIdsFromEventId(int eventId) async {
    List<EventTopicDBConnection> list =
        await _filter(id: eventId, column: columnEventId);
    return list.map((e) => e.topicId).toList();
  }

  static Future<List<int>> getEventIdsFromTopicId(int topicId) async {
    List<EventTopicDBConnection> list =
        await _filter(id: topicId, column: columnTopicId);
    return list.map((e) => e.eventId).toList();
  }

  static Future<List<EventTopicDBConnection>> _filter(
      {required int id, required String column}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      where: '$column = ?',
      whereArgs: [id],
    );
    List<EventTopicDBConnection> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => EventTopicDBConnection.fromMap(e)).toList()
        : [];
    return rowsList;
  }

  static Future<int> add(EventTopicDBConnection eventTopicDBConnection) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    int insertedID = await db.insert(
      table,
      eventTopicDBConnection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    _logger.d("Inserted: $eventTopicDBConnection into $table");
    return insertedID;
  }

  static Future<void> addBatch(
      List<EventTopicDBConnection> eventTopicDBConnections) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in eventTopicDBConnections) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      //_logger.d("Inserted: $entry into $table as batch into $table");
    }
    batch.commit();
  }

  static Future<List<EventTopicDBConnection>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
    );
    List<EventTopicDBConnection> rowsList = rawRows.isNotEmpty
        ? rawRows.map((e) => EventTopicDBConnection.fromMap(e)).toList()
        : [];
    return rowsList;
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

class EventTopicDBConnection {
  EventTopicDBConnection({required this.topicId, required this.eventId});

  final int topicId;
  final int eventId;

  @override
  String toString() {
    return 'EventTopicDBConnection{topic_id: $topicId, event_id: $eventId}';
  }

  factory EventTopicDBConnection.fromMap(Map<String, dynamic> json) =>
      EventTopicDBConnection(
        topicId: json[DatabaseEventTopicTable.columnTopicId],
        eventId: json[DatabaseEventTopicTable.columnEventId],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabaseEventTopicTable.columnTopicId: topicId,
      DatabaseEventTopicTable.columnEventId: eventId,
    };
  }
}
