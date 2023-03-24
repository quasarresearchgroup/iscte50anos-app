import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_topic_table.dart';
import 'package:iscte_spots/models/database/tables/database_page_table.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/database/tables/database_topic_table.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const _databaseName = "IscteSpots.db";
  static const _databaseVersion = 16;

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<void> _onConfigure(Database db) async {
    String dbPath = join(db.path, _databaseName);
    LoggerService.instance.debug('db location : $dbPath');

    LoggerService.instance.debug('Started onConfigure to the db');
    String fkPragma = "PRAGMA foreign_keys = ON";
    await db.execute(fkPragma);
    LoggerService.instance.debug('executed: $fkPragma');
    LoggerService.instance.debug('Finished onConfigure to the db');
  }

  Future<void> _onCreate(Database db, int version) async {
    LoggerService.instance.debug('Started OnCreate to the db');
    await DatabasePageTable.onCreate(db);
    await DatabaseTopicTable.onCreate(db);
    await DatabaseEventTable.onCreate(db);
    await DatabaseContentTable.onCreate(db);
    await DatabaseEventTopicTable.onCreate(db);
    await DatabaseEventContentTable.onCreate(db);
    await DatabasePuzzlePieceTable.onCreate(db);
    await DatabaseSpotTable.onCreate(db);

    // await _createFKs(db);
    LoggerService.instance.debug('Finished OnCreate to the db');
  }

  Future<void> _dropAll(Database db) async {
    LoggerService.instance.debug('Started DropAll to the db');
    databaseFactory.deleteDatabase(db.path);

    LoggerService.instance.debug('Finished DropAll to the db');
  }

  Future<void> _removeAll() async {
    LoggerService.instance.debug('Started removeAll to the db');
    await DatabasePageTable.removeALL();
    await DatabaseContentTable.removeALL();
    await DatabaseEventTable.removeALL();
    await DatabaseTopicTable.removeALL();
    await DatabaseEventTopicTable.removeALL();
    await DatabaseEventContentTable.removeALL();
    await DatabasePuzzlePieceTable.removeALL();
    await DatabaseSpotTable.removeALL();
    LoggerService.instance.debug('Finished removeAll to the db');
  }

  Future<void> _onUpgradeDb(Database db, int oldversion, int newversion) async {
    if (oldversion != newversion) {
      LoggerService.instance.debug('Started Upgrade to the db');
      await _dropAll(db);
      await _onCreate(db, newversion);
      LoggerService.instance.debug('Finished Upgrade to the db');
    }
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    LoggerService.instance.debug('Started init db');
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
