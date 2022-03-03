import 'package:sqflite/sqflite.dart';

import '../../timeline_item.dart';
import '../database_helper.dart';

class DatabaseContentsTable {
  DatabaseContentsTable({required this.instance});

  final DatabaseHelper instance;
  static const table = 'pagesTable';

  static const columnId = '_id';
  static const columnTitle = 'content';
  static const columnLink = 'link';
  static const columnDate = 'date';
  static const columnScope = 'scope';
  static const columnType = 'type';

  Future onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnTitle TEXT UNIQUE,
      $columnLink TEXT,
      $columnDate INTEGER,
      $columnScope ENUM('iscte', 'portugal', 'world'),
      $columnType ENUM('image', 'video', 'web_page', 'social_media', 'doc', 'music')
      )
    ''');
  }

  Future<List<Content>> getAll() async {
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnTitle);
    List<Content> pageList = contents.isNotEmpty
        ? contents.map((e) => Content.fromMap(e)).toList()
        : [];
    return pageList;
  }

  void add(Content content) async {
    Database db = await instance.database;
    db.insert(
      table,
      content.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> removeALL() async {
    Database db = await instance.database;
    return await db.delete(table);
  }
}
