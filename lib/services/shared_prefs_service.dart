import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _allPuzzlesCompletedSharedPrefsKey =
      "all_puzzle_complete";
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  static final Logger _logger = Logger();

  ValueNotifier<bool> allPuzzleCompleteState = ValueNotifier<bool>(false);
  SharedPrefsService._internal() {
    _getcurrentState();
  }
  void _getcurrentState() async {
    var currentState = await getCompletedAllPuzzles();
    allPuzzleCompleteState.value = currentState;
  }

  factory SharedPrefsService() {
    return _instance;
  }

  static Future<bool> storeCompletedAllPuzzles() async {
    _logger.d("storeCompletedAllPuzzles : true");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, true);
    (await SharedPrefsService().allPuzzleCompleteState).value = true;
    return true;
  }

  static Future<bool> resetCompletedAllPuzzles() async {
    _logger.d("resetCompletedAllPuzzles : false");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, false);
    (await SharedPrefsService().allPuzzleCompleteState).value = false;
    return false;
  }

  static Future<bool> getCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    bool currentStatus =
        prefs.getBool(_allPuzzlesCompletedSharedPrefsKey) ?? false;
    _logger.d("getCompletedAllPuzzles :$currentStatus");
    return currentStatus;
  }
}
