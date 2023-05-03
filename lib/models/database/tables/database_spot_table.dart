import 'package:iscte_spots/models/database/database_helper.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseSpotTable {
  static const table = 'spotTable';

  static const columnId = '_id';
  static const columnPhotoLink = 'photo_link';
  static const columnVisited = 'visited';
  static const columnPuzzleComplete = 'puzzleComplete';

  static Future onCreate(Database db) async {
    var sql = '''
      CREATE TABLE $table(
      $columnId INTEGER PRIMARY KEY,
      $columnPhotoLink TEXT UNIQUE,
      $columnVisited BOOLEAN NOT NULL CHECK ( $columnVisited IN ( 0 , 1 ) ) DEFAULT 0,
      $columnPuzzleComplete BOOLEAN NOT NULL CHECK ( $columnVisited IN ( 0 , 1 ) ) DEFAULT 0
      )
    ''';

    db.execute(sql);
    LoggerService.instance.debug("Created $table with sql: \n $sql");
  }

  static Future<List<Spot>> getAll() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents =
        await db.query(table, orderBy: columnPhotoLink);
    List<Spot> contentList = contents.isNotEmpty
        ? contents.map((e) => Spot.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<List<Spot>> where(
      {String? where, List<Object?>? whereArgs, String? orderBy}) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> contents = await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );

    List<Spot> contentList = contents.isNotEmpty
        ? contents.map((e) => Spot.fromMap(e)).toList()
        : [];
    return contentList;
  }

  static Future<void> add(Spot spot) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    db.insert(
      table,
      spot.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    LoggerService.instance.debug("Inserted: $spot into $table");
  }

  static Future<void> addBatch(List<Spot> spots) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    Batch batch = db.batch();
    for (var entry in spots) {
      batch.insert(
        table,
        entry.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }
    LoggerService.instance.debug("Inserted: $spots into $table as batch");
    batch.commit();
  }

  ///Method that syncs the database with the received list of spots, it updates all the spots in the db with the new info from the list, deletes any on the db that dont exist on the received list from the arguments and adds any new spot into the db
  static Future<void> sync(List<Spot> newSpots) async {
    List<int> newSpotsIds = newSpots.map((e) => e.id).toList();
    DatabaseHelper instance = DatabaseHelper.instance;
    List<Spot> existingSpots = await getAll();
    List<int> existingSpotsIds = existingSpots.map((e) => e.id).toList();

    if (existingSpots.isEmpty) {
      await addBatch(newSpots);
      return;
    }

    //determine which spots to delete
    List<Spot> spotsToDelete =
        existingSpots.where((spot) => !newSpotsIds.contains(spot.id)).toList();

    //determine which spots to update
    List<Spot> spotsToUpdate = existingSpots.where((spot) {
      bool spotInBothLists = newSpotsIds.contains(spot.id);
      if (!spotInBothLists) return false;

      Spot existingSpot = existingSpots[existingSpots.indexOf(spot)];
      Spot newSpot = newSpots[newSpotsIds.indexOf(spot.id)];

      return existingSpot.id == newSpot.id &&
          existingSpot.photoLink == newSpot.photoLink;
    }).toList();
    //determine which spots to add
    List<Spot> spotsToAdd =
        newSpots.where((spot) => !existingSpotsIds.contains(spot.id)).toList();
    LoggerService.instance.debug(
        "spotsToDelete: $spotsToDelete \nspotsToUpdate: $spotsToUpdate \nspotsToAdd: $spotsToAdd");

    await addBatch(spotsToAdd);
    for (Spot spot in spotsToDelete) {
      await remove(spot.id);
    }
    for (Spot spot in spotsToUpdate) {
      await update(spot);
    }

    LoggerService.instance
        .debug("synced: $newSpots into $table\n result: ${await getAll()}");
  }

  static Future<int> update(Spot spot) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    LoggerService.instance.debug("Updating entry: $spot from $table");
    return await db.update(table, spot.toMap(),
        where: "$columnId = ?", whereArgs: [spot.id]);
  }

  static Future<int> remove(int id) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    LoggerService.instance.debug("Removing entry with id:$id from $table");
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  static Future<int> removeALL() async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    LoggerService.instance.debug("Removing all entries from $table");
    return await db.delete(table);
  }

  static Future<void> drop(Database db) async {
    LoggerService.instance.debug("Dropping $table");
    return await db.execute('DROP TABLE IF EXISTS $table');
  }

  static Future<List<Spot>> getAllWithIds(List<int> idList) async {
    DatabaseHelper instance = DatabaseHelper.instance;
    Database db = await instance.database;
    List<Map<String, Object?>> rawRows = await db.query(
      table,
      orderBy: columnId,
      where: '$columnId IN (${List.filled(idList.length, '?').join(',')})',
      whereArgs: idList,
    );
    List<Spot> rowsList =
        rawRows.isNotEmpty ? rawRows.map((e) => Spot.fromMap(e)).toList() : [];
    return rowsList;
  }
}
