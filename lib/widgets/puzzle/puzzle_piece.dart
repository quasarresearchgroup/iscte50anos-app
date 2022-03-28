import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece_painter.dart';
import 'package:logger/logger.dart';

class PuzzlePiece extends StatefulWidget {
  final Logger _logger = Logger();

  final Image image;
  final Size imageSize;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final Function bringToTop;
  final Function sendToBack;
  final bool snapInPlace;
  final BoxConstraints constraints;

  PuzzlePiece({
    required Key key,
    required this.image,
    required this.imageSize,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    required this.bringToTop,
    required this.sendToBack,
    required this.constraints,
    this.snapInPlace = true,
  }) : super(key: key);

  @override
  PuzzlePieceState createState() {
    return PuzzlePieceState();
  }
}

class PuzzlePieceState extends State<PuzzlePiece> {
  double? top;
  double? left;
  bool isMovable = true;

  @override
  void initState() {
    super.initState();
    final imageWidth = widget.constraints.maxWidth;
    final imageHeight = widget.constraints.maxHeight *
        widget.constraints.maxWidth /
        widget.imageSize.width;
    final double pieceWidth = imageWidth / widget.maxCol;
    final double pieceHeight = imageHeight / widget.maxRow;

    double maxHeight = widget.maxRow * pieceHeight * 0.5;
    double minHeight = widget.row * pieceHeight * 0.5;
    double maxWidth = widget.maxCol * pieceWidth * 0.5;
    double minWidth = widget.col * pieceWidth * 0.5;
    top ??= (Random().nextDouble() * maxHeight) - minHeight;
    left ??= (Random().nextDouble() * maxWidth) - minWidth;
    widget._logger.d(
        "col:${widget.col}; row:${widget.row}; pieceHeight:$pieceHeight; pieceWidth:$pieceWidth; top:$top; left:$left;");
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
            if (isMovable) {
              setState(() {
                top = top! + dragUpdateDetails.delta.dy;
                left = left! + dragUpdateDetails.delta.dx;

                if (-10 < top! && top! < 10 && -10 < left! && left! < 10) {
                  top = 0;
                  left = 0;
                  if (widget.snapInPlace) {
                    isMovable = false;
                  }
                  widget.sendToBack(widget);
                }
                widget._logger.d("top:$top; left: $left");
              });
            }
          },
          child: ClippedPiece(
              image: widget.image,
              row: widget.row,
              col: widget.col,
              maxRow: widget.maxRow,
              width: widget.constraints.maxWidth,
              maxCol: widget.maxCol),
        ));
  }
}

class ClippedPiece extends StatelessWidget {
  const ClippedPiece({
    Key? key,
    required this.image,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    required this.width,
  }) : super(key: key);

  final double width;
  final Image image;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: ClipPath(
        child: image,
        clipper: PuzzlePieceClipper(row, col, maxRow, maxCol),
      ),
    );
  }
}

// this class is used to clip the image to the puzzle piece path
class PuzzlePieceClipper extends CustomClipper<Path> {
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;

  PuzzlePieceClipper(this.row, this.col, this.maxRow, this.maxCol);

  @override
  Path getClip(Size size) {
    return getPiecePath(size, row, col, maxRow, maxCol);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
