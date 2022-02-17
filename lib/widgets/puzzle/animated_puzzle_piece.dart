import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/helper_methods.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece.dart';

class AnimatedPuzzlePiece extends StatefulWidget {
  final Image image;
  final Size imageSize;
  final int row;
  final int col;
  final int maxRow;
  final int maxCol;
  final Function bringToTop;
  final Function sendToBack;
  final Duration animDuration;

  AnimatedPuzzlePiece({
    required Key key,
    required this.image,
    required this.imageSize,
    required this.row,
    required this.col,
    required this.maxRow,
    required this.maxCol,
    required this.bringToTop,
    required this.sendToBack,
    required this.animDuration,
  }) : super(key: key);

  double top = 0;
  double left = 0;
  double accelX = 0;
  double accelY = 0;
  int lastDeltaTime = 0;

  void addAccel({required double x, required double y}) {
    double timedif = HelperMethods.deltaTime(lastDeltaTime);
    accelX += x * timedif;
    accelY += y * timedif;
  }

  void move() {
    top = (top + accelY);
    left = (left + accelX);
  }

  @override
  AnimatedPuzzlePieceState createState() {
    return AnimatedPuzzlePieceState();
  }
}

class AnimatedPuzzlePieceState extends State<AnimatedPuzzlePiece> {
  late final double imageWidth;
  late final double imageHeight;

  @override
  void initState() {
    imageWidth = MediaQuery.of(context).size.width;
    imageHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).size.width /
        widget.imageSize.width;
    final pieceWidth = imageWidth / widget.maxCol;
    final pieceHeight = imageHeight / widget.maxRow;

    widget.top =
        Random().nextInt((imageHeight - pieceHeight).ceil()).toDouble();
    widget.top = widget.top - widget.row * pieceHeight;
    widget.left = Random().nextInt((imageWidth - pieceWidth).ceil()).toDouble();
    widget.left = widget.left - widget.col * pieceWidth;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        top: widget.top,
        left: widget.left,
        duration: widget.animDuration,
        width: imageWidth,
        child: GestureDetector(
          onTap: () {
            widget.bringToTop(widget);
          },
          onPanStart: (_) {
            widget.bringToTop(widget);
          },
          onPanUpdate: (dragUpdateDetails) {
            setState(() {
              widget.top = widget.top + dragUpdateDetails.delta.dy;
              widget.left = widget.left + dragUpdateDetails.delta.dx;
            });
          },
          child: ClipPath(
            child: widget.image,
            clipper: PuzzlePieceClipper(
                widget.row, widget.col, widget.maxRow, widget.maxCol),
          ),
        ));
  }
}
