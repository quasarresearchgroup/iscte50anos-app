import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_page_table.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final Logger _logger = Logger();
  static Database? _database;
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 13;

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<void> _onConfigure(Database db) async {
    String dbPath = join(db.path, _databaseName);
    _logger.d('db location : $dbPath');

    _logger.d('Started onConfigure to the db');
    String fkPragma = "PRAGMA foreign_keys = ON";
    await db.execute(fkPragma);
    _logger.d('executed: $fkPragma');
    _logger.d('Finished onConfigure to the db');
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.d('Started OnCreate to the db');
    await DatabasePageTable.onCreate(db);
    await DatabaseTopicTable.onCreate(db);
    await DatabaseEventTable.onCreate(db);
    await DatabaseContentTable.onCreate(db);
    await DatabaseEventTopicTable.onCreate(db);
    await DatabaseEventContentTable.onCreate(db);
    await DatabasePuzzlePieceTable.onCreate(db);
    await DatabaseSpotTable.onCreate(db);

    // await _createFKs(db);
    _logger.d('Finished OnCreate to the db');
  }

  Future<void> _dropAll(Database db) async {
    _logger.d('Started DropAll to the db');
    databaseFactory.deleteDatabase(db.path);

    _logger.d('Finished DropAll to the db');
  }

  Future<void> _removeAll() async {
    _logger.d('Started removeAll to the db');
    await DatabasePageTable.removeALL();
    await DatabaseContentTable.removeALL();
    await DatabaseEventTable.removeALL();
    await DatabaseTopicTable.removeALL();
    await DatabaseEventTopicTable.removeALL();
    await DatabaseEventContentTable.removeALL();
    await DatabasePuzzlePieceTable.removeALL();
    await DatabaseSpotTable.removeALL();
    _logger.d('Finished removeAll to the db');
  }

  Future<void> _onUpgradeDb(Database db, int oldversion, int newversion) async {
    if (oldversion != newversion) {
      _logger.d('Started Upgrade to the db');
      await _dropAll(db);
      await _onCreate(db, newversion);
      _logger.d('Finished Upgrade to the db');
    }
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    _logger.d('Started init db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    Database database = await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgradeDb,
      onDowngrade: onDatabaseDowngradeDelete,
    );

    return database;
  }
}
