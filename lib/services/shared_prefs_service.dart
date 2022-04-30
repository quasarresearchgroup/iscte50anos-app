import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _allPuzzlesCompletedSharedPrefsKey =
      "all_puzzle_complete";
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  ValueNotifier<bool>? allPuzzleCompleteState;

  SharedPrefsService._internal() {
    _getcurrentState();
  }
  void _getcurrentState() async {
    var currentState = await getCompletedAllPuzzles();
    allPuzzleCompleteState = ValueNotifier(currentState);
  }

  factory SharedPrefsService() {
    return _instance;
  }

  static Future<bool> storeCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, true);
    (await SharedPrefsService().allPuzzleCompleteState)?.value = true;
    return true;
  }

  static Future<bool> resetCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, false);
    (await SharedPrefsService().allPuzzleCompleteState)?.value = false;
    return false;
  }

  static Future<bool> getCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_allPuzzlesCompletedSharedPrefsKey) ?? false;
  }
}
