import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/models/spot.dart';
import 'package:logger/logger.dart';

import 'clipped_piece_widget.dart';

class PuzzlePieceWidget extends StatefulWidget {
  final Logger _logger = Logger();

  final Spot spot;
  final Size imageSize;
  final Function bringToTop;
  final Function sendToBack;
  final bool snapInPlace;
  final BoxConstraints constraints;
  final Function completeCallback;

  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final double? top;
  final double? left;
  final bool? movable;

  PuzzlePieceWidget({
    Key? key,
    required this.spot,
    required this.imageSize,
    required this.bringToTop,
    required this.sendToBack,
    required this.constraints,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    this.snapInPlace = true,
    this.top,
    this.left,
    this.movable,
    required this.completeCallback,
  }) : super(key: key);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PuzzlePieceWidget{row: $row, col: $col, maxRow: $maxRow, maxCol: $maxCol, top: $top, left: $left, movable: $movable,spot: $spot, imageSize: $imageSize, bringToTop: $bringToTop, sendToBack: $sendToBack, snapInPlace: $snapInPlace}';
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
  late final double pieceWidth;
  late final double pieceHeight;

  @override
  void initState() {
    super.initState();

    top = widget.top;
    left = widget.left;
    if (widget.movable != null) {
      isMovable = widget.movable!;
    }

    pieceHeight = widget.imageSize.height / widget.maxRow;
    pieceWidth = widget.imageSize.width / widget.maxCol;
    zeroHeight = -widget.row * pieceHeight;
    zeroWidth = -widget.col * pieceWidth;
    //widget._logger.d(" row: ${widget.row}; col: ${widget.col} ;pieceHeight: $pieceHeight; pieceWidth: $pieceWidth; zeroHeight: $zeroHeight; zeroWidth: $zeroWidth; ");
    maxHeight = zeroHeight - pieceHeight + widget.constraints.maxHeight;
    minHeight = zeroHeight - 2 * pieceHeight + widget.constraints.maxHeight;
    maxWidth = zeroWidth + widget.constraints.maxWidth - pieceWidth;
    minWidth = zeroWidth;

    if (top == null || left == null) {
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
      child: GestureDetector(
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
          move(
            dx: dragUpdateDetails.delta.dx,
            dy: dragUpdateDetails.delta.dy,
            constraints: widget.constraints,
          );
        },
        child: ClippedPieceWidget(
          image: Image.network(widget.spot.photoLink),
          row: widget.row,
          col: widget.col,
          maxRow: widget.maxRow,
          width: widget.imageSize.width,
          maxCol: widget.maxCol,
        ),
      ),
    );
  }

  void move({
    required double dx,
    required double dy,
    required BoxConstraints constraints,
  }) {
    double maxTop = zeroHeight + constraints.maxHeight - pieceHeight;
    double maxLeft = zeroWidth + constraints.maxWidth - pieceWidth;

    if (isMovable) {
      top = max(
        zeroHeight,
        min(
          maxTop,
          top != null ? (top! + dy) : dy,
        ),
      );
      left = max(
        zeroWidth,
        min(
          maxLeft,
          left != null ? (left! + dx) : dx,
        ),
      );
      //top = min(top != null ? (top! + dy) : dy,
      //    constraints.maxHeight - zeroHeight - 100);
      //left = min(left != null ? (left! + dx) : dx,
      //    constraints.maxWidth - zeroWidth - 100);

      if (-10 < top! && top! < 10 && -10 < left! && left! < 10) {
        snapInPlace();
      }
      //widget._logger.d("top:$top; left: $left, pieceHeight: $pieceHeight; pieceWIdth: $pieceWidth; maxTop: $maxTop ;maxLeft: $maxLeft ;");
      //widget._logger.d(constraints);
      setState(() {});
    }
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
      spotID: widget.spot.id,
    ));

    List<PuzzlePiece> listPuzzlePieces =
        await DatabasePuzzlePieceTable.getAllFromSpot(widget.spot.id);
    if (listPuzzlePieces.length == (widget.maxRow * widget.maxCol)) {
      widget.completeCallback();
    }
  }
}
