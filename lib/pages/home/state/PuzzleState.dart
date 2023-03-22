import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/services/shared_prefs_service.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_page.dart';

class PuzzleState {
  PuzzleState._privateConstructor()
      : _currentPuzzleProgress = ValueNotifier<double>(0.0) {
    SharedPrefsService.getCurrentSpot().then((Spot? value) {
      if (value != null) _updateCurrentPuzzleProgress(value.id);
    });
  }

  static final PuzzleState _instance = PuzzleState._privateConstructor();

  final ValueNotifier<double> _currentPuzzleProgress;

  static ValueNotifier<double> get currentPuzzleProgress =>
      _instance._currentPuzzleProgress;

  static Future<void> snapPuzzlePiece(PuzzlePiece puzzlePiece) async {
    await DatabasePuzzlePieceTable.add(puzzlePiece);
    Spot? currentSpot = await (SharedPrefsService.getCurrentSpot());
    if (currentSpot == null) return;

    await _updateCurrentPuzzleProgress(currentSpot.id);
  }

  static Future<void> changeSpot(int spotId) async {
    await _updateCurrentPuzzleProgress(spotId);
  }

  static Future<void> _updateCurrentPuzzleProgress(int spotID) async {
    int nPlacedPieces =
        (await DatabasePuzzlePieceTable.getAllFromSpot(spotID)).length;
    currentPuzzleProgress.value =
        (nPlacedPieces / (PuzzlePage.cols * PuzzlePage.rows));
  }
}
