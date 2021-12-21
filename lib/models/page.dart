import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class VisitedPage {
  final int? id;
  final String content;

  VisitedPage({this.id, required this.content});

  factory VisitedPage.fromMap(Map<String, dynamic> json) =>
      VisitedPage(id: json["id"], content: json["content"]);

  Map<String, dynamic> toMap() {
    return {'id': id, 'content': content};
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'visitedpages.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE page(
      id INTEGER PRIMARY KEY,
      content TEXT UNIQUE
      )
    ''');
  }

  Future<List<VisitedPage>> getPages() async {
    Database db = await instance.database;
    var pages = await db.query('page', orderBy: 'content');
    List<VisitedPage> pageList = pages.isNotEmpty
        ? pages.map((e) => VisitedPage.fromMap(e)).toList()
        : [];
    return pageList;
  }

  void add(VisitedPage page) async {
    Database db = await instance.database;
    bool notExists = true;
    db.query('page', where: 'content = ?', whereArgs: [page.content]).then(
        (e) => {
              notExists = e.isEmpty,
              if (notExists)
                {
                  db.insert(
                    'page',
                    page.toMap(),
                    conflictAlgorithm: ConflictAlgorithm.abort,
                  )
                }
            });
  }

  Future<int> remove(int id) async {
    Database db = await instance.database;
    return await db.delete('page', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> removeALL() async {
    Database db = await instance.database;
    return await db.delete('page');
  }
}
