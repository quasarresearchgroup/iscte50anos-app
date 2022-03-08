import 'dart:io';

import 'package:iscte_spots/models/database/tables/database_content_table.dart';
import 'package:iscte_spots/models/database/tables/database_event_table.dart';
import 'package:iscte_spots/models/database/tables/pages_table.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final Logger _logger = Logger();
  static Database? _database;
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 6;

  //  singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  Future<Database> get database async => _database ??= await _initDatabase();

  Future _onCreate(Database db, int version) async {
    _logger.d('Started OnCreate to the db');
    await DatabasePagesTable.onCreate(db, version);
    await DatabaseContentsTable.onCreate(db, version);
    await DatabaseEventTable.onCreate(db, version);
    _logger.d('Finished OnCreate to the db');
  }

  Future _dropAll(Database db) async {
    _logger.d('Started DropAll to the db');
    await DatabasePagesTable.drop();
    await DatabaseContentsTable.drop();
    await DatabaseEventTable.drop();
    _logger.d('Finished DropAll to the db');
  }

  Future _removeAll(Database db) async {
    _logger.d('Started removeAll to the db');
    await DatabasePagesTable.removeALL();
    await DatabaseContentsTable.removeALL();
    await DatabaseEventTable.removeALL();
    _logger.d('Finished removeAll to the db');
  }

  Future<void> _upgradeDb(db, int oldversion, int newversion) async {
    _logger.d('Started Upgrade to the db');
    //await _dropAll(db);
    await _onCreate(db, newversion);
    _logger.d('Finished Upgrade to the db');
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    _logger.d('Started init db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _upgradeDb,
        onDowngrade: _upgradeDb);
  }
}
