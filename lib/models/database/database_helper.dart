import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_page_table.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final Logger _logger = Logger();
  static Database? _database;
  static const _databaseName = "MyDatabase.db";

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

//reference for migration https://medium.com/flutter-community/migrating-a-mobile-database-in-flutter-sqlite-44ac618e4897

  // Initialization script split into seperate statements
  static List<String> initScript = [
    DatabasePageTable.initScript,
    DatabaseTopicTable.initScript,
    DatabaseEventTable.initScript,
    DatabaseContentTable.initScript,
    DatabaseEventTopicTable.initScript,
    DatabasePuzzlePieceTable.initScript,
  ];

  // Migration sql scripts, containing a single statements per migration
  static List<String> migrationScripts = [
    '''
    DROP TABLE topic_eventTable 
    ''',
    ""
  ];

  //DatabasePageTable.migrationScripts,
  //  DatabaseTopicTable.migrationScripts,
  //  DatabaseEventTable.migrationScripts,
  //  DatabaseContentTable.migrationScripts,
  //  DatabaseTopicEventTable.migrationScripts,
  //  DatabasePuzzlePieceTable.migrationScripts,

  _onConfigure(Database db) async {
    // Add support for cascade delete
    _logger.d('Started onConfigure to the db');
    String fkPragma = "PRAGMA foreign_keys = ON";
    await db.execute(fkPragma);
    _logger.d('executed: $fkPragma');
    _logger.d('Finished onConfigure to the db');
  }

/*
  Future _onCreate(Database db, int version) async {
    _logger.d('Started OnCreate to the db');
    await DatabasePageTable.onCreate(db, version);
    await DatabaseTopicTable.onCreate(db, version);
    await DatabaseEventTable.onCreate(db, version);
    await DatabaseContentTable.onCreate(db, version);
    await DatabaseTopicEventTable.onCreate(db, version);
    await DatabasePuzzlePieceTable.onCreate(db, version);

    // await _createFKs(db);
    _logger.d('Finished OnCreate to the db');
  }
*/

  /*Future _dropAll(db) async {
    _logger.d('Started DropAll to the db');
*/ /*
    String sql_query = """SELECT name FROM sqlite_master WHERE type='table';""";
    List<Map<String, Object?>> query = await db.query('sqlite_master');
    _logger.d(query);*/ /*

    await DatabasePageTable.drop(db);
    await DatabaseContentTable.drop(db);
    await DatabaseEventTable.drop(db);
    await DatabaseTopicTable.drop(db);
    await DatabaseTopicEventTable.drop(db);
    await DatabasePuzzlePieceTable.drop(db);

    _logger.d('Finished DropAll to the db');
  }

  Future _removeAll() async {
    _logger.d('Started removeAll to the db');
    await DatabasePageTable.removeALL();
    await DatabaseContentTable.removeALL();
    await DatabaseEventTable.removeALL();
    await DatabaseTopicTable.removeALL();
    await DatabaseTopicEventTable.removeALL();
    await DatabasePuzzlePieceTable.removeALL();
    _logger.d('Finished removeAll to the db');
  }
*/
/*
  Future<void> _upgradeDb(db, int oldversion, int newversion) async {
    if (oldversion != newversion) {
      _logger.d('Started Upgrade to the db');
      await _dropAll(db);
      await _onCreate(db, newversion);
      _logger.d('Finished Upgrade to the db');
    }
  }
*/

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    _logger.d('Started init db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    Database database = await openDatabase(
      path,
      version: migrationScripts.length + 1,
      onConfigure: _onConfigure,
      onCreate: (Database db, int version) async {
        initScript.forEach((script) async => await db.execute(script));
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        for (var i = oldVersion - 1; i <= newVersion - 1; i++) {
          print(migrationScripts);
          print(i);
          await db.execute(migrationScripts[i]);
        }
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );

    return database;
  }
}
