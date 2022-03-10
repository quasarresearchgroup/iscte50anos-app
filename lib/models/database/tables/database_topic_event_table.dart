import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../database_helper.dart';

class DatabaseTopicEventTable {
  static final Logger _logger = Logger();

  static const table = 'topic_eventTable';

  static const columnTopicId = 'topic_id';
  static const columnEventId = 'event_id';

  static Future onCreate(Database db, int version) async {
    String eventTable = DatabaseEventTable.table;
    String eventTableID = DatabaseEventTable.columnId;
    String contentTable = DatabaseContentTable.table;
    String contentTableID = DatabaseContentTable.columnId;

    db.execute('''
      CREATE TABLE $table(
      $columnTopicId INTEGER,
      $columnEventId INTEGER,
      PRIMARY KEY (`topic_id`, `event_id`),
      FOREIGN KEY (`$columnEventId`) REFERENCES `$eventTable` (`$eventTableID`),
      FOREIGN KEY (`$columnTopicId`) REFERENCES `$contentTable` (`$contentTableID`)
      )
    ''');
    _logger.d("Created $table");
  }

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
