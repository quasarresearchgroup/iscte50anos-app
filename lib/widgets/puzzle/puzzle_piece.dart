import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece_painter.dart';

class PuzzlePiece extends StatefulWidget {
  final Image image;
  final Size imageSize;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final Function bringToTop;
  final Function sendToBack;

  const PuzzlePiece(
      {required Key key,
      required this.image,
      required this.imageSize,
      required this.row,
      required this.col,
      required this.maxRow,
      required this.maxCol,
      required this.bringToTop,
      required this.sendToBack})
      : super(key: key);

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
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).size.width /
        widget.imageSize.width;
    final pieceWidth = imageWidth / widget.maxCol;
    final pieceHeight = imageHeight / widget.maxRow;

    if (top == null) {
      top = Random().nextInt((imageHeight - pieceHeight).ceil()).toDouble();
      top = top! - widget.row * pieceHeight;
    }
    if (left == null) {
      left = Random().nextInt((imageWidth - pieceWidth).ceil()).toDouble();
      left = left! - widget.col * pieceWidth;
    }

    return Positioned(
        top: top,
        left: left,
        width: imageWidth,
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
                  isMovable = false;
                  widget.sendToBack(widget);
                }
              });
            }
          },
          child: ClipPath(
            child: widget.image,
            clipper: PuzzlePieceClipper(
                widget.row, widget.col, widget.maxRow, widget.maxCol),
          ),
        ));
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
