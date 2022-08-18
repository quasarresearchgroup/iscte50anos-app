import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';

import 'clipped_piece_widget.dart';

class PuzzlePieceWidget extends StatefulWidget {
  //final Logger _logger = Logger();

  final Image image;
  final Size imageSize;
  final Function bringToTop;
  final Function sendToBack;
  final bool snapInPlace;
  //final BoxConstraints constraints;
  final Function completeCallback;

  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final double? top;
  final double? left;
  final bool? movable;
  final int quarterTurns;

  const PuzzlePieceWidget({
    Key? key,
    required this.image,
    required this.imageSize,
    required this.bringToTop,
    required this.sendToBack,
    //required this.constraints,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    this.snapInPlace = true,
    this.top,
    this.left,
    this.movable,
    required this.completeCallback,
    this.quarterTurns = 0,
  }) : super(key: key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is PuzzlePieceWidget &&
          runtimeType == other.runtimeType &&
          image == other.image &&
          imageSize == other.imageSize &&
          bringToTop == other.bringToTop &&
          sendToBack == other.sendToBack &&
          snapInPlace == other.snapInPlace &&
          //constraints == other.constraints &&
          row == other.row &&
          col == other.col &&
          maxRow == other.maxRow &&
          maxCol == other.maxCol &&
          movable == other.movable;

  @override
  int get hashCode =>
      super.hashCode ^
      image.hashCode ^
      imageSize.hashCode ^
      bringToTop.hashCode ^
      sendToBack.hashCode ^
      snapInPlace.hashCode ^
      //constraints.hashCode ^
      row.hashCode ^
      col.hashCode ^
      maxRow.hashCode ^
      maxCol.hashCode ^
      movable.hashCode;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PuzzlePieceWidget{row: $row, col: $col, maxRow: $maxRow, maxCol: $maxCol, top: $top, left: $left, movable: $movable,image: $image, imageSize: $imageSize, bringToTop: $bringToTop, sendToBack: $sendToBack, snapInPlace: $snapInPlace, quarterTurns: $quarterTurns}';
  }

  @override
  PuzzlePieceWidgetState createState() {
    return PuzzlePieceWidgetState();
  }
}

class PuzzlePieceWidgetState extends State<PuzzlePieceWidget> {
  double? top;
  double? left;
  bool isMovable = true;
  late double zeroWidth;
  late double zeroHeight;
  late double maxHeight;
  late double minHeight;
  late double maxWidth;
  late double minWidth;

  @override
  void initState() {
    super.initState();

    top = widget.top;
    left = widget.left;
    if (widget.movable != null) {
      isMovable = widget.movable!;
    }

    if (top == null || left == null) {
      final double pieceHeight = widget.imageSize.height / widget.maxRow;
      zeroHeight = (-widget.row) * pieceHeight;
      maxHeight = zeroHeight + (widget.maxRow - 1) * pieceHeight;

      minHeight = zeroHeight + (widget.maxRow - 2) * pieceHeight;

      final double pieceWidth = widget.imageSize.width / widget.maxCol;
      zeroWidth = (-widget.col) * pieceWidth;
      maxWidth = zeroWidth + (widget.maxCol - 1) * pieceWidth;
      minWidth = zeroWidth;

      double x =
          ((Random().nextDouble() * (maxHeight - minHeight)) + minHeight);
      double y = ((Random().nextDouble() * (maxWidth - minWidth)) + minWidth);

      top ??= x;
      left ??= y;

      /*
        Logger().d(
        "col:${widget.col};"
        "row:${widget.row};"
        "maxHeight: $maxHeight;"
        "minHeight: $minHeight;"
        "maxWidth: $maxWidth;"
        "minWidth: $minWidth;"
        "top:$top;"
        "left:$left;",
      );
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: () {
            if (isMovable) {
              widget.bringToTop(widget);
            }
          },
          onPanStart: (_) {
            if (isMovable) {
              widget.bringToTop(widget);
            }
          },
          onPanUpdate: (dragUpdateDetails) {
            if (isMovable) {
              setState(() {
                top = min(top! + dragUpdateDetails.delta.dy,
                    constraints.maxHeight - zeroHeight - 100);
                left = min(left! + dragUpdateDetails.delta.dx,
                    constraints.maxWidth - zeroWidth - 100);

                if (-10 < top! && top! < 10 && -10 < left! && left! < 10) {
                  snapInPlace();
                }
                //widget._logger.d("top:$top; left: $left");
              });
            }
          },
          child: RotatedBox(
            quarterTurns: widget.quarterTurns,
            child: ClippedPieceWidget(
              image: widget.image,
              row: widget.row,
              col: widget.col,
              maxRow: widget.maxRow,
              width: widget.imageSize.width,
              maxCol: widget.maxCol,
            ),
          ),
        ),
      ),
    );
  }

  void snapInPlace() async {
    top = 0;
    left = 0;
    if (widget.snapInPlace) {
      isMovable = false;
    }
    widget.sendToBack(widget);

    await DatabasePuzzlePieceTable.add(PuzzlePiece(
      row: widget.row,
      column: widget.col,
      maxRow: widget.maxRow,
      maxColumn: widget.maxCol,
      top: top!,
      left: left!,
    ));

    List<PuzzlePiece> listPuzzlePieces =
        await DatabasePuzzlePieceTable.getAll();
    if (listPuzzlePieces.length == (widget.maxRow * widget.maxCol)) {
      widget.completeCallback();
    }
  }
}
