import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

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

/*
  static Future onCreate(Database db, int version) async {
    String eventTable = DatabaseEventTable.table;
    String eventTableID = DatabaseEventTable.columnId;
    String contentTable = DatabaseContentTable.table;
    String contentTableID = DatabaseContentTable.columnId;

    db.execute('''
      CREATE TABLE topic_eventTable(
      topic_id INTEGER,
      event_id INTEGER,
      PRIMARY KEY (`topic_id`, `event_id`),
      FOREIGN KEY (`event_id`) REFERENCES `eventTable` (`_id`),
      FOREIGN KEY (`topic_id`) REFERENCES `contentTable` (`_id`)
      )
    ''');
    _logger.d("Created $table");
  }
*/

/*
  static Future onFKCreate(Database db) async {
    String eventTable = DatabaseEventTable.table;
    String eventTableID = DatabaseEventTable.columnId;
    String contentTable = DatabaseContentTable.table;
    String contentTableID = DatabaseContentTable.columnId;

    db.execute('''
      ALTER TABLE `$table` ADD FOREIGN KEY (`$columnEventId`) REFERENCES `$eventTable` (`$eventTableID`);
    ''');
    db.execute('''
      ALTER TABLE `$table` ADD FOREIGN KEY (`$columnTopicId`) REFERENCES `$contentTable` (`$contentTableID`);
    ''');
    _logger.d("Added FK to $table");
  }
*/

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
