import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iscte_spots/helper/image_manipulation.dart';
import 'package:iscte_spots/models/database/tables/database_puzzle_piece_table.dart';
import 'package:iscte_spots/models/puzzle_piece.dart';
import 'package:iscte_spots/widgets/puzzle/puzzle_piece_widget.dart';
import 'package:iscte_spots/widgets/util/loading.dart';
import 'package:logger/logger.dart';

class PuzzlePage extends StatefulWidget {
  PuzzlePage({Key? key, required this.image, required this.constraints})
      : super(key: key);
  final Logger _logger = Logger();
  static const pageRoute = "/puzzle";

  final int rows = 5;
  final int cols = 5;
  final Image image;
  final BoxConstraints constraints;

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<Widget> pieces = [];
  //make this a future so that previous operations get queued and complete only when this has values
  @override
  void initState() {
    super.initState();
    generatePieces(widget.image);
  }

  @override
  void didUpdateWidget(PuzzlePage oldWidget) {
    if (oldWidget.image != widget.image) {
      widget._logger.d("changing image");
      generatePieces(widget.image);
    }
    super.didUpdateWidget(oldWidget);
  }

  void generatePieces(Image img) async {
    setState(() {
      pieces = [];
    });
    Size imageSize = await ImageManipulation.getImageSize(img);
    final double imageWidth;
    final double imageHeight;
    final double aspectRatio = imageSize.width / imageSize.height;
    //if (imageSize.width < imageSize.height) {
    imageWidth = min(widget.constraints.maxWidth, widget.constraints.maxWidth);
    imageHeight = min(widget.constraints.maxWidth / aspectRatio,
        widget.constraints.maxHeight);
    // } else {
    //   imageWidth = widget.constraints.maxHeight * aspectRatio;
    //   imageHeight = widget.constraints.maxHeight;
    // }
    widget._logger.d("imageWidth:$imageWidth; imageHeight:$imageHeight");
    List<PuzzlePiece> storedPuzzlePieces =
        await DatabasePuzzlePieceTable.getAll();
    List<PuzzlePieceWidget> storedPuzzlePieceWidgets = [];
    List<Point> storedPositions = [];
    for (var element in storedPuzzlePieces) {
      storedPuzzlePieceWidgets.add(
        element.getWidget(
            img, imageSize, bringToTop, sendToBack, widget.constraints),
      );
      storedPositions.add(Point(element.row, element.column));
    }

    List<PuzzlePieceWidget> notStoredPieces =
        (await ImageManipulation.splitImagePuzzlePiece(
      image: img,
      bringToTop: bringToTop,
      sendToBack: sendToBack,
      rows: widget.rows,
      cols: widget.cols,
      constraints: widget.constraints,
    ))
            .where((PuzzlePieceWidget element) {
      Point<int> point = Point(element.row, element.col);
      return !storedPositions.contains(point);
    }).toList();

/*
    if (puzzlePiecesList.length < widget.rows * widget.cols) {
      List<PuzzlePiece> storedPieces = await DatabasePuzzlePieceTable.getAll();

      puzzlePiecesList = await ImageManipulation.splitImagePuzzlePiece(
        image: img,
        bringToTop: bringToTop,
        sendToBack: sendToBack,
        rows: widget.rows,
        cols: widget.cols,
        constraints: widget.constraints,
      );
      Size imageSize = await ImageManipulation.getImageSize(img);
      final imageWidth = widget.constraints.maxWidth;
      final imageHeight = widget.constraints.maxHeight *
          widget.constraints.maxWidth /
          imageSize.width;

      List<PuzzlePiece> remadePuzzlePieces =
          puzzlePiecesList.map((PuzzlePieceWidget e) {
        final double pieceWidth = imageWidth / e.maxCol;
        final double pieceHeight = imageHeight / e.maxRow;

        double maxHeight = e.maxRow * pieceHeight * 0.5;
        double minHeight = e.row * pieceHeight * 0.5;
        double maxWidth = e.maxCol * pieceWidth * 0.5;
        double minWidth = e.col * pieceWidth * 0.5;
        return PuzzlePiece(
          row: e.row,
          column: e.col,
          maxRow: e.maxRow,
          maxColumn: e.maxCol,
          top: (Random().nextDouble() * maxHeight) - minHeight,
          left: (Random().nextDouble() * maxWidth) - minWidth,
        );
      }).toList();

      List<PuzzlePiece> notStoredPieces = [];
      for (var element in remadePuzzlePieces) {
        if (!storedPieces.contains(element)) {
          notStoredPieces.add(element);
        }
      }

      DatabasePuzzlePieceTable.addBatch(notStoredPieces);
    }

    List<PuzzlePieceWidget> movablePuzzlePieces = puzzlePiecesList
        .where((element) => element.movable != null ? element.movable! : true)
        .toList();
    List<PuzzlePieceWidget> snappedPuzzlePieces = puzzlePiecesList
        .where((element) => element.movable != null ? !element.movable! : false)
        .toList();
*/

    pieces.add(SizedBox.expand(child: Container()));
    pieces.add(Container(
      decoration: BoxDecoration(
        color: Colors.brown,
        border: Border.all(
          color: Theme.of(context).shadowColor.withAlpha(100),
        ),
      ),
      child: SizedBox(
        width: imageWidth,
        height: imageHeight,
      ),
    ));
    //pieces.addAll(snappedPuzzlePieces);
    //pieces.addAll(movablePuzzlePieces);
    pieces.addAll(storedPuzzlePieceWidgets);
    pieces.addAll(notStoredPieces);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return pieces.isNotEmpty ? Stack(children: pieces) : const LoadingWidget();
  }

  void bringToTop(Widget targetWidget) {
    //widget._logger.d("Used bringToTop function on $targetWidget.");
    setState(() {
      pieces.remove(targetWidget);
      pieces.add(targetWidget);
    });
  }

// when a piece reaches its final position, it will be sent to the back of the stack to not get in the way of other, still movable, pieces
  void sendToBack(Widget targetWidget) {
    //widget._logger.d("Used sendToBack function on $targetWidget");
    setState(() {
      pieces.remove(targetWidget);
      pieces.insert(2, targetWidget);
    });
  }
}
