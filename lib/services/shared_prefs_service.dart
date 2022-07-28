import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _allPuzzlesCompletedSharedPrefsKey =
      "all_puzzle_complete";
  static const String _currentPuzzleImgString = "currentPuzzleIMG";
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  static final Logger _logger = Logger();

  ValueNotifier<bool> allPuzzleCompleteNotifier = ValueNotifier<bool>(false);
  ValueNotifier<String> currentPuzzleIMGNotifier = ValueNotifier<String>("");

  SharedPrefsService._internal() {
    _getcurrentState();
  }
  void _getcurrentState() async {
    var currentCompletePuzzleState = await getCompletedAllPuzzles();
    allPuzzleCompleteNotifier.value = currentCompletePuzzleState;
    var currentPuzzleIMGState = await getCurrentPuzzleIMG();
    currentPuzzleIMGNotifier.value = currentPuzzleIMGState;
  }

  factory SharedPrefsService() {
    return _instance;
  }

//region completed puzzles
  static Future<bool> storeCompletedAllPuzzles() async {
    _logger.d("storeCompletedAllPuzzles : true");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, true);
    (SharedPrefsService().allPuzzleCompleteNotifier).value = true;
    return true;
  }

  static Future<bool> resetCompletedAllPuzzles() async {
    _logger.d("resetCompletedAllPuzzles : false");
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_allPuzzlesCompletedSharedPrefsKey, false);
    SharedPrefsService().allPuzzleCompleteNotifier.value = false;
    return false;
  }

  static Future<bool> getCompletedAllPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    bool currentStatus =
        prefs.getBool(_allPuzzlesCompletedSharedPrefsKey) ?? false;
    _logger.d("getCompletedAllPuzzles :$currentStatus");
    return currentStatus;
  }
//endregion

//region Current puzzle image
  static Future<void> storeCurrentPuzzleIMG(String imageLink) async {
    _logger.d("storeCompletedAllPuzzles : $imageLink");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_currentPuzzleImgString, imageLink);
    SharedPrefsService().currentPuzzleIMGNotifier.value = imageLink;
  }

  static Future<void> resetCurrentPuzzleIMG() async {
    _logger.d("resetCompletedAllPuzzles : false");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_currentPuzzleImgString, "");
    SharedPrefsService().currentPuzzleIMGNotifier.value = "";
  }

  static Future<String> getCurrentPuzzleIMG() async {
    final prefs = await SharedPreferences.getInstance();
    String currentImage = prefs.getString(_currentPuzzleImgString) ?? "";
    _logger.d("getCurrentPuzzleIMG :$currentImage");
    return currentImage;
  }
//endregion
}
