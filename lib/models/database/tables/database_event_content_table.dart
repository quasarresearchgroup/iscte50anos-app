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

  static String initScript = '''
      CREATE TABLE event_contentTable(
      content_id INTEGER,
      event_id INTEGER,
      PRIMARY KEY (`topic_id`, `event_id`),
      FOREIGN KEY (`event_id`) REFERENCES `eventTable` (`_id`),
      FOREIGN KEY (`content_id`) REFERENCES `contentTable` (`_id`)
      )
    ''';

  static Future onCreate(Database db, int version) async {
    db.execute('''
      CREATE TABLE topic_eventTable(
      $columnContentId INTEGER,
      $columnEventId INTEGER,
      PRIMARY KEY (`$columnContentId`, `$columnEventId`),
      FOREIGN KEY (`$columnEventId`) REFERENCES `${DatabaseEventTable.table}` (`${DatabaseEventTable.columnId}`),
      FOREIGN KEY (`$columnContentId`) REFERENCES `${DatabaseContentTable.table}` (`${DatabaseContentTable.columnId}`)
      )
    ''');
    _logger.d("Created $table");
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
