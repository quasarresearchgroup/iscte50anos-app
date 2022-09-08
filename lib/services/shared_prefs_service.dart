import 'package:flutter/foundation.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/logging/LoggerService.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _allPuzzlesCompletedSharedPrefsKey =
      "all_puzzle_complete";
  static const String _currentSpotIdPrefsString = "currentSpot";
  static final SharedPrefsService _instance = SharedPrefsService._internal();

  ValueNotifier<bool> allPuzzleCompleteNotifier = ValueNotifier<bool>(false);
  ValueNotifier<Spot?> currentSpotNotifier = ValueNotifier<Spot?>(null);

  SharedPrefsService._internal() {
    _getcurrentState();
  }
  void _getcurrentState() async {
    allPuzzleCompleteNotifier.value = await getCompletedAllPuzzles();
    currentSpotNotifier.value = await getCurrentSpot();
  }

  factory SharedPrefsService() {
    return _instance;
  }

//region completed puzzles
  static Future<bool> storeCompletedAllPuzzles() async {
    LoggerService.instance.debug("storeCompletedAllPuzzles : true");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, true);
    (SharedPrefsService().allPuzzleCompleteNotifier).value = true;
    return true;
  }

  static Future<bool> resetCompletedAllPuzzles() async {
    LoggerService.instance.debug("resetCompletedAllPuzzles : false");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, false);
    SharedPrefsService().allPuzzleCompleteNotifier.value = false;
    return false;
  }

  static Future<bool> getCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    bool currentStatus =
        prefs.getBool(_allPuzzlesCompletedSharedPrefsKey) ?? false;
    LoggerService.instance.debug("getCompletedAllPuzzles :$currentStatus");
    return currentStatus;
  }
//endregion

//region Current Spot
  static Future<void> storeCurrentSpot(Spot spot) async {
    assert(spot.id != null);
    LoggerService.instance.debug("storeCurrentSpotID : $spot");
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(_currentSpotIdPrefsString, spot.id);
    SharedPrefsService().currentSpotNotifier.value = spot;
  }

  static Future<void> resetCurrentSpot() async {
    LoggerService.instance.debug("resetCompletedAllPuzzles : false");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_currentSpotIdPrefsString, "");
    SharedPrefsService().currentSpotNotifier.value = null;
  }

  static Future<Spot?> getCurrentSpot() async {
    final prefs = await SharedPreferences.getInstance();
    int? currentSpotID = prefs.getInt(_currentSpotIdPrefsString);
    LoggerService.instance.debug("currentSpotID: $currentSpotID");
    if (currentSpotID == null) {
      return null;
    } else {
      LoggerService.instance.debug("getCurrentSpot :$currentSpotID");

      List<Spot> spotsList =
          await DatabaseSpotTable.getAllWithIds([currentSpotID]);
      if (spotsList.isEmpty) {
        return null;
      } else {
        return spotsList.first;
      }
    }
  }
//endregion
}
