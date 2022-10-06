import 'package:flutter/cupertino.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/database/tables/database_spot_table.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:iscte_spots/pages/home/puzzle/puzzle_piece_widget.dart';

class PuzzlePiece {
  PuzzlePiece({
    required this.spotID,
    required this.row,
    required this.column,
    required this.maxRow,
    required this.maxColumn,
    required this.left,
    required this.top,
  });
  final int spotID;
  final double left;
  final double top;
  final int row;
  final int column;
  final int maxRow;
  final int maxColumn;

  @override
  String toString() {
    return 'PuzzlePiece{spotID: $spotID, left: $left, top: $top, row: $row, column: $column, maxRow: $maxRow, maxColumn: $maxColumn}';
  }

  Future<PuzzlePieceWidget> getWidget({
    required Size imageSize,
    required bringToTop,
    required sendToBack,
    required BoxConstraints constraints,
    required completeCallback,
    bool isTurned = false,
  }) async {
    Spot spot = (await DatabaseSpotTable.getAllWithIds([spotID])).first;
    return PuzzlePieceWidget(
      spot: spot,
      imageSize: imageSize,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      constraints: constraints,
      row: row,
      col: column,
      maxRow: maxRow,
      maxCol: maxColumn,
      top: top,
      left: left,
      movable: (top != 0 || left != 0),
      completeCallback: completeCallback,
    );
  }

  factory PuzzlePiece.fromMap(Map<String, dynamic> json) => PuzzlePiece(
        spotID: json[DatabasePuzzlePieceTable.columnSpotId],
        row: json[DatabasePuzzlePieceTable.columnRow],
        column: json[DatabasePuzzlePieceTable.columnColumn],
        maxRow: json[DatabasePuzzlePieceTable.columnMaxRow],
        maxColumn: json[DatabasePuzzlePieceTable.columnMaxColumn],
        left: json[DatabasePuzzlePieceTable.columnLeft],
        top: json[DatabasePuzzlePieceTable.columnTop],
      );

  Map<String, dynamic> toMap() {
    return {
      DatabasePuzzlePieceTable.columnSpotId: spotID,
      DatabasePuzzlePieceTable.columnRow: row,
      DatabasePuzzlePieceTable.columnColumn: column,
      DatabasePuzzlePieceTable.columnMaxRow: maxRow,
      DatabasePuzzlePieceTable.columnMaxColumn: maxColumn,
      DatabasePuzzlePieceTable.columnLeft: left,
      DatabasePuzzlePieceTable.columnTop: top,
    };
  }
}
